// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuyerReviewModelImpl _$$BuyerReviewModelImplFromJson(
  Map<String, dynamic> json,
) => _$BuyerReviewModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  buyerId: json['buyerId'] as String,
  agentId: json['agentId'] as String,
  overallRating: (json['overallRating'] as num).toDouble(),
  agentRating: (json['agentRating'] as num).toDouble(),
  communicationRating: (json['communicationRating'] as num).toDouble(),
  speedRating: (json['speedRating'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$BuyerReviewModelImplToJson(
  _$BuyerReviewModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'buyerId': instance.buyerId,
  'agentId': instance.agentId,
  'overallRating': instance.overallRating,
  'agentRating': instance.agentRating,
  'communicationRating': instance.communicationRating,
  'speedRating': instance.speedRating,
  'comment': instance.comment,
  'createdAt': instance.createdAt?.toIso8601String(),
};
