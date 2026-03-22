import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../profile/domain/entities/user_session_entity.dart';

part 'user_session_model.freezed.dart';
part 'user_session_model.g.dart';

@freezed
class UserSessionModel with _$UserSessionModel {
  const factory UserSessionModel({
    required String id,
    required String userId,
    String? deviceToken,
    String? sessionToken,
    required String role,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    DateTime? createdAt,
  }) = _UserSessionModel;

  factory UserSessionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSessionModelFromJson(json);

  factory UserSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserSessionModel(
        id: doc.id,
        userId: '',
        role: '',
      );
    }
    return UserSessionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      deviceToken: data['deviceToken'] as String?,
      sessionToken: data['sessionToken'] as String?,
      role: data['role'] as String? ?? '',
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      lastUsedAt: (data['lastUsedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension UserSessionModelEntityX on UserSessionModel {
  UserSessionEntity toEntity() => UserSessionEntity(
        id: id,
        userId: userId,
        deviceToken: deviceToken,
        lastUsedAt: lastUsedAt,
        expiresAt: expiresAt,
      );
}
