// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExchangeRateModelImpl _$$ExchangeRateModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExchangeRateModelImpl(
  id: json['id'] as String,
  usdToGhs: (json['usdToGhs'] as num).toDouble(),
  source: json['source'] as String?,
  fetchedAt: json['fetchedAt'] == null
      ? null
      : DateTime.parse(json['fetchedAt'] as String),
  isCurrent: json['isCurrent'] as bool? ?? true,
);

Map<String, dynamic> _$$ExchangeRateModelImplToJson(
  _$ExchangeRateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'usdToGhs': instance.usdToGhs,
  'source': instance.source,
  'fetchedAt': instance.fetchedAt?.toIso8601String(),
  'isCurrent': instance.isCurrent,
};
