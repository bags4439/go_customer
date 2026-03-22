// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      senderId: json['senderId'] as String,
      senderRole: json['senderRole'] as String,
      messageType: _messageTypeFromJson(json['messageType']),
      body: json['body'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaDurationSecs: (json['mediaDurationSecs'] as num?)?.toInt(),
      mediaFileName: json['mediaFileName'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      vehicleOptionId: json['vehicleOptionId'] as String?,
      paymentRequestId: json['paymentRequestId'] as String?,
      bidOutcomeId: json['bidOutcomeId'] as String?,
      shippingId: json['shippingId'] as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: _msgDateTimeFromJson(json['deletedAt']),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'senderId': instance.senderId,
      'senderRole': instance.senderRole,
      'messageType': _messageTypeToJson(instance.messageType),
      'body': instance.body,
      'mediaUrl': instance.mediaUrl,
      'mediaDurationSecs': instance.mediaDurationSecs,
      'mediaFileName': instance.mediaFileName,
      'thumbnailUrl': instance.thumbnailUrl,
      'vehicleOptionId': instance.vehicleOptionId,
      'paymentRequestId': instance.paymentRequestId,
      'bidOutcomeId': instance.bidOutcomeId,
      'shippingId': instance.shippingId,
      'replyToMessageId': instance.replyToMessageId,
      'isRead': instance.isRead,
      'isDeleted': instance.isDeleted,
      'deletedAt': _msgDateTimeToJson(instance.deletedAt),
      'sentAt': instance.sentAt?.toIso8601String(),
    };
