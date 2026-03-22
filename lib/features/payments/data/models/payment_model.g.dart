// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentModelImpl _$$PaymentModelImplFromJson(Map<String, dynamic> json) =>
    _$PaymentModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      buyerId: json['buyerId'] as String,
      paymentRequestId: json['paymentRequestId'] as String?,
      paymentRef: json['paymentRef'] as String?,
      type: json['type'] as String,
      description: json['description'] as String?,
      amountGhs: (json['amountGhs'] as num).toDouble(),
      amountUsd: (json['amountUsd'] as num?)?.toDouble(),
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'GHS',
      method: json['method'] as String?,
      provider: json['provider'] as String?,
      providerRef: json['providerRef'] as String?,
      status: json['status'] as String? ?? 'pending',
      failureReason: json['failureReason'] as String?,
      initiatedAt: json['initiatedAt'] == null
          ? null
          : DateTime.parse(json['initiatedAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
    );

Map<String, dynamic> _$$PaymentModelImplToJson(_$PaymentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'buyerId': instance.buyerId,
      'paymentRequestId': instance.paymentRequestId,
      'paymentRef': instance.paymentRef,
      'type': instance.type,
      'description': instance.description,
      'amountGhs': instance.amountGhs,
      'amountUsd': instance.amountUsd,
      'exchangeRate': instance.exchangeRate,
      'currency': instance.currency,
      'method': instance.method,
      'provider': instance.provider,
      'providerRef': instance.providerRef,
      'status': instance.status,
      'failureReason': instance.failureReason,
      'initiatedAt': instance.initiatedAt?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
    };
