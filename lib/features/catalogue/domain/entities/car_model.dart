import 'price_band.dart';

class CarModel {
  final String slug;
  final String name;
  final int yearStart;
  final int yearEnd;
  final List<String> trims;
  final String? imageUrl;
  final bool isActive;
  final List<PriceBand> priceBands;

  const CarModel({
    required this.slug,
    required this.name,
    required this.yearStart,
    required this.yearEnd,
    required this.trims,
    required this.imageUrl,
    required this.isActive,
    required this.priceBands,
  });

  double? estimatedAuctionPriceForYears(
    int yearMin,
    int yearMax,
  ) {
    final mid = ((yearMin + yearMax) / 2).round();
    for (final band in priceBands) {
      if (mid >= band.yearStart && mid <= band.yearEnd) {
        return band.estimatedAuctionPriceUsd;
      }
    }
    if (priceBands.isEmpty) return null;
    return priceBands.last.estimatedAuctionPriceUsd;
  }
}
