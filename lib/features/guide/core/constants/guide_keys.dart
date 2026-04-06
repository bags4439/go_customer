/// SharedPreferences keys for each coach mark
/// touchpoint. One key per guide moment.
/// Never hardcode these strings outside this file.
class GuideKeys {
  GuideKeys._();

  static const String homeEmpty = 'guide_seen_home_empty';
  static const String homeOrders = 'guide_seen_home_orders';
  static const String orderTimeline = 'guide_seen_order_timeline';
  static const String orderPaymentRequest =
      'guide_seen_order_payment_request';
  static const String stageSearching = 'guide_seen_stage_searching';
  static const String stageBid = 'guide_seen_stage_bid';
  static const String stageShipping = 'guide_seen_stage_shipping';
  static const String stageClearance = 'guide_seen_stage_clearance';
  static const String stageRepair = 'guide_seen_stage_repair';
  static const String stageDelivery = 'guide_seen_stage_delivery';
  static const String chat = 'guide_seen_chat';
  static const String documents = 'guide_seen_documents';
  static const String notifications = 'guide_seen_notifications';
  static const String agentProfile = 'guide_seen_agent_profile';

  /// All keys — used for resetAll().
  static const List<String> all = [
    homeEmpty,
    homeOrders,
    orderTimeline,
    orderPaymentRequest,
    stageSearching,
    stageBid,
    stageShipping,
    stageClearance,
    stageRepair,
    stageDelivery,
    chat,
    documents,
    notifications,
    agentProfile,
  ];
}
