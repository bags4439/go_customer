import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_message_widgets.dart';

const _kReceivedBg = Color(0xFFFFFFFF);

/// Date divider label for a given date (Today, Yesterday, or formatted date).
String _dateDividerLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  if (d == yesterday) return 'Yesterday';
  return '${date.day}/${date.month}/${date.year}';
}

/// Groups messages with date dividers. Returns a list of items: either
/// _DateDivider or _MessageItem.
sealed class _ListItem {}

class _DateDivider implements _ListItem {
  final String label;
  _DateDivider(this.label);
}

class _MessageItem implements _ListItem {
  final ChatMessage message;
  _MessageItem(this.message);
}

class _PendingItem implements _ListItem {
  final PendingMessage pending;
  _PendingItem(this.pending);
}

List<_ListItem> _messagesWithDateDividersFromDisplay(
  List<Object> displayMessages,
  String userId,
) {
  final result = <_ListItem>[];
  DateTime? lastDate;
  for (final obj in displayMessages) {
    DateTime sentAt;
    if (obj is ChatMessage) {
      sentAt = obj.sentAt;
      final d = DateTime(sentAt.year, sentAt.month, sentAt.day);
      if (lastDate != d) {
        lastDate = d;
        result.add(_DateDivider(_dateDividerLabel(sentAt)));
      }
      result.add(_MessageItem(obj));
    } else {
      final p = obj as PendingMessage;
      sentAt = p.sentAt;
      final d = DateTime(sentAt.year, sentAt.month, sentAt.day);
      if (lastDate != d) {
        lastDate = d;
        result.add(_DateDivider(_dateDividerLabel(sentAt)));
      }
      result.add(_PendingItem(p));
    }
  }
  return result;
}

bool _isFirstInGroup(
  List<_ListItem> items,
  int index,
  String senderId,
  DateTime sentAt,
) {
  if (index == 0) return true;
  final prev = items[index - 1];
  if (prev is _DateDivider) return true;
  if (prev is _MessageItem) {
    if (prev.message.senderId != senderId) {
      return true;
    }
    if (sentAt.difference(prev.message.sentAt).inMinutes > 2) return true;
    return false;
  }
  return true;
}

bool _isLastInGroup(
  List<_ListItem> items,
  int index,
  String senderId,
  DateTime sentAt,
) {
  if (index == items.length - 1) return true;
  final next = items[index + 1];
  if (next is _DateDivider) return true;
  if (next is _MessageItem) {
    if (next.message.senderId != senderId) {
      return true;
    }
    if (next.message.sentAt.difference(sentAt).inMinutes > 2) return true;
    return false;
  }
  if (next is _PendingItem) return true;
  return false;
}

class OrderChatTab extends ConsumerStatefulWidget {
  final String orderId;

  const OrderChatTab({super.key, required this.orderId});

  @override
  ConsumerState<OrderChatTab> createState() => _OrderChatTabState();
}

class _OrderChatTabState extends ConsumerState<OrderChatTab> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markChatAsRead(ref, widget.orderId);
    });
  }

  @override
  void deactivate() {
    FocusScope.of(context).unfocus();
    super.deactivate();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 0) {
      final pagination = ref.read(
        chatPaginationNotifierProvider(widget.orderId),
      );
      if (pagination.isLoadingMore || !pagination.hasMoreMessages) return;
      final lastDoc =
          pagination.lastDocumentForLoadMore ??
          ref.read(chatFirstPageLastDocProvider(widget.orderId));
      if (lastDoc != null) {
        ref
            .read(chatPaginationNotifierProvider(widget.orderId).notifier)
            .loadMore(lastDoc);
      }
    }
  }

  void _openFullScreenVideo(BuildContext context, String mediaUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _FullScreenVideoPage(mediaUrl: mediaUrl),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final displayMessages = ref.watch(chatDisplayMessagesProvider(orderId));
    final reactionsAsync = ref.watch(messageReactionsProvider(orderId));
    final typingAsync = ref.watch(agentTypingProvider(orderId));
    final input = ref.watch(messageInputProvider);
    final replyState = ref.watch(replyStateProvider(orderId));

    ref.listen<List<Object>>(chatDisplayMessagesProvider(orderId), (
      prev,
      next,
    ) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          typingAsync.when(
            data: (isTyping) {
              if (!isTyping) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
                color: const Color(0xFFF2F1ED),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _kReceivedBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8E7E2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        size: 16,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Agent is typing…',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF999999),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  final focus = FocusManager.instance.primaryFocus;
                  if (focus != null && focus.hasFocus) {
                    focus.unfocus();
                  }
                }
                return false;
              },
              child: ColoredBox(
                color: const Color(0xFFF2F1ED),
                child: displayMessages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE0DFD8),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 26,
                                  color: Color(0xFFBBBBBB),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your conversation\nis private',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A18),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Only you and your agent\n'
                                'can see these messages.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  color: const Color(0xFF999999),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                          final userId = ref.watch(authStateProvider).value;
                          final reactions = reactionsAsync.valueOrNull ?? {};
                          final pageResult = ref
                              .watch(messagesProvider(orderId))
                              .valueOrNull;
                          final streamMessages = pageResult?.messages ?? [];
                          final idToBody = {
                            for (final m in streamMessages)
                              m.id: (m.body ?? ''),
                          };
                          final pagination = ref.watch(
                            chatPaginationNotifierProvider(orderId),
                          );
                          for (final m in pagination.olderMessages) {
                            idToBody[m.id] = m.body ?? '';
                          }
                          final items = _messagesWithDateDividersFromDisplay(
                            displayMessages,
                            userId ?? '',
                          );

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                if (pagination.isLoadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (!pagination.hasMoreMessages &&
                                    items.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Beginning of conversation',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              final itemIndex = index - 1;
                              final item = items[itemIndex];
                              if (item is _DateDivider) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE0DFD8),
                                          width: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        item.label,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF888888),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (item is _MessageItem) {
                                final msg = item.message;
                                final isMe = msg.senderId == userId;
                                final replyToBody = msg.replyToMessageId != null
                                    ? idToBody[msg.replyToMessageId]
                                    : null;
                                final messageReactions =
                                    reactions[msg.id] ?? const [];

                                final isFirst = _isFirstInGroup(
                                  items,
                                  itemIndex,
                                  msg.senderId,
                                  msg.sentAt,
                                );
                                final isLast = _isLastInGroup(
                                  items,
                                  itemIndex,
                                  msg.senderId,
                                  msg.sentAt,
                                );

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: GestureDetector(
                                    onLongPress: () async {
                                      if (msg.isDeleted) return;
                                      final result =
                                          await showModalBottomSheet<String>(
                                            context: context,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            builder: (ctx) =>
                                                _MessageActionSheet(
                                                  orderId: orderId,
                                                  messageId: msg.id,
                                                  messageBody: msg.body,
                                                  isMe: isMe,
                                                ),
                                          );
                                      if (!context.mounted) return;
                                      if (result == 'reply') {
                                        ref
                                            .read(
                                              replyStateProvider(
                                                orderId,
                                              ).notifier,
                                            )
                                            .state = ReplyState(
                                          messageId: msg.id,
                                          body: msg.body,
                                        );
                                      } else if (result == 'delete') {
                                        final confirmed =
                                            await showModalBottomSheet<bool>(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                  ),
                                              builder: (ctx) =>
                                                  _DeleteConfirmSheet(
                                                    onConfirm: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(true),
                                                    onCancel: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(false),
                                                  ),
                                            );
                                        if (confirmed == true) {
                                          await deleteMessageForOrder(
                                            ref,
                                            orderId: orderId,
                                            messageId: msg.id,
                                          );
                                        }
                                      } else if (result != null) {
                                        await toggleReactionForMessage(
                                          ref,
                                          orderId: orderId,
                                          messageId: msg.id,
                                          emoji: result,
                                        );
                                      }
                                    },
                                    child: ChatMessageBubble(
                                      message: msg,
                                      isMe: isMe,
                                      orderId: orderId,
                                      reactions: messageReactions,
                                      replyToBody: replyToBody,
                                      onVideoTap:
                                          msg.messageType == 'video' &&
                                              msg.mediaUrl != null
                                          ? () => _openFullScreenVideo(
                                              context,
                                              msg.mediaUrl!,
                                            )
                                          : null,
                                      isFirstInGroup: isFirst,
                                      isLastInGroup: isLast,
                                    ),
                                  ),
                                );
                              }
                              final pending = (item as _PendingItem).pending;
                              return Align(
                                alignment: Alignment.centerRight,
                                child: ChatMessageBubble.pending(
                                  pending: pending,
                                  isMe: true,
                                  orderId: orderId,
                                  onVideoTap: () {},
                                  isFirstInGroup: true,
                                  isLastInGroup: true,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: replyState != null
                ? _ReplyPreviewBar(
                    replyBody: replyState.body ?? '…',
                    onCancel: () =>
                        ref.read(replyStateProvider(orderId).notifier).state =
                            null,
                  )
                : const SizedBox.shrink(),
          ),
          _ImagePreviewStrip(orderId: orderId),
          _VideoPreviewBar(orderId: orderId),
          _InputBar(orderId: orderId, text: input),
        ],
      ),
    );
  }
}

class _ImagePreviewStrip extends ConsumerWidget {
  final String orderId;

  const _ImagePreviewStrip({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(pendingSelectedImagesProvider(orderId));
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEDE8), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Text(
                  '${images.length} '
                  '${images.length == 1 ? 'photo' : 'photos'} selected',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      ref
                              .read(
                                pendingSelectedImagesProvider(orderId).notifier,
                              )
                              .state =
                          [],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFE9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                final path = images[index];
                return _ImageThumb(
                  path: path,
                  index: index,
                  orderId: orderId,
                  allImages: images,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => sendSelectedImagesForOrder(ref, orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF378ADD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 17),
                    const SizedBox(width: 8),
                    Text(
                      'Send ${images.length} '
                      '${images.length == 1 ? 'photo' : 'photos'}',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String path;
  final int index;
  final String orderId;
  final List<String> allImages;

  const _ImageThumb({
    required this.path,
    required this.index,
    required this.orderId,
    required this.allImages,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPreview(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: Consumer(
              builder: (ctx, ref, _) => GestureDetector(
                onTap: () => removePendingImage(ref, orderId, index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => _ImagePreviewScreen(
          images: allImages,
          initialIndex: index,
          orderId: orderId,
        ),
      ),
    );
  }
}

class _ImagePreviewScreen extends ConsumerStatefulWidget {
  /// Snapshot at navigation time; [build] uses live provider list so deletes sync.
  final List<String> images;
  final int initialIndex;
  final String orderId;

  const _ImagePreviewScreen({
    required this.images,
    required this.initialIndex,
    required this.orderId,
  });

  @override
  ConsumerState<_ImagePreviewScreen> createState() =>
      _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<_ImagePreviewScreen> {
  late final PageController _pageCtrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final images = ref.read(pendingSelectedImagesProvider(widget.orderId));
    final safeInitial = images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, images.length - 1);
    _currentIndex = safeInitial;
    _pageCtrl = PageController(initialPage: safeInitial);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDeletePressed() async {
    final before = ref.read(pendingSelectedImagesProvider(widget.orderId));
    if (before.isEmpty) return;
    if (before.length == 1) {
      await removePendingImage(ref, widget.orderId, _currentIndex);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await removePendingImage(ref, widget.orderId, _currentIndex);
    if (!mounted) return;
    final after = ref.read(pendingSelectedImagesProvider(widget.orderId));
    if (after.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    if (_currentIndex >= after.length) {
      setState(() => _currentIndex = after.length - 1);
      _pageCtrl.jumpToPage(_currentIndex);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(pendingSelectedImagesProvider(widget.orderId));
    if (images.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.file(File(images[i]), fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                MediaQuery.of(context).padding.top + 8,
                8,
                8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} of ${images.length}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _onDeletePressed,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentIndex ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoPreviewBar extends ConsumerWidget {
  final String orderId;

  const _VideoPreviewBar({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPath = ref.watch(pendingVideoPathProvider(orderId));
    if (videoPath == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFFF5F4F0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 60,
              child: _VideoThumbnail(path: videoPath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Video ready',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => sendVideoForOrder(ref, orderId),
            child: const Text('Send'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                ref.read(pendingVideoPathProvider(orderId).notifier).state =
                    null,
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String path;

  const _VideoThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(File(snapshot.data!), fit: BoxFit.cover);
        }
        return const ColoredBox(
          color: Colors.black26,
          child: Center(child: Icon(Icons.videocam)),
        );
      },
    );
  }

  Future<String?> _getThumbnail() async {
    try {
      final file = await VideoCompress.getFileThumbnail(path);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

class _InputBar extends ConsumerStatefulWidget {
  final String orderId;
  final String text;

  const _InputBar({required this.orderId, required this.text});

  @override
  ConsumerState<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<_InputBar> {
  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _recordingStopwatch = Stopwatch();
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(_InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text.isEmpty && oldWidget.text.isNotEmpty) {
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final isRecording = ref.read(isRecordingProvider);
    if (isRecording) {
      ref.read(isRecordingProvider.notifier).state = false;
      try {
        final path = await _recorder.stop();
        if (path != null) {
          final durationSecs = _recordingStopwatch.elapsed.inSeconds.clamp(
            1,
            999,
          );
          _recordingStopwatch.stop();
          _recordingStopwatch.reset();
          final file = File(path);
          if (file.existsSync()) {
            await sendVoiceNoteForOrder(
              ref,
              widget.orderId,
              file: file,
              durationSecs: durationSecs,
            );
          }
        }
      } catch (_) {}
      return;
    }

    final dir = Directory.systemTemp;
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }
    try {
      await _recorder.start(const RecordConfig(bitRate: 64000), path: path);
      _recordingStopwatch.start();
      ref.read(isRecordingProvider.notifier).state = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recording failed: $e')));
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final xFiles = await picker.pickMultiImage(limit: 5);
    if (xFiles.isEmpty) return;
    final paths = xFiles
        .map((x) => x.path)
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .toList();
    if (paths.isEmpty) return;
    addPendingImagePaths(ref, widget.orderId, paths);
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null) return;
    addPendingImagePaths(ref, widget.orderId, [xFile.path]);
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 10),
    );
    if (video != null && video.path.isNotEmpty) {
      ref.read(pendingVideoPathProvider(widget.orderId).notifier).state =
          video.path;
    }
  }

  void _showAttachMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 3.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDD8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AttachTile(
                      icon: Icons.photo_library_outlined,
                      label: 'Photos',
                      color: const Color(0xFF5C85DE),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImages();
                      },
                    ),
                    _AttachTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      color: const Color(0xFF1D9E75),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImageFromCamera();
                      },
                    ),
                    _AttachTile(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      color: const Color(0xFFE24B4A),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickVideo();
                      },
                    ),
                    _AttachTile(
                      icon: Icons.insert_drive_file_outlined,
                      label: 'File',
                      color: const Color(0xFFBA7517),
                      onTap: () {
                        Navigator.pop(ctx);
                        sendFileForOrder(ref, widget.orderId);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);
    final inputText = ref.watch(messageInputProvider);
    final hasText = inputText.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEDE8), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: isRecording ? null : _showAttachMenu,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0EFE9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: isRecording
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF378ADD),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(
                    minHeight: 42,
                    maxHeight: 130,
                  ),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? const Color(0xFFFFF0EF)
                        : const Color(0xFFF5F4F0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isRecording
                          ? const Color(0xFFF5C5C2)
                          : const Color(0xFFE8E7E2),
                      width: 0.5,
                    ),
                  ),
                  child: isRecording
                      ? const _RecordingIndicator()
                      : TextField(
                          controller: _textController,
                          minLines: 1,
                          maxLines: 5,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: const Color(0xFF1A1A18),
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: const Color(0xFFBBBBBB),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                          ),
                          onChanged: (v) =>
                              ref.read(messageInputProvider.notifier).state = v,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: hasText && !isRecording
                      ? () => sendTextMessageForOrder(ref, widget.orderId)
                      : _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasText || isRecording
                          ? const Color(0xFF378ADD)
                          : const Color(0xFFF0EFE9),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        isRecording
                            ? Icons.stop_rounded
                            : hasText
                            ? Icons.send_rounded
                            : Icons.mic_none_rounded,
                        key: ValueKey<String>(
                          isRecording
                              ? 'stop'
                              : hasText
                              ? 'send'
                              : 'mic',
                        ),
                        size: 17,
                        color: hasText || isRecording
                            ? Colors.white
                            : const Color(0xFF378ADD),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: Reply + reaction emojis. Pops with 'reply', 'delete', or emoji.
class _MessageActionSheet extends StatelessWidget {
  final String orderId;
  final String messageId;
  final String? messageBody;
  final bool isMe;

  const _MessageActionSheet({
    required this.orderId,
    required this.messageId,
    this.messageBody,
    required this.isMe,
  });

  static const List<String> _emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3.5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDD8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _emojis
                    .map(
                      (e) => GestureDetector(
                        onTap: () => Navigator.of(context).pop(e),
                        child: Text(e, style: const TextStyle(fontSize: 26)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: () => Navigator.of(context).pop('reply'),
            ),
            if (isMe) ...[
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: const Color(0xFFEEEDE8),
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete for everyone',
                color: const Color(0xFFE24B4A),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  final String mediaUrl;

  const _FullScreenVideoPage({required this.mediaUrl});

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
    );
    _videoController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF378ADD),
            handleColor: const Color(0xFF378ADD),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_chewieController != null)
            Center(child: Chewie(controller: _chewieController!)),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          FadeTransition(
            opacity: _fade,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE24B4A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Recording…',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFFE24B4A),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  final String replyBody;
  final VoidCallback onCancel;

  const _ReplyPreviewBar({required this.replyBody, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEDE8), width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF378ADD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to message',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF378ADD),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyBody,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    color: const Color(0xFF888888),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EFE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFF888888),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? const Color(0xFF1A1A18);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: fg,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteConfirmSheet({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3.5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDD8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFCEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE24B4A),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Delete message?',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A18),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This message will be deleted'
              ' for everyone in this'
              ' conversation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF888888),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE24B4A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Delete for everyone',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF888888),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
