// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BreakdownItemImpl _$$BreakdownItemImplFromJson(Map<String, dynamic> json) =>
    _$BreakdownItemImpl(
      label: json['label'] as String,
      amountUsd: (json['amountUsd'] as num).toDouble(),
      isDeduction: json['isDeduction'] as bool? ?? false,
    );

Map<String, dynamic> _$$BreakdownItemImplToJson(_$BreakdownItemImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'amountUsd': instance.amountUsd,
      'isDeduction': instance.isDeduction,
    };

_$PaymentRequestModelImpl _$$PaymentRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentRequestModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  createdByAgentId: json['createdByAgentId'] as String?,
  paymentId: json['paymentId'] as String?,
  type: _paymentRequestTypeFromJson(json['type']),
  description: json['description'] as String?,
  breakdown: json['breakdown'] == null
      ? const []
      : _breakdownFromJson(json['breakdown']),
  amountUsd: (json['amountUsd'] as num).toDouble(),
  exchangeRateAtRequest: (json['exchangeRateAtRequest'] as num?)?.toDouble(),
  depositDeductedUsd: (json['depositDeductedUsd'] as num?)?.toDouble(),
  timelineStageKey: json['timelineStageKey'] as String?,
  invoiceImageUrl: json['invoiceImageUrl'] as String?,
  deadlineAt: json['deadlineAt'] == null
      ? null
      : DateTime.parse(json['deadlineAt'] as String),
  status: json['status'] as String? ?? 'pending',
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  expiredAt: json['expiredAt'] == null
      ? null
      : DateTime.parse(json['expiredAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
);

Map<String, dynamic> _$$PaymentRequestModelImplToJson(
  _$PaymentRequestModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'createdByAgentId': instance.createdByAgentId,
  'paymentId': instance.paymentId,
  'type': _paymentRequestTypeToJson(instance.type),
  'description': instance.description,
  'breakdown': _breakdownToJson(instance.breakdown),
  'amountUsd': instance.amountUsd,
  'exchangeRateAtRequest': instance.exchangeRateAtRequest,
  'depositDeductedUsd': instance.depositDeductedUsd,
  'timelineStageKey': instance.timelineStageKey,
  'invoiceImageUrl': instance.invoiceImageUrl,
  'deadlineAt': instance.deadlineAt?.toIso8601String(),
  'status': instance.status,
  'sentAt': instance.sentAt?.toIso8601String(),
  'paidAt': instance.paidAt?.toIso8601String(),
  'expiredAt': instance.expiredAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
};
