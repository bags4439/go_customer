/// Copy for vehicle option feedback UX.
class VehicleOptionConstants {
  VehicleOptionConstants._();

  static const String needsResponseLabel = 'Needs your response';

  static String pendingBannerTitle(int count) =>
      count == 1
          ? '1 option needs your response'
          : '$count options need your response';

  static const String pendingBannerBody =
      'Review each option and let your agent know if you are interested.';

  static String homeStatusLine(int count) =>
      count == 1
          ? '1 option awaiting your feedback'
          : '$count options awaiting your feedback';

  static String timelineButtonLabel(int pendingCount, int totalCount) {
    if (pendingCount > 0) {
      return pendingCount == 1
          ? 'Review 1 option awaiting response →'
          : 'Review $pendingCount options awaiting response →';
    }
    return totalCount == 1
        ? 'View vehicle option →'
        : 'View vehicle options →';
  }

  static String homeCtaTitle(int count) =>
      count == 1 ? '1 option to review' : '$count options to review';

  static const String homeCtaAction = 'Review now';

  static const String notificationAction = 'Review options →';
}
