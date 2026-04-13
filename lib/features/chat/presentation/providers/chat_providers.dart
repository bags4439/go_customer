import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/chat_firestore_data_source.dart';
import '../../domain/entities/chat_message.dart';

final chatDataSourceProvider = Provider<ChatFirestoreDataSource>((ref) {
  return ChatFirestoreDataSource(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  );
});

final messagesProvider = StreamProvider.family<MessagesPageResult, String>((
  ref,
  orderId,
) {
  return ref.watch(chatDataSourceProvider).watchMessages(orderId);
});

/// Pagination: older messages loaded on scroll-to-top.
class ChatPaginationState {
  final List<ChatMessage> olderMessages;
  final bool hasMoreMessages;
  final bool isLoadingMore;
  final DocumentSnapshot? lastDocumentForLoadMore;

  const ChatPaginationState({
    this.olderMessages = const [],
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.lastDocumentForLoadMore,
  });
}

final chatPaginationNotifierProvider =
    StateNotifierProvider.family<
      ChatPaginationNotifier,
      ChatPaginationState,
      String
    >((ref, orderId) => ChatPaginationNotifier(ref, orderId));

class ChatPaginationNotifier extends StateNotifier<ChatPaginationState> {
  final Ref _ref;
  final String orderId;

  ChatPaginationNotifier(this._ref, this.orderId)
    : super(const ChatPaginationState());

  Future<void> loadMore(DocumentSnapshot lastDocument) async {
    if (state.isLoadingMore || !state.hasMoreMessages) return;
    state = ChatPaginationState(
      olderMessages: state.olderMessages,
      hasMoreMessages: state.hasMoreMessages,
      isLoadingMore: true,
      lastDocumentForLoadMore: state.lastDocumentForLoadMore,
    );
    try {
      final ds = _ref.read(chatDataSourceProvider);
      final (next, nextLastDoc) = await ds.loadMoreMessages(
        orderId,
        lastDocument,
      );
      state = ChatPaginationState(
        olderMessages: [...next, ...state.olderMessages],
        hasMoreMessages: next.length >= 30,
        isLoadingMore: false,
        lastDocumentForLoadMore: nextLastDoc,
      );
    } catch (_) {
      state = ChatPaginationState(
        olderMessages: state.olderMessages,
        hasMoreMessages: state.hasMoreMessages,
        isLoadingMore: false,
        lastDocumentForLoadMore: state.lastDocumentForLoadMore,
      );
    }
  }
}

/// Pending message (not yet or just sent): shown with status pending/sent until stream has it.
class PendingMessage {
  final String tempId;
  final String messageType;
  final String? body;
  final String? localPath;
  final double progress;
  final String status; // 'pending' | 'sent'
  final String? firestoreId;
  final DateTime sentAt;

  PendingMessage({
    required this.tempId,
    required this.messageType,
    this.body,
    this.localPath,
    this.progress = 0.0,
    this.status = 'pending',
    this.firestoreId,
    required this.sentAt,
  });

  PendingMessage copyWith({
    double? progress,
    String? status,
    String? firestoreId,
  }) => PendingMessage(
    tempId: tempId,
    messageType: messageType,
    body: body,
    localPath: localPath,
    progress: progress ?? this.progress,
    status: status ?? this.status,
    firestoreId: firestoreId ?? this.firestoreId,
    sentAt: sentAt,
  );
}

final pendingMessagesProvider =
    StateProvider.family<List<PendingMessage>, String>((ref, orderId) => []);

/// Multi-image selection (up to 5) before sending. Stores file paths.
final pendingSelectedImagesProvider =
    StateProvider.family<List<String>, String>((ref, orderId) => []);

/// Single video file path before sending (recorded or picked).
final pendingVideoPathProvider = StateProvider.family<String?, String>(
  (ref, orderId) => null,
);

final unreadCountProvider = StreamProvider.family<int, String>((ref, orderId) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestoreCollections.messages)
      .where('orderId', isEqualTo: orderId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final unreadFromAgentCountProvider = StreamProvider.family<int, String>((
  ref,
  orderId,
) {
  return ref
      .watch(firestoreProvider)
      .collection(FirestoreCollections.messages)
      .where('orderId', isEqualTo: orderId)
      .where('isRead', isEqualTo: false)
      .where('senderRole', isNotEqualTo: FirestoreEnumValues.roleBuyer)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final messageReactionsProvider =
    StreamProvider.family<Map<String, List<String>>, String>((ref, orderId) {
      return ref.watch(chatDataSourceProvider).watchMessageReactions(orderId);
    });

final agentTypingProvider = StreamProvider.family<bool, String>((ref, orderId) {
  return ref.watch(chatDataSourceProvider).watchAgentTyping(orderId);
});

final messageInputProvider = StateProvider<String>((ref) => '');
final isRecordingProvider = StateProvider<bool>((ref) => false);

class ReplyState {
  final String messageId;
  final String? body;

  const ReplyState({required this.messageId, this.body});
}

final replyStateProvider = StateProvider.family<ReplyState?, String>(
  (ref, orderId) => null,
);

/// Combined list: older (pagination) + latest page (stream), then pending (text/image only). Chronological order.
final chatDisplayMessagesProvider = Provider.family<List<Object>, String>((
  ref,
  orderId,
) {
  final pageResult = ref.watch(messagesProvider(orderId)).valueOrNull;
  final pagination = ref.watch(chatPaginationNotifierProvider(orderId));
  final streamMessages = pageResult?.messages ?? [];
  final streamIds = {for (final m in streamMessages) m.id};
  final pending = ref.watch(pendingMessagesProvider(orderId));
  final pendingOnly = pending
      .where((p) => p.firestoreId == null || !streamIds.contains(p.firestoreId))
      .toList();
  // Chronological: oldest first. olderMessages are desc (oldest batch first), streamMessages desc (newest first).
  final fromFirestore = [
    ...pagination.olderMessages.reversed,
    ...streamMessages.reversed,
  ];
  const _hiddenTypes = {
    'payment_request',
    'payment_confirmed',
    'shipping_update',
  };
  final filteredFirestore = fromFirestore
      .whereType<ChatMessage>()
      .where((m) => !_hiddenTypes.contains(m.messageType))
      .toList();
  final combined = <Object>[...filteredFirestore, ...pendingOnly];
  combined.sort((a, b) {
    final at = a is ChatMessage ? a.sentAt : (a as PendingMessage).sentAt;
    final bt = b is ChatMessage ? b.sentAt : (b as PendingMessage).sentAt;
    return at.compareTo(bt);
  });
  return combined;
});

/// Last document of the first page (for load more). Null when no messages.
final chatFirstPageLastDocProvider = Provider.family<DocumentSnapshot?, String>(
  (ref, orderId) {
    return ref.watch(messagesProvider(orderId)).valueOrNull?.lastDocument;
  },
);

Future<void> sendTextMessageForOrder(WidgetRef ref, String orderId) async {
  final body = ref.read(messageInputProvider).trim();
  if (body.isEmpty) return;
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  final reply = ref.read(replyStateProvider(orderId).notifier).state;
  final tempId = 'text_${DateTime.now().millisecondsSinceEpoch}';
  final sentAt = DateTime.now();
  ref.read(pendingMessagesProvider(orderId).notifier).state = [
    ...ref.read(pendingMessagesProvider(orderId)),
    PendingMessage(
      tempId: tempId,
      messageType: 'text',
      body: body,
      sentAt: sentAt,
    ),
  ];
  ref.read(messageInputProvider.notifier).state = '';
  ref.read(replyStateProvider(orderId).notifier).state = null;

  try {
    final docId = await ref
        .read(chatDataSourceProvider)
        .sendTextMessage(
          orderId: orderId,
          senderId: user,
          senderRole: 'buyer',
          body: body,
          replyToMessageId: reply?.messageId,
        );
    final list = ref.read(pendingMessagesProvider(orderId));
    final idx = list.indexWhere((p) => p.tempId == tempId);
    if (idx >= 0) {
      final updated = list[idx].copyWith(status: 'sent', firestoreId: docId);
      ref.read(pendingMessagesProvider(orderId).notifier).state = [
        ...list.sublist(0, idx),
        updated,
        ...list.sublist(idx + 1),
      ];
    }
  } catch (_) {
    ref.read(pendingMessagesProvider(orderId).notifier).state = ref
        .read(pendingMessagesProvider(orderId))
        .where((p) => p.tempId != tempId)
        .toList();
  }
}

Future<void> sendSelectedImagesForOrder(WidgetRef ref, String orderId) async {
  final images = ref.read(pendingSelectedImagesProvider(orderId));
  if (images.isEmpty) return;
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  ref.read(pendingSelectedImagesProvider(orderId).notifier).state = [];

  final reply = ref.read(replyStateProvider(orderId).notifier).state;
  final ds = ref.read(chatDataSourceProvider);

  for (final path in images) {
    if (path.isEmpty) continue;
    final tempId = 'img_${DateTime.now().millisecondsSinceEpoch}_$path';
    final sentAt = DateTime.now();
    ref.read(pendingMessagesProvider(orderId).notifier).state = [
      ...ref.read(pendingMessagesProvider(orderId)),
      PendingMessage(
        tempId: tempId,
        messageType: 'image',
        localPath: path,
        sentAt: sentAt,
      ),
    ];

    try {
      final compressed = await _compressImage(path);
      void onProgress(double p) {
        final list = ref.read(pendingMessagesProvider(orderId));
        final idx = list.indexWhere((e) => e.tempId == tempId);
        if (idx >= 0) {
          final updated = list[idx].copyWith(progress: p);
          ref.read(pendingMessagesProvider(orderId).notifier).state = [
            ...list.sublist(0, idx),
            updated,
            ...list.sublist(idx + 1),
          ];
        }
      }

      final docId = await ds.sendImageMessage(
        orderId: orderId,
        senderId: user,
        senderRole: 'buyer',
        fileOrBytes: compressed ?? File(path),
        replyToMessageId: reply?.messageId,
        onProgress: onProgress,
      );
      final list = ref.read(pendingMessagesProvider(orderId));
      final idx = list.indexWhere((p) => p.tempId == tempId);
      if (idx >= 0) {
        final updated = list[idx].copyWith(
          status: 'sent',
          firestoreId: docId,
          progress: 1.0,
        );
        ref.read(pendingMessagesProvider(orderId).notifier).state = [
          ...list.sublist(0, idx),
          updated,
          ...list.sublist(idx + 1),
        ];
      }
    } catch (_) {
      ref.read(pendingMessagesProvider(orderId).notifier).state = ref
          .read(pendingMessagesProvider(orderId))
          .where((p) => p.tempId != tempId)
          .toList();
    }
  }
  ref.read(replyStateProvider(orderId).notifier).state = null;
}

Future<List<int>?> _compressImage(String path) async {
  try {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: 800,
      minHeight: 800,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    return result;
  } catch (_) {
    return null;
  }
}

/// Call this after picking images to add their paths to pending selection.
void addPendingImagePaths(WidgetRef ref, String orderId, List<String> paths) {
  final current = ref.read(pendingSelectedImagesProvider(orderId));
  final remaining = 5 - current.length;
  if (remaining <= 0) return;
  final toAdd = paths.take(remaining).toList();
  ref.read(pendingSelectedImagesProvider(orderId).notifier).state = [
    ...current,
    ...toAdd,
  ];
}

Future<void> sendImageForOrder(WidgetRef ref, String orderId) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result == null || result.files.isEmpty) return;
  final path = result.files.first.path;
  if (path == null || path.isEmpty) return;
  final images = ref.read(pendingSelectedImagesProvider(orderId));
  if (images.length >= 5) return;
  ref.read(pendingSelectedImagesProvider(orderId).notifier).state = [
    ...images,
    path,
  ];
}

Future<void> removePendingImage(
  WidgetRef ref,
  String orderId,
  int index,
) async {
  final list = ref.read(pendingSelectedImagesProvider(orderId));
  if (index < 0 || index >= list.length) return;
  ref.read(pendingSelectedImagesProvider(orderId).notifier).state = [
    ...list.sublist(0, index),
    ...list.sublist(index + 1),
  ];
}

Future<void> sendVoiceNoteForOrder(
  WidgetRef ref,
  String orderId, {
  required File file,
  required int durationSecs,
}) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  final reply = ref.read(replyStateProvider(orderId).notifier).state;
  await ref
      .read(chatDataSourceProvider)
      .sendVoiceNote(
        orderId: orderId,
        senderId: user,
        senderRole: 'buyer',
        file: file,
        durationSecs: durationSecs,
        replyToMessageId: reply?.messageId,
      );
  ref.read(replyStateProvider(orderId).notifier).state = null;
}

Future<void> sendFileForOrder(WidgetRef ref, String orderId) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) return;
  final f = result.files.first;
  final path = f.path;
  if (path == null) return;
  final file = File(path);
  final fileName = f.name;
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  final reply = ref.read(replyStateProvider(orderId).notifier).state;
  await ref
      .read(chatDataSourceProvider)
      .sendFileMessage(
        orderId: orderId,
        senderId: user,
        senderRole: 'buyer',
        file: file,
        fileName: fileName,
        replyToMessageId: reply?.messageId,
      );
  ref.read(replyStateProvider(orderId).notifier).state = null;
}

/// Video: single source of truth — Firestore only. No local pending; stream shows pending doc with progress.
Future<void> sendVideoForOrder(WidgetRef ref, String orderId) async {
  final videoPath = ref.read(pendingVideoPathProvider(orderId).notifier).state;
  if (videoPath == null) return;
  ref.read(pendingVideoPathProvider(orderId).notifier).state = null;

  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  final reply = ref.read(replyStateProvider(orderId).notifier).state;

  try {
    final compressedPath = await _compressVideo(videoPath);
    final file = File(compressedPath ?? videoPath);
    final pathForThumbnail = compressedPath ?? videoPath;

    await ref
        .read(chatDataSourceProvider)
        .sendVideoMessage(
          orderId: orderId,
          senderId: user,
          senderRole: 'buyer',
          file: file,
          videoPath: pathForThumbnail,
          replyToMessageId: reply?.messageId,
        );
  } catch (_) {
    // Optionally show snackbar
  }
  ref.read(replyStateProvider(orderId).notifier).state = null;
}

Future<String?> _compressVideo(String path) async {
  try {
    final info = await VideoCompress.compressVideo(
      path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );
    return info?.path;
  } catch (_) {
    return null;
  }
}

Future<void> toggleReactionForMessage(
  WidgetRef ref, {
  required String orderId,
  required String messageId,
  required String emoji,
}) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  await ref
      .read(chatDataSourceProvider)
      .upsertReaction(
        orderId: orderId,
        messageId: messageId,
        userId: user,
        emoji: emoji,
      );
}

Future<void> markChatAsRead(WidgetRef ref, String orderId) async {
  await ref.read(chatDataSourceProvider).markMessagesRead(orderId, 'buyer');
}

Future<void> deleteMessageForOrder(
  WidgetRef ref, {
  required String orderId,
  required String messageId,
}) async {
  await ref.read(chatDataSourceProvider).deleteMessage(messageId: messageId);
}
