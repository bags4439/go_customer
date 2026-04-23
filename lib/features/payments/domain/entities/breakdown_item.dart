/// Single line item from payment_requests.breakdown.
class BreakdownItem {
  final String label;
  final double amountUsd;
  final bool isDeduction;

  const BreakdownItem({
    required this.label,
    required this.amountUsd,
    this.isDeduction = false,
  });
}
