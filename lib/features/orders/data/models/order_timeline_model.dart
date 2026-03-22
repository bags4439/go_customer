import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_timeline_model.freezed.dart';
part 'order_timeline_model.g.dart';

@freezed
class OrderTimelineModel with _$OrderTimelineModel {
  const factory OrderTimelineModel({
    required String id,
    required String orderId,
    required int stageNumber,
    required String stageKey,
    required String label,
    String? detail,
    String? actionLabel,
    @Default('none') String actionType,
    String? actionTargetId,
    @Default(false) bool isComplete,
    @Default(false) bool isActive,
    @Default(false) bool isBlocked,
    DateTime? completedAt,
    DateTime? activatedAt,
  }) = _OrderTimelineModel;

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineModelFromJson(json);

  factory OrderTimelineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return OrderTimelineModel(
        id: doc.id,
        orderId: '',
        stageNumber: 1,
        stageKey: '',
        label: '',
      );
    }
    return OrderTimelineModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      stageNumber: data['stageNumber'] as int? ?? 1,
      stageKey: data['stageKey'] as String? ?? '',
      label: data['label'] as String? ?? '',
      detail: data['detail'] as String?,
      actionLabel: data['actionLabel'] as String?,
      actionType: data['actionType'] as String? ?? 'none',
      actionTargetId: data['actionTargetId'] as String?,
      isComplete: data['isComplete'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? false,
      isBlocked: data['isBlocked'] as bool? ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      activatedAt: (data['activatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
