/// Presentation-ready payment request entity.
class PaymentRequestView {
  final String id;
  final double amountUsd;
  final String type;
  final DateTime? deadlineAt;

  const PaymentRequestView({
    required this.id,
    required this.amountUsd,
    required this.type,
    required this.deadlineAt,
  });
}
