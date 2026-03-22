// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buyer_review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BuyerReviewModel _$BuyerReviewModelFromJson(Map<String, dynamic> json) {
  return _BuyerReviewModel.fromJson(json);
}

/// @nodoc
mixin _$BuyerReviewModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  double get overallRating => throw _privateConstructorUsedError;
  double get agentRating => throw _privateConstructorUsedError;
  double get communicationRating => throw _privateConstructorUsedError;
  double get speedRating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BuyerReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuyerReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuyerReviewModelCopyWith<BuyerReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuyerReviewModelCopyWith<$Res> {
  factory $BuyerReviewModelCopyWith(
    BuyerReviewModel value,
    $Res Function(BuyerReviewModel) then,
  ) = _$BuyerReviewModelCopyWithImpl<$Res, BuyerReviewModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String buyerId,
    String agentId,
    double overallRating,
    double agentRating,
    double communicationRating,
    double speedRating,
    String? comment,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$BuyerReviewModelCopyWithImpl<$Res, $Val extends BuyerReviewModel>
    implements $BuyerReviewModelCopyWith<$Res> {
  _$BuyerReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuyerReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? buyerId = null,
    Object? agentId = null,
    Object? overallRating = null,
    Object? agentRating = null,
    Object? communicationRating = null,
    Object? speedRating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
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
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            overallRating: null == overallRating
                ? _value.overallRating
                : overallRating // ignore: cast_nullable_to_non_nullable
                      as double,
            agentRating: null == agentRating
                ? _value.agentRating
                : agentRating // ignore: cast_nullable_to_non_nullable
                      as double,
            communicationRating: null == communicationRating
                ? _value.communicationRating
                : communicationRating // ignore: cast_nullable_to_non_nullable
                      as double,
            speedRating: null == speedRating
                ? _value.speedRating
                : speedRating // ignore: cast_nullable_to_non_nullable
                      as double,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BuyerReviewModelImplCopyWith<$Res>
    implements $BuyerReviewModelCopyWith<$Res> {
  factory _$$BuyerReviewModelImplCopyWith(
    _$BuyerReviewModelImpl value,
    $Res Function(_$BuyerReviewModelImpl) then,
  ) = __$$BuyerReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String buyerId,
    String agentId,
    double overallRating,
    double agentRating,
    double communicationRating,
    double speedRating,
    String? comment,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$BuyerReviewModelImplCopyWithImpl<$Res>
    extends _$BuyerReviewModelCopyWithImpl<$Res, _$BuyerReviewModelImpl>
    implements _$$BuyerReviewModelImplCopyWith<$Res> {
  __$$BuyerReviewModelImplCopyWithImpl(
    _$BuyerReviewModelImpl _value,
    $Res Function(_$BuyerReviewModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BuyerReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? buyerId = null,
    Object? agentId = null,
    Object? overallRating = null,
    Object? agentRating = null,
    Object? communicationRating = null,
    Object? speedRating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$BuyerReviewModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        overallRating: null == overallRating
            ? _value.overallRating
            : overallRating // ignore: cast_nullable_to_non_nullable
                  as double,
        agentRating: null == agentRating
            ? _value.agentRating
            : agentRating // ignore: cast_nullable_to_non_nullable
                  as double,
        communicationRating: null == communicationRating
            ? _value.communicationRating
            : communicationRating // ignore: cast_nullable_to_non_nullable
                  as double,
        speedRating: null == speedRating
            ? _value.speedRating
            : speedRating // ignore: cast_nullable_to_non_nullable
                  as double,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BuyerReviewModelImpl implements _BuyerReviewModel {
  const _$BuyerReviewModelImpl({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.agentId,
    required this.overallRating,
    required this.agentRating,
    required this.communicationRating,
    required this.speedRating,
    this.comment,
    this.createdAt,
  });

  factory _$BuyerReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuyerReviewModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String buyerId;
  @override
  final String agentId;
  @override
  final double overallRating;
  @override
  final double agentRating;
  @override
  final double communicationRating;
  @override
  final double speedRating;
  @override
  final String? comment;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'BuyerReviewModel(id: $id, orderId: $orderId, buyerId: $buyerId, agentId: $agentId, overallRating: $overallRating, agentRating: $agentRating, communicationRating: $communicationRating, speedRating: $speedRating, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuyerReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.overallRating, overallRating) ||
                other.overallRating == overallRating) &&
            (identical(other.agentRating, agentRating) ||
                other.agentRating == agentRating) &&
            (identical(other.communicationRating, communicationRating) ||
                other.communicationRating == communicationRating) &&
            (identical(other.speedRating, speedRating) ||
                other.speedRating == speedRating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    buyerId,
    agentId,
    overallRating,
    agentRating,
    communicationRating,
    speedRating,
    comment,
    createdAt,
  );

  /// Create a copy of BuyerReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuyerReviewModelImplCopyWith<_$BuyerReviewModelImpl> get copyWith =>
      __$$BuyerReviewModelImplCopyWithImpl<_$BuyerReviewModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BuyerReviewModelImplToJson(this);
  }
}

abstract class _BuyerReviewModel implements BuyerReviewModel {
  const factory _BuyerReviewModel({
    required final String id,
    required final String orderId,
    required final String buyerId,
    required final String agentId,
    required final double overallRating,
    required final double agentRating,
    required final double communicationRating,
    required final double speedRating,
    final String? comment,
    final DateTime? createdAt,
  }) = _$BuyerReviewModelImpl;

  factory _BuyerReviewModel.fromJson(Map<String, dynamic> json) =
      _$BuyerReviewModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get buyerId;
  @override
  String get agentId;
  @override
  double get overallRating;
  @override
  double get agentRating;
  @override
  double get communicationRating;
  @override
  double get speedRating;
  @override
  String? get comment;
  @override
  DateTime? get createdAt;

  /// Create a copy of BuyerReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuyerReviewModelImplCopyWith<_$BuyerReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
