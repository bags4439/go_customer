// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_outcome_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BidOutcomeModelImpl _$$BidOutcomeModelImplFromJson(
  Map<String, dynamic> json,
) => _$BidOutcomeModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  vehicleOptionId: json['vehicleOptionId'] as String?,
  agentId: json['agentId'] as String,
  outcome: json['outcome'] as String,
  maxBidUsd: (json['maxBidUsd'] as num?)?.toDouble(),
  finalPriceUsd: (json['finalPriceUsd'] as num?)?.toDouble(),
  savingUsd: (json['savingUsd'] as num?)?.toDouble(),
  finalPriceGhs: (json['finalPriceGhs'] as num?)?.toDouble(),
  lossReason: json['lossReason'] as String?,
  lossPriceUsd: (json['lossPriceUsd'] as num?)?.toDouble(),
  nextStep: json['nextStep'] as String?,
  noteToBuyer: json['noteToBuyer'] as String?,
  bidDate: _bidDateTimeFromJson(json['bidDate']),
  loggedAt: _bidDateTimeFromJson(json['loggedAt']),
);

Map<String, dynamic> _$$BidOutcomeModelImplToJson(
  _$BidOutcomeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'vehicleOptionId': instance.vehicleOptionId,
  'agentId': instance.agentId,
  'outcome': instance.outcome,
  'maxBidUsd': instance.maxBidUsd,
  'finalPriceUsd': instance.finalPriceUsd,
  'savingUsd': instance.savingUsd,
  'finalPriceGhs': instance.finalPriceGhs,
  'lossReason': instance.lossReason,
  'lossPriceUsd': instance.lossPriceUsd,
  'nextStep': instance.nextStep,
  'noteToBuyer': instance.noteToBuyer,
  'bidDate': _bidDateTimeToJson(instance.bidDate),
  'loggedAt': _bidDateTimeToJson(instance.loggedAt),
};
