/// Single line item from payment_requests.breakdownJson.
class BreakdownItem {
  final String label;
  final double amountGhs;
  final double amountUsd;
  final bool isDeduction;

  const BreakdownItem({
    required this.label,
    required this.amountGhs,
    required this.amountUsd,
    this.isDeduction = false,
  });
}
