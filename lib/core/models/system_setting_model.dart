// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_setting_model.freezed.dart';
part 'system_setting_model.g.dart';

Object? _dynamicFromJson(Object? json) => json;

Object? _dynamicToJson(dynamic value) => value;

@freezed
class SystemSettingModel with _$SystemSettingModel {
  const factory SystemSettingModel({
    required String id,
    required String key,
    @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
    Object? value,
    String? label,
    String? updatedBy,
    DateTime? updatedAt,
  }) = _SystemSettingModel;

  factory SystemSettingModel.fromJson(Map<String, dynamic> json) =>
      _$SystemSettingModelFromJson(json);

  factory SystemSettingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return SystemSettingModel(id: doc.id, key: '');
    }
    return SystemSettingModel(
      id: doc.id,
      key: data['key'] as String? ?? '',
      value: data['value'],
      label: data['label'] as String?,
      updatedBy: data['updatedBy'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
