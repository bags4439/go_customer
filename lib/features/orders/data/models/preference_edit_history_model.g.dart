// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_edit_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PreferenceEditHistoryModelImpl _$$PreferenceEditHistoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$PreferenceEditHistoryModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  editedByUserId: json['editedByUserId'] as String,
  editedByRole: json['editedByRole'] as String,
  previousValuesJson: json['previousValuesJson'] as Map<String, dynamic>?,
  newValuesJson: json['newValuesJson'] as Map<String, dynamic>?,
  reason: json['reason'] as String?,
  buyerNotified: json['buyerNotified'] as bool? ?? false,
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
);

Map<String, dynamic> _$$PreferenceEditHistoryModelImplToJson(
  _$PreferenceEditHistoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'editedByUserId': instance.editedByUserId,
  'editedByRole': instance.editedByRole,
  'previousValuesJson': instance.previousValuesJson,
  'newValuesJson': instance.newValuesJson,
  'reason': instance.reason,
  'buyerNotified': instance.buyerNotified,
  'editedAt': instance.editedAt?.toIso8601String(),
};
