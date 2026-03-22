// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSessionModelImpl _$$UserSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserSessionModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  deviceToken: json['deviceToken'] as String?,
  sessionToken: json['sessionToken'] as String?,
  role: json['role'] as String,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$UserSessionModelImplToJson(
  _$UserSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'deviceToken': instance.deviceToken,
  'sessionToken': instance.sessionToken,
  'role': instance.role,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};
