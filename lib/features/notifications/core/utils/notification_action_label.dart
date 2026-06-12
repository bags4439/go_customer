import '../../core/constants/notification_constants.dart';

String? actionLabelForNotificationType(String type) {
  switch (type) {
    case 'payment_request':
      return NotificationConstants.actionPayNow;
    case 'shipping_update':
      return NotificationConstants.actionTrack;
    case 'arrival':
      return NotificationConstants.actionClearance;
    case 'bid_won':
      return NotificationConstants.actionViewDetails;
    case 'id_reminder':
      return NotificationConstants.actionVerifyNow;
    case 'message':
      return NotificationConstants.actionViewMessage;
    case 'agent_assigned':
      return NotificationConstants.actionMeetAgent;
    case 'vehicle_listing':
      return NotificationConstants.actionReviewOptions;
    default:
      return null;
  }
}
