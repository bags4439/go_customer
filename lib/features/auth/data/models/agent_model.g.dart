// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentModelImpl _$$AgentModelImplFromJson(Map<String, dynamic> json) =>
    _$AgentModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      employeeId: json['employeeId'] as String?,
      status: json['status'] as String? ?? 'active',
      maxActiveOrders: (json['maxActiveOrders'] as num?)?.toInt() ?? 15,
      totalOrdersCompleted:
          (json['totalOrdersCompleted'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AgentModelImplToJson(_$AgentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'employeeId': instance.employeeId,
      'status': instance.status,
      'maxActiveOrders': instance.maxActiveOrders,
      'totalOrdersCompleted': instance.totalOrdersCompleted,
      'successRate': instance.successRate,
      'rating': instance.rating,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
