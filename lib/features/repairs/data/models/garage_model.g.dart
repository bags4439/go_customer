// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GarageModelImpl _$$GarageModelImplFromJson(Map<String, dynamic> json) =>
    _$GarageModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isVetted: json['isVetted'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      specialisations: _stringListFromJson(json['specialisations']),
      isActive: json['isActive'] as bool? ?? true,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$GarageModelImplToJson(_$GarageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'city': instance.city,
      'phone': instance.phone,
      'email': instance.email,
      'isVetted': instance.isVetted,
      'rating': instance.rating,
      'totalJobs': instance.totalJobs,
      'specialisations': _stringListToJson(instance.specialisations),
      'isActive': instance.isActive,
      'addedAt': instance.addedAt?.toIso8601String(),
    };
