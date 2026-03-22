import 'package:intl/intl.dart';

/// Format sentAt for notification list. Uses intl — never manual string building.
String formatNotificationTimestamp(DateTime sentAt) {
  final now = DateTime.now();
  final diff = now.difference(sentAt);

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  final sentDate = DateTime(sentAt.year, sentAt.month, sentAt.day);
  final yesterday = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 1));
  if (sentDate == yesterday) {
    return 'Yesterday ${DateFormat('h:mm a').format(sentAt)}';
  }
  if (sentAt.year == now.year) {
    return DateFormat('d MMM, h:mm a').format(sentAt);
  }
  return DateFormat('d MMM yyyy').format(sentAt);
}
