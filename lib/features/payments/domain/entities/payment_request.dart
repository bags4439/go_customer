import 'breakdown_item.dart';

/// Full payment request from Firestore — used for the 4-screen flow.
class PaymentRequest {
  final String id;
  final String orderId;
  final String createdByAgentId;
  final String? paymentId;
  final String type;
  final String? description;
  final List<BreakdownItem> breakdown;
  final double totalGhs;
  final double totalUsd;
  final double exchangeRate;
  final double? depositDeductedGhs;
  final DateTime? deadlineAt;
  final String status;
  final DateTime? sentAt;
  final DateTime? paidAt;
  final DateTime? expiredAt;
  final DateTime? cancelledAt;

  const PaymentRequest({
    required this.id,
    required this.orderId,
    required this.createdByAgentId,
    this.paymentId,
    required this.type,
    this.description,
    required this.breakdown,
    required this.totalGhs,
    required this.totalUsd,
    required this.exchangeRate,
    this.depositDeductedGhs,
    this.deadlineAt,
    required this.status,
    this.sentAt,
    this.paidAt,
    this.expiredAt,
    this.cancelledAt,
  });

  bool get isPending => status == 'pending';
}
