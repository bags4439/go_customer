import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/chat_message.dart';

/// First page stream result: messages (descending) + last doc for pagination.
class MessagesPageResult {
  final List<ChatMessage> messages;
  final DocumentSnapshot? lastDocument;

  const MessagesPageResult(this.messages, this.lastDocument);
}

ChatMessage _messageFromDoc(DocumentSnapshot doc, String orderId) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  final sentRaw = data['sentAt'];
  DateTime sentAt = DateTime.now();
  if (sentRaw is Timestamp) sentAt = sentRaw.toDate();
  return ChatMessage(
    id: doc.id,
    orderId: data['orderId'] as String? ?? orderId,
    senderId: data['senderId'] as String? ?? '',
    senderRole: data['senderRole'] as String? ?? 'buyer',
    messageType: data['messageType'] as String? ?? 'text',
    body: data['body'] as String?,
    mediaUrl: data['mediaUrl'] as String?,
    thumbnailUrl: data['thumbnailUrl'] as String?,
    mediaDurationSecs: data['mediaDurationSecs'] as int?,
    mediaFileName: data['mediaFileName'] as String?,
    vehicleOptionId: data['vehicleOptionId'] as String?,
    paymentRequestId: data['paymentRequestId'] as String?,
    replyToMessageId: data['replyToMessageId'] as String?,
    status: data['status'] as String?,
    uploadProgress: (data['uploadProgress'] as num?)?.toDouble(),
    isRead: data['isRead'] as bool? ?? false,
    isDeleted: data['isDeleted'] as bool? ?? false,
    sentAt: sentAt,
  );
}

class ChatFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const ChatFirestoreDataSource(this._firestore, this._storage);

  /// First page: most recent 30 messages (descending). lastDocument is the oldest doc for loadMore.
  Stream<MessagesPageResult> watchMessages(String orderId) {
    return _firestore
        .collection(FirestoreCollections.messages)
        .where('orderId', isEqualTo: orderId)
        .orderBy('sentAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          final messages = docs.map((d) => _messageFromDoc(d, orderId)).toList();
          final lastDoc = docs.isNotEmpty ? docs.last : null;
          return MessagesPageResult(messages, lastDoc);
        });
  }

  /// Load next 30 older messages. Returns messages and the last doc of this batch (cursor for next load).
  Future<(List<ChatMessage>, DocumentSnapshot?)> loadMoreMessages(
    String orderId,
    DocumentSnapshot lastDocument,
  ) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.messages)
        .where('orderId', isEqualTo: orderId)
        .orderBy('sentAt', descending: true)
        .startAfterDocument(lastDocument)
        .limit(30)
        .get();
    final docs = snapshot.docs;
    final messages = docs.map((d) => _messageFromDoc(d, orderId)).toList();
    final nextLastDoc = docs.isNotEmpty ? docs.last : null;
    return (messages, nextLastDoc);
  }

  Future<String> sendTextMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required String body,
    String? replyToMessageId,
  }) async {
    final data = <String, dynamic>{
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': 'text',
      'body': body,
      'isRead': false,
      'isDeleted': false,
      'sentAt': FieldValue.serverTimestamp(),
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      data['replyToMessageId'] = replyToMessageId;
    }
    final docRef =
        await _firestore.collection(FirestoreCollections.messages).add(data);
    return docRef.id;
  }

  Future<String> sendImageMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required dynamic fileOrBytes,
    String? replyToMessageId,
    void Function(double progress)? onProgress,
  }) async {
    final storageRef = _storage.ref().child(
        'messages/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg');

    UploadTask uploadTask;
    if (fileOrBytes is File) {
      uploadTask = storageRef.putFile(fileOrBytes);
    } else {
      final bytes = fileOrBytes is Uint8List
          ? fileOrBytes
          : Uint8List.fromList(fileOrBytes as List<int>);
      uploadTask = storageRef.putData(bytes);
    }

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes;
        if (total > 0) {
          onProgress(snapshot.bytesTransferred / total);
        }
      });
    }
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    final data = <String, dynamic>{
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': 'image',
      'mediaUrl': url,
      'isRead': false,
      'isDeleted': false,
      'sentAt': FieldValue.serverTimestamp(),
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      data['replyToMessageId'] = replyToMessageId;
    }
    final docRef =
        await _firestore.collection(FirestoreCollections.messages).add(data);
    return docRef.id;
  }

  /// Single source of truth: create Firestore doc with status 'pending', then upload thumbnail + video, then update to 'sent'.
  Future<String> sendVideoMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required File file,
    required String videoPath,
    String? replyToMessageId,
  }) async {
    final messagesRef =
        _firestore.collection(FirestoreCollections.messages);
    final data = <String, dynamic>{
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': 'video',
      'status': 'pending',
      'uploadProgress': 0.0,
      'isRead': false,
      'isDeleted': false,
      'sentAt': FieldValue.serverTimestamp(),
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      data['replyToMessageId'] = replyToMessageId;
    }
    final docRef = await messagesRef.add(data);
    final messageId = docRef.id;

    int? durationSecs;
    try {
      final info = await VideoCompress.getMediaInfo(videoPath);
      if (info.duration != null) {
        durationSecs = (info.duration! / 1000).round();
      }
    } catch (_) {}

    // Generate thumbnail before upload (first frame).
    Uint8List? thumbBytes;
    try {
      thumbBytes = await VideoCompress.getByteThumbnail(
        videoPath,
        quality: 75,
        position: -1,
      );
    } catch (_) {}

    if (thumbBytes != null && thumbBytes.isNotEmpty) {
      final thumbRef = _storage
          .ref()
          .child('messages/$orderId/thumbnails/$messageId.jpg');
      await thumbRef.putData(thumbBytes);
      final thumbUrl = await thumbRef.getDownloadURL();
      await docRef.update({'thumbnailUrl': thumbUrl});
    }

    // Upload video and update progress on the doc.
    final storageRef =
        _storage.ref().child('messages/$orderId/videos/$messageId.mp4');
    final uploadTask = storageRef.putFile(file);
    uploadTask.snapshotEvents.listen((snapshot) async {
      final total = snapshot.totalBytes;
      if (total > 0) {
        final p = snapshot.bytesTransferred / total;
        await docRef.update({'uploadProgress': p});
      }
    });
    await uploadTask;
    final url = await storageRef.getDownloadURL();

    final updateData = <String, dynamic>{
      'mediaUrl': url,
      'status': 'sent',
      'uploadProgress': FieldValue.delete(),
    };
    if (durationSecs != null) updateData['mediaDurationSecs'] = durationSecs;
    await docRef.update(updateData);

    return messageId;
  }

  Future<String> sendVoiceNote({
    required String orderId,
    required String senderId,
    required String senderRole,
    required File file,
    required int durationSecs,
    String? replyToMessageId,
  }) async {
    final ref = _storage
        .ref()
        .child('messages/$orderId/${DateTime.now().millisecondsSinceEpoch}.m4a');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final data = <String, dynamic>{
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': 'voice_note',
      'mediaUrl': url,
      'mediaDurationSecs': durationSecs,
      'isRead': false,
      'isDeleted': false,
      'sentAt': FieldValue.serverTimestamp(),
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      data['replyToMessageId'] = replyToMessageId;
    }
    final docRef =
        await _firestore.collection(FirestoreCollections.messages).add(data);
    return docRef.id;
  }

  Future<void> markMessagesRead(String orderId, String currentUserRole) async {
    final query = await _firestore
        .collection(FirestoreCollections.messages)
        .where('orderId', isEqualTo: orderId)
        .where('senderRole', isNotEqualTo: currentUserRole)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<String> sendFileMessage({
    required String orderId,
    required String senderId,
    required String senderRole,
    required File file,
    required String fileName,
    String? replyToMessageId,
  }) async {
    final ext = fileName.split('.').last;
    final ref = _storage.ref().child(
        'messages/$orderId/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final data = <String, dynamic>{
      'orderId': orderId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': 'file',
      'mediaUrl': url,
      'mediaFileName': fileName,
      'isRead': false,
      'isDeleted': false,
      'sentAt': FieldValue.serverTimestamp(),
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      data['replyToMessageId'] = replyToMessageId;
    }
    final docRef =
        await _firestore.collection(FirestoreCollections.messages).add(data);
    return docRef.id;
  }

  Future<void> upsertReaction({
    required String orderId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final ref = _firestore
        .collection(FirestoreCollections.messageReactions)
        .doc('$messageId-$userId');
    final snapshot = await ref.get();
    if (snapshot.exists && (snapshot.data()?['emoji'] == emoji)) {
      await ref.delete();
    } else {
      await ref.set({
        'orderId': orderId,
        'messageId': messageId,
        'userId': userId,
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Stream of messageId -> list of emoji strings for reactions in this order.
  Stream<Map<String, List<String>>> watchMessageReactions(String orderId) {
    return _firestore
        .collection(FirestoreCollections.messageReactions)
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snapshot) {
      final map = <String, List<String>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final msgId = data['messageId'] as String?;
        final emoji = data['emoji'] as String?;
        if (msgId != null && emoji != null) {
          map.putIfAbsent(msgId, () => []).add(emoji);
        }
      }
      return map;
    });
  }

  /// Stream of agent typing status for this order.
  /// Agent app writes to orders/{orderId}/typing/agent { isTyping, updatedAt }.
  Stream<bool> watchAgentTyping(String orderId) {
    return _firestore
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .collection('typing')
        .doc('agent')
        .snapshots()
        .map((doc) => (doc.data()?['isTyping'] as bool?) ?? false);
  }
}

