import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_model.freezed.dart';
part 'agent_model.g.dart';

@freezed
class AgentModel with _$AgentModel {
  const factory AgentModel({
    required String id,
    required String userId,
    String? employeeId,
    @Default('active') String status, // active|inactive|suspended
    @Default(15) int maxActiveOrders,
    @Default(0) int totalOrdersCompleted,
    @Default(0.0) double successRate,
    @Default(0.0) double rating,
    DateTime? createdAt,
  }) = _AgentModel;

  factory AgentModel.fromJson(Map<String, dynamic> json) =>
      _$AgentModelFromJson(json);

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return AgentModel(id: doc.id, userId: '');
    }
    return AgentModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      employeeId: data['employeeId'] as String?,
      status: data['status'] as String? ?? 'active',
      maxActiveOrders: data['maxActiveOrders'] as int? ?? 15,
      totalOrdersCompleted:
          data['totalOrdersCompleted'] as int? ?? 0,
      successRate:
          (data['successRate'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
