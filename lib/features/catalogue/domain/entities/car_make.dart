class CarMake {
  final String slug;
  final String name;
  final bool popular;
  final String marketType;
  final int sortOrder;
  final bool isActive;

  const CarMake({
    required this.slug,
    required this.name,
    required this.popular,
    required this.marketType,
    required this.sortOrder,
    required this.isActive,
  });
}
