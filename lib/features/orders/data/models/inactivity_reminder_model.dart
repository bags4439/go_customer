import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inactivity_reminder_model.freezed.dart';
part 'inactivity_reminder_model.g.dart';

@freezed
class InactivityReminderModel with _$InactivityReminderModel {
  const factory InactivityReminderModel({
    required String id,
    required String orderId,
    required String agentId,
    required int reminderLevel,
    DateTime? triggeredAt,
    DateTime? resolvedAt,
    @Default('none') String actionTaken,
    String? notes,
  }) = _InactivityReminderModel;

  factory InactivityReminderModel.fromJson(Map<String, dynamic> json) =>
      _$InactivityReminderModelFromJson(json);

  factory InactivityReminderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return InactivityReminderModel(
        id: doc.id,
        orderId: '',
        agentId: '',
        reminderLevel: 0,
      );
    }
    return InactivityReminderModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      agentId: data['agentId'] as String? ?? '',
      reminderLevel: data['reminderLevel'] as int? ?? 0,
      triggeredAt: (data['triggeredAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      actionTaken: data['actionTaken'] as String? ?? 'none',
      notes: data['notes'] as String?,
    );
  }
}
