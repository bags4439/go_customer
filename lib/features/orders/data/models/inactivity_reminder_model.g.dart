// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inactivity_reminder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InactivityReminderModelImpl _$$InactivityReminderModelImplFromJson(
  Map<String, dynamic> json,
) => _$InactivityReminderModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  agentId: json['agentId'] as String,
  reminderLevel: (json['reminderLevel'] as num).toInt(),
  triggeredAt: json['triggeredAt'] == null
      ? null
      : DateTime.parse(json['triggeredAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  actionTaken: json['actionTaken'] as String? ?? 'none',
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$InactivityReminderModelImplToJson(
  _$InactivityReminderModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'agentId': instance.agentId,
  'reminderLevel': instance.reminderLevel,
  'triggeredAt': instance.triggeredAt?.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'actionTaken': instance.actionTaken,
  'notes': instance.notes,
};
