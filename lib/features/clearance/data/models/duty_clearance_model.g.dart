// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty_clearance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DutyClearanceModelImpl _$$DutyClearanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$DutyClearanceModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  handledBy: json['handledBy'] as String? ?? 'agent',
  clearanceFeeUsd: (json['clearanceFeeUsd'] as num?)?.toDouble(),
  icumsRef: json['icumsRef'] as String?,
  clearingAgentName: json['clearingAgentName'] as String?,
  dutyAmountUsd: (json['dutyAmountUsd'] as num?)?.toDouble(),
  vatUsd: (json['vatUsd'] as num?)?.toDouble(),
  nhilUsd: (json['nhilUsd'] as num?)?.toDouble(),
  otherLeviesUsd: (json['otherLeviesUsd'] as num?)?.toDouble(),
  totalPayableUsd: (json['totalPayableUsd'] as num?)?.toDouble(),
  graStatus: json['graStatus'] == null
      ? GraStatus.notStarted
      : _graStatusFromJson(json['graStatus']),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  assessedAt: json['assessedAt'] == null
      ? null
      : DateTime.parse(json['assessedAt'] as String),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  clearedAt: json['clearedAt'] == null
      ? null
      : DateTime.parse(json['clearedAt'] as String),
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$DutyClearanceModelImplToJson(
  _$DutyClearanceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'handledBy': instance.handledBy,
  'clearanceFeeUsd': instance.clearanceFeeUsd,
  'icumsRef': instance.icumsRef,
  'clearingAgentName': instance.clearingAgentName,
  'dutyAmountUsd': instance.dutyAmountUsd,
  'vatUsd': instance.vatUsd,
  'nhilUsd': instance.nhilUsd,
  'otherLeviesUsd': instance.otherLeviesUsd,
  'totalPayableUsd': instance.totalPayableUsd,
  'graStatus': _graStatusToJson(instance.graStatus),
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'assessedAt': instance.assessedAt?.toIso8601String(),
  'paidAt': instance.paidAt?.toIso8601String(),
  'clearedAt': instance.clearedAt?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
};
