// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderTimelineModelImpl _$$OrderTimelineModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrderTimelineModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  stageNumber: (json['stageNumber'] as num).toInt(),
  stageKey: json['stageKey'] as String,
  label: json['label'] as String,
  detail: json['detail'] as String?,
  actionLabel: json['actionLabel'] as String?,
  actionType: json['actionType'] as String? ?? 'none',
  actionTargetId: json['actionTargetId'] as String?,
  isComplete: json['isComplete'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? false,
  isBlocked: json['isBlocked'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  activatedAt: json['activatedAt'] == null
      ? null
      : DateTime.parse(json['activatedAt'] as String),
);

Map<String, dynamic> _$$OrderTimelineModelImplToJson(
  _$OrderTimelineModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'stageNumber': instance.stageNumber,
  'stageKey': instance.stageKey,
  'label': instance.label,
  'detail': instance.detail,
  'actionLabel': instance.actionLabel,
  'actionType': instance.actionType,
  'actionTargetId': instance.actionTargetId,
  'isComplete': instance.isComplete,
  'isActive': instance.isActive,
  'isBlocked': instance.isBlocked,
  'completedAt': instance.completedAt?.toIso8601String(),
  'activatedAt': instance.activatedAt?.toIso8601String(),
};
