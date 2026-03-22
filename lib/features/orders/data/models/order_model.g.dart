// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      orderRef: json['orderRef'] as String,
      buyerId: json['buyerId'] as String,
      agentId: json['agentId'] as String?,
      status: json['status'] == null
          ? OrderStatus.open
          : _orderStatusFromJson(json['status']),
      currentStage: json['currentStage'] as String?,
      stageNumber: (json['stageNumber'] as num?)?.toInt() ?? 1,
      firstPaymentMade: json['firstPaymentMade'] as bool? ?? false,
      cancelledBy: json['cancelledBy'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      cancellationNote: json['cancellationNote'] as String?,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderRef': instance.orderRef,
      'buyerId': instance.buyerId,
      'agentId': instance.agentId,
      'status': _orderStatusToJson(instance.status),
      'currentStage': instance.currentStage,
      'stageNumber': instance.stageNumber,
      'firstPaymentMade': instance.firstPaymentMade,
      'cancelledBy': instance.cancelledBy,
      'cancellationReason': instance.cancellationReason,
      'cancellationNote': instance.cancellationNote,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
