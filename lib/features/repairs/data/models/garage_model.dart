// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/garage.dart';

part 'garage_model.freezed.dart';
part 'garage_model.g.dart';

List<String>? _stringListFromJson(Object? json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  return null;
}

Object? _stringListToJson(List<String>? list) => list;

@freezed
class GarageModel with _$GarageModel {
  const factory GarageModel({
    required String id,
    required String name,
    String? location,
    String? city,
    String? phone,
    String? email,
    @Default(false) bool isVetted,
    @Default(0.0) double rating,
    @Default(0) int totalJobs,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? specialisations,
    @Default(true) bool isActive,
    DateTime? addedAt,
  }) = _GarageModel;

  factory GarageModel.fromJson(Map<String, dynamic> json) =>
      _$GarageModelFromJson(json);

  factory GarageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return GarageModel(id: doc.id, name: '');
    }
    final rawSpecs = data['specialisations'];
    return GarageModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String?,
      city: data['city'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      isVetted: data['isVetted'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: data['totalJobs'] as int? ?? 0,
      specialisations: rawSpecs != null
          ? List<String>.from(
              (rawSpecs as List).map((e) => e.toString()),
            )
          : null,
      isActive: data['isActive'] as bool? ?? true,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }
}

Garage garageFromDoc(DocumentSnapshot doc) {
  final m = GarageModel.fromFirestore(doc);
  return Garage(
    id: m.id,
    name: m.name,
    location: m.location,
    city: m.city,
    isVetted: m.isVetted,
    rating: m.rating,
    totalJobs: m.totalJobs,
  );
}
