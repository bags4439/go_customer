/// Presentation-ready payment request entity.
class PaymentRequestView {
  final String id;
  final double totalGhs;
  final String type;
  final DateTime? deadlineAt;

  const PaymentRequestView({
    required this.id,
    required this.totalGhs,
    required this.type,
    required this.deadlineAt,
  });
}
