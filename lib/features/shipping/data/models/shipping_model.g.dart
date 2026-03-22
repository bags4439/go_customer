// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShippingModelImpl _$$ShippingModelImplFromJson(Map<String, dynamic> json) =>
    _$ShippingModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      vesselName: json['vesselName'] as String?,
      shippingLine: json['shippingLine'] as String?,
      blNumber: json['blNumber'] as String?,
      containerNumber: json['containerNumber'] as String?,
      originPort: json['originPort'] as String?,
      destinationPort: json['destinationPort'] as String? ?? 'Tema, Ghana',
      trackingUrl: json['trackingUrl'] as String?,
      estimatedDeparture: json['estimatedDeparture'] == null
          ? null
          : DateTime.parse(json['estimatedDeparture'] as String),
      actualDeparture: json['actualDeparture'] == null
          ? null
          : DateTime.parse(json['actualDeparture'] as String),
      estimatedArrival: json['estimatedArrival'] == null
          ? null
          : DateTime.parse(json['estimatedArrival'] as String),
      actualArrival: json['actualArrival'] == null
          ? null
          : DateTime.parse(json['actualArrival'] as String),
      journeyProgressPct: (json['journeyProgressPct'] as num?)?.toDouble(),
      status: json['status'] == null
          ? ShippingStatus.pending
          : _shippingStatusFromJson(json['status']),
      agentNotes: json['agentNotes'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ShippingModelImplToJson(_$ShippingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'vesselName': instance.vesselName,
      'shippingLine': instance.shippingLine,
      'blNumber': instance.blNumber,
      'containerNumber': instance.containerNumber,
      'originPort': instance.originPort,
      'destinationPort': instance.destinationPort,
      'trackingUrl': instance.trackingUrl,
      'estimatedDeparture': instance.estimatedDeparture?.toIso8601String(),
      'actualDeparture': instance.actualDeparture?.toIso8601String(),
      'estimatedArrival': instance.estimatedArrival?.toIso8601String(),
      'actualArrival': instance.actualArrival?.toIso8601String(),
      'journeyProgressPct': instance.journeyProgressPct,
      'status': _shippingStatusToJson(instance.status),
      'agentNotes': instance.agentNotes,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
