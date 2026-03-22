class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderRole; // buyer / agent / system
  final String messageType;
  final String? body;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? mediaDurationSecs;
  final String? mediaFileName;
  final String? vehicleOptionId;
  final String? paymentRequestId;
  final String? replyToMessageId;
  final String? status; // 'pending' | 'sent' (null treated as sent)
  final double? uploadProgress; // 0..1 while uploading
  final bool isRead;
  final bool isDeleted;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderRole,
    required this.messageType,
    this.body,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaDurationSecs,
    this.mediaFileName,
    this.vehicleOptionId,
    this.paymentRequestId,
    this.replyToMessageId,
    this.status,
    this.uploadProgress,
    required this.isRead,
    required this.isDeleted,
    required this.sentAt,
  });
}

