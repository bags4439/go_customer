import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preference_edit_history_model.freezed.dart';
part 'preference_edit_history_model.g.dart';

@freezed
class PreferenceEditHistoryModel with _$PreferenceEditHistoryModel {
  const factory PreferenceEditHistoryModel({
    required String id,
    required String orderId,
    required String editedByUserId,
    required String editedByRole, // 'buyer' | 'agent'
    Map<String, dynamic>? previousValuesJson,
    Map<String, dynamic>? newValuesJson,
    String? reason,
    @Default(false) bool buyerNotified,
    DateTime? editedAt,
  }) = _PreferenceEditHistoryModel;

  factory PreferenceEditHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PreferenceEditHistoryModelFromJson(json);

  factory PreferenceEditHistoryModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return PreferenceEditHistoryModel(
        id: doc.id,
        orderId: '',
        editedByUserId: '',
        editedByRole: 'buyer',
      );
    }
    return PreferenceEditHistoryModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      editedByUserId: data['editedByUserId'] as String? ?? '',
      editedByRole: data['editedByRole'] as String? ?? 'buyer',
      previousValuesJson:
          data['previousValuesJson'] as Map<String, dynamic>?,
      newValuesJson:
          data['newValuesJson'] as Map<String, dynamic>?,
      reason: data['reason'] as String?,
      buyerNotified: data['buyerNotified'] as bool? ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
    );
  }
}
