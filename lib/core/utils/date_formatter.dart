import 'package:intl/intl.dart';

/// Relative and absolute date formatting for the app.
class DateFormatter {
  DateFormatter._();

  /// Relative label for completed / activity timestamps (e.g. "2h ago").
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.isNegative) {
      return DateFormat('d MMM, h:mm a').format(dateTime);
    }
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (dateTime.year == now.year) {
      return DateFormat('d MMM, h:mm a').format(dateTime);
    }
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  static String formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('d MMM yyyy').format(d);
  }

  /// Short date for vehicle cards (e.g. "28 Mar 2026").
  static String format(DateTime? d) => formatDate(d);

  static String formatDateTime(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('d MMM yyyy, h:mm a').format(d);
  }
}
