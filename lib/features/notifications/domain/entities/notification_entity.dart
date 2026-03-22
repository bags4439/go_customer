/// Single notification from Firestore notifications collection.
class NotificationEntity {
  final String id;
  final String userId;
  final String? orderId;
  final String type;
  final String title;
  final String body;
  final String? actionUrl;
  final bool isRead;
  final DateTime sentAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.title,
    required this.body,
    this.actionUrl,
    required this.isRead,
    required this.sentAt,
  });
}
