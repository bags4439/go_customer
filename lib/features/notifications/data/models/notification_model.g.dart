// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  orderId: json['orderId'] as String?,
  orderRef: json['orderRef'] as String?,
  type: _notificationTypeFromJson(json['type']),
  title: json['title'] as String,
  body: json['body'] as String,
  actionUrl: json['actionUrl'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'orderId': instance.orderId,
  'orderRef': instance.orderRef,
  'type': _notificationTypeToJson(instance.type),
  'title': instance.title,
  'body': instance.body,
  'actionUrl': instance.actionUrl,
  'isRead': instance.isRead,
  'sentAt': instance.sentAt?.toIso8601String(),
};
