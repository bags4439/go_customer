/// Presentation-ready order entity.
/// Combines order document + car preferences in one object
/// so screens never need to watch two providers.
class OrderView {
  final String id;
  final String orderRef;
  final String? agentId;
  final String status;
  final int stageNumber;
  final bool hasPendingPayment;
  final bool firstPaymentMade;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // From car_preferences subcollection
  final String? make;
  final String? model;
  final String? trim;
  final String purchaseOrigin; // 'any'|'us_canada'|'dubai'|'china'
  final bool isNewVehicle;
  final bool repairOptedIn;

  /// From car_preferences — year range for summaries.
  final int? yearMin;
  final int? yearMax;
  final bool isSingleYear;

  const OrderView({
    required this.id,
    required this.orderRef,
    required this.agentId,
    required this.status,
    required this.stageNumber,
    required this.hasPendingPayment,
    required this.firstPaymentMade,
    required this.createdAt,
    required this.updatedAt,
    required this.make,
    required this.model,
    this.trim,
    this.purchaseOrigin = 'any',
    this.isNewVehicle = false,
    this.repairOptedIn = false,
    this.yearMin,
    this.yearMax,
    this.isSingleYear = false,
  });

  static const String _delivered = 'delivered';
  static const String _paymentPending = 'paymentPending';
  static const String _cancelled = 'cancelled';

  bool get isCompleted => status == _delivered;
  bool get needsPayment => status == _paymentPending;
  bool get isCancelled => status == _cancelled;

  /// Display label for purchase origin.
  String get purchaseOriginLabel => switch (purchaseOrigin) {
    'us_canada' => 'US / Canada',
    'dubai' => 'Dubai / Middle East',
    'china' => 'China',
    _ => 'No preference',
  };
}

/// Alias kept for backward compatibility with existing
/// widgets that import OrderModel.
typedef OrderModel = OrderView;
