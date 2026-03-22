/// One document per order in duty_clearance collection (or query by orderId).
class DutyClearance {
  final String id;
  final String orderId;
  final String handledBy;
  final double? clearanceFeeGhs;
  final String? icumsRef;
  final String? clearingAgentName;
  final double? dutyAmountGhs;
  final double? vatGhs;
  final double? nhilGhs;
  final double? otherLeviesGhs;
  final double? totalPayableGhs;
  final String graStatus;
  final DateTime? submittedAt;
  final DateTime? assessedAt;
  final DateTime? paidAt;
  final DateTime? clearedAt;
  final String? notes;
  final DateTime? createdAt;

  const DutyClearance({
    required this.id,
    required this.orderId,
    required this.handledBy,
    this.clearanceFeeGhs,
    this.icumsRef,
    this.clearingAgentName,
    this.dutyAmountGhs,
    this.vatGhs,
    this.nhilGhs,
    this.otherLeviesGhs,
    this.totalPayableGhs,
    required this.graStatus,
    this.submittedAt,
    this.assessedAt,
    this.paidAt,
    this.clearedAt,
    this.notes,
    this.createdAt,
  });

  bool get isAgentHandled => handledBy == 'agent';
  bool get isBuyerHandled => handledBy == 'buyer';
}
