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
  clearanceFeeGhs: (json['clearanceFeeGhs'] as num?)?.toDouble(),
  icumsRef: json['icumsRef'] as String?,
  clearingAgentName: json['clearingAgentName'] as String?,
  dutyAmountGhs: (json['dutyAmountGhs'] as num?)?.toDouble(),
  vatGhs: (json['vatGhs'] as num?)?.toDouble(),
  nhilGhs: (json['nhilGhs'] as num?)?.toDouble(),
  otherLeviesGhs: (json['otherLeviesGhs'] as num?)?.toDouble(),
  totalPayableGhs: (json['totalPayableGhs'] as num?)?.toDouble(),
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
  'clearanceFeeGhs': instance.clearanceFeeGhs,
  'icumsRef': instance.icumsRef,
  'clearingAgentName': instance.clearingAgentName,
  'dutyAmountGhs': instance.dutyAmountGhs,
  'vatGhs': instance.vatGhs,
  'nhilGhs': instance.nhilGhs,
  'otherLeviesGhs': instance.otherLeviesGhs,
  'totalPayableGhs': instance.totalPayableGhs,
  'graStatus': _graStatusToJson(instance.graStatus),
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'assessedAt': instance.assessedAt?.toIso8601String(),
  'paidAt': instance.paidAt?.toIso8601String(),
  'clearedAt': instance.clearedAt?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
};
