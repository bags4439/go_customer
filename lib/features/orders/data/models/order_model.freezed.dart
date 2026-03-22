// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get orderRef => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String? get agentId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  OrderStatus get status => throw _privateConstructorUsedError;
  String? get currentStage => throw _privateConstructorUsedError;
  int get stageNumber => throw _privateConstructorUsedError;
  bool get firstPaymentMade => throw _privateConstructorUsedError;
  String? get cancelledBy => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get cancellationNote => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    String orderRef,
    String buyerId,
    String? agentId,
    @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
    OrderStatus status,
    String? currentStage,
    int stageNumber,
    bool firstPaymentMade,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationNote,
    DateTime? cancelledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderRef = null,
    Object? buyerId = null,
    Object? agentId = freezed,
    Object? status = null,
    Object? currentStage = freezed,
    Object? stageNumber = null,
    Object? firstPaymentMade = null,
    Object? cancelledBy = freezed,
    Object? cancellationReason = freezed,
    Object? cancellationNote = freezed,
    Object? cancelledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderRef: null == orderRef
                ? _value.orderRef
                : orderRef // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentId: freezed == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            currentStage: freezed == currentStage
                ? _value.currentStage
                : currentStage // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageNumber: null == stageNumber
                ? _value.stageNumber
                : stageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            firstPaymentMade: null == firstPaymentMade
                ? _value.firstPaymentMade
                : firstPaymentMade // ignore: cast_nullable_to_non_nullable
                      as bool,
            cancelledBy: freezed == cancelledBy
                ? _value.cancelledBy
                : cancelledBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationNote: freezed == cancellationNote
                ? _value.cancellationNote
                : cancellationNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderRef,
    String buyerId,
    String? agentId,
    @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
    OrderStatus status,
    String? currentStage,
    int stageNumber,
    bool firstPaymentMade,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationNote,
    DateTime? cancelledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderRef = null,
    Object? buyerId = null,
    Object? agentId = freezed,
    Object? status = null,
    Object? currentStage = freezed,
    Object? stageNumber = null,
    Object? firstPaymentMade = null,
    Object? cancelledBy = freezed,
    Object? cancellationReason = freezed,
    Object? cancellationNote = freezed,
    Object? cancelledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$OrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderRef: null == orderRef
            ? _value.orderRef
            : orderRef // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: freezed == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        currentStage: freezed == currentStage
            ? _value.currentStage
            : currentStage // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageNumber: null == stageNumber
            ? _value.stageNumber
            : stageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        firstPaymentMade: null == firstPaymentMade
            ? _value.firstPaymentMade
            : firstPaymentMade // ignore: cast_nullable_to_non_nullable
                  as bool,
        cancelledBy: freezed == cancelledBy
            ? _value.cancelledBy
            : cancelledBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationNote: freezed == cancellationNote
            ? _value.cancellationNote
            : cancellationNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    required this.orderRef,
    required this.buyerId,
    this.agentId,
    @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
    this.status = OrderStatus.open,
    this.currentStage,
    this.stageNumber = 1,
    this.firstPaymentMade = false,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationNote,
    this.cancelledAt,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderRef;
  @override
  final String buyerId;
  @override
  final String? agentId;
  @override
  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  final OrderStatus status;
  @override
  final String? currentStage;
  @override
  @JsonKey()
  final int stageNumber;
  @override
  @JsonKey()
  final bool firstPaymentMade;
  @override
  final String? cancelledBy;
  @override
  final String? cancellationReason;
  @override
  final String? cancellationNote;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderRef: $orderRef, buyerId: $buyerId, agentId: $agentId, status: $status, currentStage: $currentStage, stageNumber: $stageNumber, firstPaymentMade: $firstPaymentMade, cancelledBy: $cancelledBy, cancellationReason: $cancellationReason, cancellationNote: $cancellationNote, cancelledAt: $cancelledAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderRef, orderRef) ||
                other.orderRef == orderRef) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.stageNumber, stageNumber) ||
                other.stageNumber == stageNumber) &&
            (identical(other.firstPaymentMade, firstPaymentMade) ||
                other.firstPaymentMade == firstPaymentMade) &&
            (identical(other.cancelledBy, cancelledBy) ||
                other.cancelledBy == cancelledBy) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.cancellationNote, cancellationNote) ||
                other.cancellationNote == cancellationNote) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderRef,
    buyerId,
    agentId,
    status,
    currentStage,
    stageNumber,
    firstPaymentMade,
    cancelledBy,
    cancellationReason,
    cancellationNote,
    cancelledAt,
    deliveredAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(this);
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel({
    required final String id,
    required final String orderRef,
    required final String buyerId,
    final String? agentId,
    @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
    final OrderStatus status,
    final String? currentStage,
    final int stageNumber,
    final bool firstPaymentMade,
    final String? cancelledBy,
    final String? cancellationReason,
    final String? cancellationNote,
    final DateTime? cancelledAt,
    final DateTime? deliveredAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderRef;
  @override
  String get buyerId;
  @override
  String? get agentId;
  @override
  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  OrderStatus get status;
  @override
  String? get currentStage;
  @override
  int get stageNumber;
  @override
  bool get firstPaymentMade;
  @override
  String? get cancelledBy;
  @override
  String? get cancellationReason;
  @override
  String? get cancellationNote;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
