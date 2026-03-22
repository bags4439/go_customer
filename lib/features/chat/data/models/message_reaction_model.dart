import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_reaction_model.freezed.dart';
part 'message_reaction_model.g.dart';

@freezed
class MessageReactionModel with _$MessageReactionModel {
  const factory MessageReactionModel({
    required String id,
    required String messageId,
    required String userId,
    required String emoji,
    DateTime? createdAt,
  }) = _MessageReactionModel;

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionModelFromJson(json);

  factory MessageReactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MessageReactionModel(
        id: doc.id,
        messageId: '',
        userId: '',
        emoji: '',
      );
    }
    return MessageReactionModel(
      id: doc.id,
      messageId: data['messageId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
