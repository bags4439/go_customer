import '../../domain/entities/notification_entity.dart';

/// One item in the flat list: either a section header or a notification entry.
abstract class NotificationListItem {
  const NotificationListItem();
}

class NotificationListItemSection extends NotificationListItem {
  final String label; // 'Today' | 'Yesterday' | 'Earlier'
  const NotificationListItemSection(this.label);
}

class NotificationListItemEntry extends NotificationListItem {
  final NotificationEntity notification;
  const NotificationListItemEntry(this.notification);
}
