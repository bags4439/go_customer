/// One document per order in duty_clearance collection (or query by orderId).
class DutyClearance {
  final String id;
  final String orderId;
  final String handledBy;
  final double? clearanceFeeUsd;
  final String? icumsRef;
  final String? clearingAgentName;
  final double? dutyAmountUsd;
  final double? vatUsd;
  final double? nhilUsd;
  final double? otherLeviesUsd;
  final double? totalPayableUsd;
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
    this.clearanceFeeUsd,
    this.icumsRef,
    this.clearingAgentName,
    this.dutyAmountUsd,
    this.vatUsd,
    this.nhilUsd,
    this.otherLeviesUsd,
    this.totalPayableUsd,
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
