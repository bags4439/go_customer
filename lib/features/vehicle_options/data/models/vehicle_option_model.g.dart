// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleOptionModelImpl _$$VehicleOptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$VehicleOptionModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  agentId: json['agentId'] as String,
  listingUrl: json['listingUrl'] as String? ?? '',
  listingTitle: json['listingTitle'] as String? ?? '',
  source: _sourceFromJson(json['source']),
  agentNote: json['agentNote'] as String?,
  status: json['status'] == null
      ? VehicleOptionStatus.draft
      : _statusFromJson(json['status']),
  buyerResponse: json['buyerResponse'] == null
      ? BuyerVehicleResponse.pending
      : _buyerResponseFromJson(json['buyerResponse']),
  sentAt: _dateTimeFromJson(json['sentAt']),
  buyerRespondedAt: _dateTimeFromJson(json['buyerRespondedAt']),
  createdAt: _dateTimeFromJson(json['createdAt']),
);

Map<String, dynamic> _$$VehicleOptionModelImplToJson(
  _$VehicleOptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'agentId': instance.agentId,
  'listingUrl': instance.listingUrl,
  'listingTitle': instance.listingTitle,
  'source': _sourceToJson(instance.source),
  'agentNote': instance.agentNote,
  'status': _statusToJson(instance.status),
  'buyerResponse': _buyerResponseToJson(instance.buyerResponse),
  'sentAt': _dateTimeToJson(instance.sentAt),
  'buyerRespondedAt': _dateTimeToJson(instance.buyerRespondedAt),
  'createdAt': _dateTimeToJson(instance.createdAt),
};
