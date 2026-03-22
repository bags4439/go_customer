// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType {
  text,
  voiceNote,
  image,
  file,
  video,
  vehicleCard,
  paymentRequest,
  paymentConfirmed,
  bidWon,
  bidLost,
  shippingUpdate,
  stageUpdate,
  system;

  static MessageType fromString(String v) {
    const map = <String, MessageType>{
      'text': MessageType.text,
      'voice_note': MessageType.voiceNote,
      'image': MessageType.image,
      'file': MessageType.file,
      'video': MessageType.video,
      'vehicle_card': MessageType.vehicleCard,
      'payment_request': MessageType.paymentRequest,
      'payment_confirmed': MessageType.paymentConfirmed,
      'bid_won': MessageType.bidWon,
      'bid_lost': MessageType.bidLost,
      'shipping_update': MessageType.shippingUpdate,
      'stage_update': MessageType.stageUpdate,
      'system': MessageType.system,
    };
    return map[v] ?? MessageType.text;
  }

  String get firestoreValue {
    const map = <MessageType, String>{
      MessageType.text: 'text',
      MessageType.voiceNote: 'voice_note',
      MessageType.image: 'image',
      MessageType.file: 'file',
      MessageType.video: 'video',
      MessageType.vehicleCard: 'vehicle_card',
      MessageType.paymentRequest: 'payment_request',
      MessageType.paymentConfirmed: 'payment_confirmed',
      MessageType.bidWon: 'bid_won',
      MessageType.bidLost: 'bid_lost',
      MessageType.shippingUpdate: 'shipping_update',
      MessageType.stageUpdate: 'stage_update',
      MessageType.system: 'system',
    };
    return map[this] ?? 'text';
  }

  bool get isMediaType => [
        MessageType.image,
        MessageType.video,
        MessageType.voiceNote,
        MessageType.file,
      ].contains(this);

  bool get isSystemType => [
        MessageType.bidWon,
        MessageType.bidLost,
        MessageType.paymentRequest,
        MessageType.paymentConfirmed,
        MessageType.vehicleCard,
        MessageType.shippingUpdate,
        MessageType.stageUpdate,
        MessageType.system,
      ].contains(this);
}

MessageType _messageTypeFromJson(Object? json) =>
    MessageType.fromString(json as String? ?? 'text');

String _messageTypeToJson(MessageType t) => t.firestoreValue;

DateTime? _msgDateTimeFromJson(Object? v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Object? _msgDateTimeToJson(DateTime? d) => d?.toIso8601String();

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String orderId,
    required String senderId,
    required String senderRole, // 'agent' | 'buyer'
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    required MessageType messageType,
    String? body,
    String? mediaUrl,
    int? mediaDurationSecs,
    String? mediaFileName,
    String? thumbnailUrl,
    String? vehicleOptionId,
    String? paymentRequestId,
    String? bidOutcomeId,
    String? shippingId,
    String? replyToMessageId,
    @Default(false) bool isRead,
    @Default(false) bool isDeleted,
    @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
    DateTime? deletedAt,
    DateTime? sentAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MessageModel(
        id: doc.id,
        orderId: '',
        senderId: '',
        senderRole: 'buyer',
        messageType: MessageType.text,
      );
    }
    return MessageModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? 'buyer',
      messageType: MessageType.fromString(
        data['messageType'] as String? ?? 'text',
      ),
      body: data['body'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      mediaDurationSecs: data['mediaDurationSecs'] as int?,
      mediaFileName: data['mediaFileName'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      vehicleOptionId: data['vehicleOptionId'] as String?,
      paymentRequestId: data['paymentRequestId'] as String?,
      bidOutcomeId: data['bidOutcomeId'] as String?,
      shippingId: data['shippingId'] as String?,
      replyToMessageId: data['replyToMessageId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
    );
  }
}
