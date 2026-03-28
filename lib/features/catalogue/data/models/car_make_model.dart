import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/car_make.dart';

class CarMakeModel {
  final String slug;
  final String name;
  final bool popular;
  final String marketType;
  final int sortOrder;
  final bool isActive;

  const CarMakeModel({
    required this.slug,
    required this.name,
    required this.popular,
    required this.marketType,
    required this.sortOrder,
    required this.isActive,
  });

  factory CarMakeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CarMakeModel(
      slug: data['slug'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      popular: data['popular'] as bool? ?? false,
      marketType: data['marketType'] as String? ?? 'us_auction',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 999,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  CarMake toEntity() => CarMake(
        slug: slug,
        name: name,
        popular: popular,
        marketType: marketType,
        sortOrder: sortOrder,
        isActive: isActive,
      );
}
