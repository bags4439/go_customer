// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarPreferencesModelImpl _$$CarPreferencesModelImplFromJson(
  Map<String, dynamic> json,
) => _$CarPreferencesModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  make: json['make'] as String?,
  model: json['model'] as String?,
  yearMin: (json['yearMin'] as num?)?.toInt(),
  yearMax: (json['yearMax'] as num?)?.toInt(),
  isSingleYear: json['isSingleYear'] as bool? ?? false,
  condition: _vehicleConditionFromJson(json['condition']),
  conditionLabel: json['conditionLabel'] as String?,
  maxMileage: (json['maxMileage'] as num?)?.toInt(),
  repairOptedIn: json['repairOptedIn'] as bool?,
  clearanceOptedIn: json['clearanceOptedIn'] as bool?,
  editedBy: json['editedBy'] as String?,
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
  editReason: json['editReason'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CarPreferencesModelImplToJson(
  _$CarPreferencesModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'make': instance.make,
  'model': instance.model,
  'yearMin': instance.yearMin,
  'yearMax': instance.yearMax,
  'isSingleYear': instance.isSingleYear,
  'condition': _vehicleConditionToJson(instance.condition),
  'conditionLabel': instance.conditionLabel,
  'maxMileage': instance.maxMileage,
  'repairOptedIn': instance.repairOptedIn,
  'clearanceOptedIn': instance.clearanceOptedIn,
  'editedBy': instance.editedBy,
  'editedAt': instance.editedAt?.toIso8601String(),
  'editReason': instance.editReason,
  'createdAt': instance.createdAt?.toIso8601String(),
};
