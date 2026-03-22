// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderRole =>
      throw _privateConstructorUsedError; // 'agent' | 'buyer'
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  MessageType get messageType => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  int? get mediaDurationSecs => throw _privateConstructorUsedError;
  String? get mediaFileName => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get vehicleOptionId => throw _privateConstructorUsedError;
  String? get paymentRequestId => throw _privateConstructorUsedError;
  String? get bidOutcomeId => throw _privateConstructorUsedError;
  String? get shippingId => throw _privateConstructorUsedError;
  String? get replyToMessageId => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
    MessageModel value,
    $Res Function(MessageModel) then,
  ) = _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String senderId,
    String senderRole,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    MessageType messageType,
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
    bool isRead,
    bool isDeleted,
    @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
    DateTime? deletedAt,
    DateTime? sentAt,
  });
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? messageType = null,
    Object? body = freezed,
    Object? mediaUrl = freezed,
    Object? mediaDurationSecs = freezed,
    Object? mediaFileName = freezed,
    Object? thumbnailUrl = freezed,
    Object? vehicleOptionId = freezed,
    Object? paymentRequestId = freezed,
    Object? bidOutcomeId = freezed,
    Object? shippingId = freezed,
    Object? replyToMessageId = freezed,
    Object? isRead = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? sentAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderRole: null == senderRole
                ? _value.senderRole
                : senderRole // ignore: cast_nullable_to_non_nullable
                      as String,
            messageType: null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaUrl: freezed == mediaUrl
                ? _value.mediaUrl
                : mediaUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaDurationSecs: freezed == mediaDurationSecs
                ? _value.mediaDurationSecs
                : mediaDurationSecs // ignore: cast_nullable_to_non_nullable
                      as int?,
            mediaFileName: freezed == mediaFileName
                ? _value.mediaFileName
                : mediaFileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleOptionId: freezed == vehicleOptionId
                ? _value.vehicleOptionId
                : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentRequestId: freezed == paymentRequestId
                ? _value.paymentRequestId
                : paymentRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            bidOutcomeId: freezed == bidOutcomeId
                ? _value.bidOutcomeId
                : bidOutcomeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shippingId: freezed == shippingId
                ? _value.shippingId
                : shippingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            replyToMessageId: freezed == replyToMessageId
                ? _value.replyToMessageId
                : replyToMessageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
    _$MessageModelImpl value,
    $Res Function(_$MessageModelImpl) then,
  ) = __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String senderId,
    String senderRole,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    MessageType messageType,
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
    bool isRead,
    bool isDeleted,
    @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
    DateTime? deletedAt,
    DateTime? sentAt,
  });
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
    _$MessageModelImpl _value,
    $Res Function(_$MessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? messageType = null,
    Object? body = freezed,
    Object? mediaUrl = freezed,
    Object? mediaDurationSecs = freezed,
    Object? mediaFileName = freezed,
    Object? thumbnailUrl = freezed,
    Object? vehicleOptionId = freezed,
    Object? paymentRequestId = freezed,
    Object? bidOutcomeId = freezed,
    Object? shippingId = freezed,
    Object? replyToMessageId = freezed,
    Object? isRead = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? sentAt = freezed,
  }) {
    return _then(
      _$MessageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderRole: null == senderRole
            ? _value.senderRole
            : senderRole // ignore: cast_nullable_to_non_nullable
                  as String,
        messageType: null == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaUrl: freezed == mediaUrl
            ? _value.mediaUrl
            : mediaUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaDurationSecs: freezed == mediaDurationSecs
            ? _value.mediaDurationSecs
            : mediaDurationSecs // ignore: cast_nullable_to_non_nullable
                  as int?,
        mediaFileName: freezed == mediaFileName
            ? _value.mediaFileName
            : mediaFileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleOptionId: freezed == vehicleOptionId
            ? _value.vehicleOptionId
            : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentRequestId: freezed == paymentRequestId
            ? _value.paymentRequestId
            : paymentRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        bidOutcomeId: freezed == bidOutcomeId
            ? _value.bidOutcomeId
            : bidOutcomeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shippingId: freezed == shippingId
            ? _value.shippingId
            : shippingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        replyToMessageId: freezed == replyToMessageId
            ? _value.replyToMessageId
            : replyToMessageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderRole,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    required this.messageType,
    this.body,
    this.mediaUrl,
    this.mediaDurationSecs,
    this.mediaFileName,
    this.thumbnailUrl,
    this.vehicleOptionId,
    this.paymentRequestId,
    this.bidOutcomeId,
    this.shippingId,
    this.replyToMessageId,
    this.isRead = false,
    this.isDeleted = false,
    @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
    this.deletedAt,
    this.sentAt,
  });

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String senderId;
  @override
  final String senderRole;
  // 'agent' | 'buyer'
  @override
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  final MessageType messageType;
  @override
  final String? body;
  @override
  final String? mediaUrl;
  @override
  final int? mediaDurationSecs;
  @override
  final String? mediaFileName;
  @override
  final String? thumbnailUrl;
  @override
  final String? vehicleOptionId;
  @override
  final String? paymentRequestId;
  @override
  final String? bidOutcomeId;
  @override
  final String? shippingId;
  @override
  final String? replyToMessageId;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
  final DateTime? deletedAt;
  @override
  final DateTime? sentAt;

  @override
  String toString() {
    return 'MessageModel(id: $id, orderId: $orderId, senderId: $senderId, senderRole: $senderRole, messageType: $messageType, body: $body, mediaUrl: $mediaUrl, mediaDurationSecs: $mediaDurationSecs, mediaFileName: $mediaFileName, thumbnailUrl: $thumbnailUrl, vehicleOptionId: $vehicleOptionId, paymentRequestId: $paymentRequestId, bidOutcomeId: $bidOutcomeId, shippingId: $shippingId, replyToMessageId: $replyToMessageId, isRead: $isRead, isDeleted: $isDeleted, deletedAt: $deletedAt, sentAt: $sentAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.mediaDurationSecs, mediaDurationSecs) ||
                other.mediaDurationSecs == mediaDurationSecs) &&
            (identical(other.mediaFileName, mediaFileName) ||
                other.mediaFileName == mediaFileName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.vehicleOptionId, vehicleOptionId) ||
                other.vehicleOptionId == vehicleOptionId) &&
            (identical(other.paymentRequestId, paymentRequestId) ||
                other.paymentRequestId == paymentRequestId) &&
            (identical(other.bidOutcomeId, bidOutcomeId) ||
                other.bidOutcomeId == bidOutcomeId) &&
            (identical(other.shippingId, shippingId) ||
                other.shippingId == shippingId) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    senderId,
    senderRole,
    messageType,
    body,
    mediaUrl,
    mediaDurationSecs,
    mediaFileName,
    thumbnailUrl,
    vehicleOptionId,
    paymentRequestId,
    bidOutcomeId,
    shippingId,
    replyToMessageId,
    isRead,
    isDeleted,
    deletedAt,
    sentAt,
  ]);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(this);
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel({
    required final String id,
    required final String orderId,
    required final String senderId,
    required final String senderRole,
    @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
    required final MessageType messageType,
    final String? body,
    final String? mediaUrl,
    final int? mediaDurationSecs,
    final String? mediaFileName,
    final String? thumbnailUrl,
    final String? vehicleOptionId,
    final String? paymentRequestId,
    final String? bidOutcomeId,
    final String? shippingId,
    final String? replyToMessageId,
    final bool isRead,
    final bool isDeleted,
    @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
    final DateTime? deletedAt,
    final DateTime? sentAt,
  }) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get senderId;
  @override
  String get senderRole; // 'agent' | 'buyer'
  @override
  @JsonKey(fromJson: _messageTypeFromJson, toJson: _messageTypeToJson)
  MessageType get messageType;
  @override
  String? get body;
  @override
  String? get mediaUrl;
  @override
  int? get mediaDurationSecs;
  @override
  String? get mediaFileName;
  @override
  String? get thumbnailUrl;
  @override
  String? get vehicleOptionId;
  @override
  String? get paymentRequestId;
  @override
  String? get bidOutcomeId;
  @override
  String? get shippingId;
  @override
  String? get replyToMessageId;
  @override
  bool get isRead;
  @override
  bool get isDeleted;
  @override
  @JsonKey(fromJson: _msgDateTimeFromJson, toJson: _msgDateTimeToJson)
  DateTime? get deletedAt;
  @override
  DateTime? get sentAt;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
