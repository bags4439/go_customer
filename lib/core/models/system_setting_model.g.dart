// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_setting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemSettingModelImpl _$$SystemSettingModelImplFromJson(
  Map<String, dynamic> json,
) => _$SystemSettingModelImpl(
  id: json['id'] as String,
  key: json['key'] as String,
  value: _dynamicFromJson(json['value']),
  label: json['label'] as String?,
  updatedBy: json['updatedBy'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SystemSettingModelImplToJson(
  _$SystemSettingModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'value': _dynamicToJson(instance.value),
  'label': instance.label,
  'updatedBy': instance.updatedBy,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
