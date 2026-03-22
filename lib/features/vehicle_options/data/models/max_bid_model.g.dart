// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'max_bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaxBidModelImpl _$$MaxBidModelImplFromJson(Map<String, dynamic> json) =>
    _$MaxBidModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      vehicleOptionId: json['vehicleOptionId'] as String,
      buyerId: json['buyerId'] as String,
      maxBidUsd: (json['maxBidUsd'] as num).toDouble(),
      maxBidGhs: (json['maxBidGhs'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      agentNotified: json['agentNotified'] as bool? ?? false,
      agentNotifiedAt: json['agentNotifiedAt'] == null
          ? null
          : DateTime.parse(json['agentNotifiedAt'] as String),
    );

Map<String, dynamic> _$$MaxBidModelImplToJson(_$MaxBidModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'vehicleOptionId': instance.vehicleOptionId,
      'buyerId': instance.buyerId,
      'maxBidUsd': instance.maxBidUsd,
      'maxBidGhs': instance.maxBidGhs,
      'exchangeRate': instance.exchangeRate,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'agentNotified': instance.agentNotified,
      'agentNotifiedAt': instance.agentNotifiedAt?.toIso8601String(),
    };
