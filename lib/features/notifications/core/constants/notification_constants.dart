/// All copy for notifications centre. No hardcoded strings in UI.
class NotificationConstants {
  NotificationConstants._();

  static const String appBarTitle = 'Notifications';
  static const String unreadSuffix = 'unread';
  static const String allCaughtUp = 'All caught up';
  static const String markAllRead = 'Mark all read';

  static const String filterAll = 'All';
  static const String filterPayments = 'Payments';
  static const String filterOrderUpdates = 'Order updates';
  static const String filterMessages = 'Messages';
  static const String filterAlerts = 'Alerts';

  static const String sectionToday = 'TODAY';
  static const String sectionYesterday = 'YESTERDAY';
  static const String sectionEarlier = 'EARLIER';

  static const String actionPayNow = 'Pay now →';
  static const String actionTrack = 'Track →';
  static const String actionClearance = 'Clearance →';
  static const String actionViewDetails = 'View details →';
  static const String actionVerifyNow = 'Verify now →';
  static const String actionViewMessage = 'View message →';
  static const String actionMeetAgent = 'Chat with your agent →';

  static const String emptyAllTitle = 'No notifications yet';
  static const String emptyAllBody =
      "You'll be notified about payments, order updates, and messages here.";

  static const String emptyPaymentsTitle = 'No payment notifications';
  static const String emptyPaymentsBody =
      'Payment requests from your agent will appear here.';

  static const String emptyOrderUpdatesTitle = 'No order updates yet';
  static const String emptyOrderUpdatesBody =
      'Bid results, shipping updates, and stage changes will appear here.';

  static const String emptyMessagesTitle = 'No messages yet';
  static const String emptyMessagesBody =
      'New messages from your agent will appear here.';

  static const String emptyAlertsTitle = 'No alerts';
  static const String emptyAlertsBody =
      'Important reminders and deadlines will appear here.';

  static const String errorTitle = 'Could not load notifications';
  static const String errorBody = 'Check your connection and try again.';
  static const String retry = 'Retry';

  static const String loadMoreError = 'Could not load more. Tap to retry.';
  static const String markAllReadError =
      'Could not mark all as read. Please try again.';
  static const String noMoreNotifications = 'No more notifications';

  static const String signInPrompt = 'Sign in to see notifications';
}
