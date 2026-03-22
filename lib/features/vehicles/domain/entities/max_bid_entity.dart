class MaxBidEntity {
  final String id;
  final String orderId;
  final String vehicleOptionId;
  final String buyerId;
  final double maxBidUsd;
  final double maxBidGhs;
  final double exchangeRate;
  final DateTime? confirmedAt;

  const MaxBidEntity({
    required this.id,
    required this.orderId,
    required this.vehicleOptionId,
    required this.buyerId,
    required this.maxBidUsd,
    required this.maxBidGhs,
    required this.exchangeRate,
    this.confirmedAt,
  });
}
