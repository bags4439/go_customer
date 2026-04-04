// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryModelImpl _$$DeliveryModelImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryCity: json['deliveryCity'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationLabel: json['locationLabel'] as String?,
      locationSource: json['locationSource'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
      actualDeliveryDate: json['actualDeliveryDate'] == null
          ? null
          : DateTime.parse(json['actualDeliveryDate'] as String),
      deliveredBy: json['deliveredBy'] as String?,
      proofOfDeliveryUrl: json['proofOfDeliveryUrl'] as String?,
      buyerConfirmed: json['buyerConfirmed'] as bool? ?? false,
      buyerConfirmedAt: json['buyerConfirmedAt'] == null
          ? null
          : DateTime.parse(json['buyerConfirmedAt'] as String),
      status: json['status'] as String? ?? 'pending_payment',
      paymentConfirmed: json['paymentConfirmed'] as bool? ?? false,
      paymentConfirmedAt: json['paymentConfirmedAt'] == null
          ? null
          : DateTime.parse(json['paymentConfirmedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DeliveryModelImplToJson(_$DeliveryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'deliveryAddress': instance.deliveryAddress,
      'deliveryCity': instance.deliveryCity,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationLabel': instance.locationLabel,
      'locationSource': instance.locationSource,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'actualDeliveryDate': instance.actualDeliveryDate?.toIso8601String(),
      'deliveredBy': instance.deliveredBy,
      'proofOfDeliveryUrl': instance.proofOfDeliveryUrl,
      'buyerConfirmed': instance.buyerConfirmed,
      'buyerConfirmedAt': instance.buyerConfirmedAt?.toIso8601String(),
      'status': instance.status,
      'paymentConfirmed': instance.paymentConfirmed,
      'paymentConfirmedAt': instance.paymentConfirmedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
