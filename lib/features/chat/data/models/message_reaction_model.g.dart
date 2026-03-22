// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_reaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageReactionModelImpl _$$MessageReactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReactionModelImpl(
  id: json['id'] as String,
  messageId: json['messageId'] as String,
  userId: json['userId'] as String,
  emoji: json['emoji'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MessageReactionModelImplToJson(
  _$MessageReactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'messageId': instance.messageId,
  'userId': instance.userId,
  'emoji': instance.emoji,
  'createdAt': instance.createdAt?.toIso8601String(),
};
