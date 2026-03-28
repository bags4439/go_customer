import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/car_model.dart';
import '../../domain/entities/price_band.dart';

class CarModelModel {
  final String slug;
  final String name;
  final int yearStart;
  final int yearEnd;
  final List<String> trims;
  final String? imageUrl;
  final bool isActive;
  final List<PriceBand> priceBands;

  const CarModelModel({
    required this.slug,
    required this.name,
    required this.yearStart,
    required this.yearEnd,
    required this.trims,
    required this.imageUrl,
    required this.isActive,
    required this.priceBands,
  });

  factory CarModelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawTrims = data['trims'] as List<dynamic>? ?? [];
    final trims = rawTrims.map((e) => e.toString()).toList();

    final rawBands = data['priceBands'] as List<dynamic>? ?? [];
    final priceBands = rawBands
        .whereType<Map<String, dynamic>>()
        .map(
          (b) => PriceBand(
            yearStart: (b['yearStart'] as num?)?.toInt() ?? 0,
            yearEnd: (b['yearEnd'] as num?)?.toInt() ?? 0,
            estimatedAuctionPriceUsd:
                (b['estimatedAuctionPriceUsd'] as num?)?.toDouble() ?? 0.0,
          ),
        )
        .toList();

    return CarModelModel(
      slug: data['slug'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      yearStart: (data['yearStart'] as num?)?.toInt() ?? 2010,
      yearEnd: (data['yearEnd'] as num?)?.toInt() ?? 2025,
      trims: trims,
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      priceBands: priceBands,
    );
  }

  CarModel toEntity() => CarModel(
        slug: slug,
        name: name,
        yearStart: yearStart,
        yearEnd: yearEnd,
        trims: trims,
        imageUrl: imageUrl,
        isActive: isActive,
        priceBands: priceBands,
      );
}
