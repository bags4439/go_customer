class PriceBand {
  final int yearStart;
  final int yearEnd;
  final double estimatedAuctionPriceUsd;

  const PriceBand({
    required this.yearStart,
    required this.yearEnd,
    required this.estimatedAuctionPriceUsd,
  });
}
