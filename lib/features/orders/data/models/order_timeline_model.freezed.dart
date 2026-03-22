// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_timeline_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderTimelineModel _$OrderTimelineModelFromJson(Map<String, dynamic> json) {
  return _OrderTimelineModel.fromJson(json);
}

/// @nodoc
mixin _$OrderTimelineModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  int get stageNumber => throw _privateConstructorUsedError;
  String get stageKey => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get detail => throw _privateConstructorUsedError;
  String? get actionLabel => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  String? get actionTargetId => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get activatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderTimelineModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderTimelineModelCopyWith<OrderTimelineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderTimelineModelCopyWith<$Res> {
  factory $OrderTimelineModelCopyWith(
    OrderTimelineModel value,
    $Res Function(OrderTimelineModel) then,
  ) = _$OrderTimelineModelCopyWithImpl<$Res, OrderTimelineModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    int stageNumber,
    String stageKey,
    String label,
    String? detail,
    String? actionLabel,
    String actionType,
    String? actionTargetId,
    bool isComplete,
    bool isActive,
    bool isBlocked,
    DateTime? completedAt,
    DateTime? activatedAt,
  });
}

/// @nodoc
class _$OrderTimelineModelCopyWithImpl<$Res, $Val extends OrderTimelineModel>
    implements $OrderTimelineModelCopyWith<$Res> {
  _$OrderTimelineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? stageNumber = null,
    Object? stageKey = null,
    Object? label = null,
    Object? detail = freezed,
    Object? actionLabel = freezed,
    Object? actionType = null,
    Object? actionTargetId = freezed,
    Object? isComplete = null,
    Object? isActive = null,
    Object? isBlocked = null,
    Object? completedAt = freezed,
    Object? activatedAt = freezed,
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
            stageNumber: null == stageNumber
                ? _value.stageNumber
                : stageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            stageKey: null == stageKey
                ? _value.stageKey
                : stageKey // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            detail: freezed == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionLabel: freezed == actionLabel
                ? _value.actionLabel
                : actionLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            actionType: null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as String,
            actionTargetId: freezed == actionTargetId
                ? _value.actionTargetId
                : actionTargetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isComplete: null == isComplete
                ? _value.isComplete
                : isComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBlocked: null == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            activatedAt: freezed == activatedAt
                ? _value.activatedAt
                : activatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderTimelineModelImplCopyWith<$Res>
    implements $OrderTimelineModelCopyWith<$Res> {
  factory _$$OrderTimelineModelImplCopyWith(
    _$OrderTimelineModelImpl value,
    $Res Function(_$OrderTimelineModelImpl) then,
  ) = __$$OrderTimelineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    int stageNumber,
    String stageKey,
    String label,
    String? detail,
    String? actionLabel,
    String actionType,
    String? actionTargetId,
    bool isComplete,
    bool isActive,
    bool isBlocked,
    DateTime? completedAt,
    DateTime? activatedAt,
  });
}

/// @nodoc
class __$$OrderTimelineModelImplCopyWithImpl<$Res>
    extends _$OrderTimelineModelCopyWithImpl<$Res, _$OrderTimelineModelImpl>
    implements _$$OrderTimelineModelImplCopyWith<$Res> {
  __$$OrderTimelineModelImplCopyWithImpl(
    _$OrderTimelineModelImpl _value,
    $Res Function(_$OrderTimelineModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? stageNumber = null,
    Object? stageKey = null,
    Object? label = null,
    Object? detail = freezed,
    Object? actionLabel = freezed,
    Object? actionType = null,
    Object? actionTargetId = freezed,
    Object? isComplete = null,
    Object? isActive = null,
    Object? isBlocked = null,
    Object? completedAt = freezed,
    Object? activatedAt = freezed,
  }) {
    return _then(
      _$OrderTimelineModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        stageNumber: null == stageNumber
            ? _value.stageNumber
            : stageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        stageKey: null == stageKey
            ? _value.stageKey
            : stageKey // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        detail: freezed == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionLabel: freezed == actionLabel
            ? _value.actionLabel
            : actionLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        actionType: null == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as String,
        actionTargetId: freezed == actionTargetId
            ? _value.actionTargetId
            : actionTargetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isComplete: null == isComplete
            ? _value.isComplete
            : isComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBlocked: null == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        activatedAt: freezed == activatedAt
            ? _value.activatedAt
            : activatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderTimelineModelImpl implements _OrderTimelineModel {
  const _$OrderTimelineModelImpl({
    required this.id,
    required this.orderId,
    required this.stageNumber,
    required this.stageKey,
    required this.label,
    this.detail,
    this.actionLabel,
    this.actionType = 'none',
    this.actionTargetId,
    this.isComplete = false,
    this.isActive = false,
    this.isBlocked = false,
    this.completedAt,
    this.activatedAt,
  });

  factory _$OrderTimelineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderTimelineModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final int stageNumber;
  @override
  final String stageKey;
  @override
  final String label;
  @override
  final String? detail;
  @override
  final String? actionLabel;
  @override
  @JsonKey()
  final String actionType;
  @override
  final String? actionTargetId;
  @override
  @JsonKey()
  final bool isComplete;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? activatedAt;

  @override
  String toString() {
    return 'OrderTimelineModel(id: $id, orderId: $orderId, stageNumber: $stageNumber, stageKey: $stageKey, label: $label, detail: $detail, actionLabel: $actionLabel, actionType: $actionType, actionTargetId: $actionTargetId, isComplete: $isComplete, isActive: $isActive, isBlocked: $isBlocked, completedAt: $completedAt, activatedAt: $activatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderTimelineModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.stageNumber, stageNumber) ||
                other.stageNumber == stageNumber) &&
            (identical(other.stageKey, stageKey) ||
                other.stageKey == stageKey) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.actionLabel, actionLabel) ||
                other.actionLabel == actionLabel) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.actionTargetId, actionTargetId) ||
                other.actionTargetId == actionTargetId) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.activatedAt, activatedAt) ||
                other.activatedAt == activatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    stageNumber,
    stageKey,
    label,
    detail,
    actionLabel,
    actionType,
    actionTargetId,
    isComplete,
    isActive,
    isBlocked,
    completedAt,
    activatedAt,
  );

  /// Create a copy of OrderTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderTimelineModelImplCopyWith<_$OrderTimelineModelImpl> get copyWith =>
      __$$OrderTimelineModelImplCopyWithImpl<_$OrderTimelineModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderTimelineModelImplToJson(this);
  }
}

abstract class _OrderTimelineModel implements OrderTimelineModel {
  const factory _OrderTimelineModel({
    required final String id,
    required final String orderId,
    required final int stageNumber,
    required final String stageKey,
    required final String label,
    final String? detail,
    final String? actionLabel,
    final String actionType,
    final String? actionTargetId,
    final bool isComplete,
    final bool isActive,
    final bool isBlocked,
    final DateTime? completedAt,
    final DateTime? activatedAt,
  }) = _$OrderTimelineModelImpl;

  factory _OrderTimelineModel.fromJson(Map<String, dynamic> json) =
      _$OrderTimelineModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  int get stageNumber;
  @override
  String get stageKey;
  @override
  String get label;
  @override
  String? get detail;
  @override
  String? get actionLabel;
  @override
  String get actionType;
  @override
  String? get actionTargetId;
  @override
  bool get isComplete;
  @override
  bool get isActive;
  @override
  bool get isBlocked;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get activatedAt;

  /// Create a copy of OrderTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderTimelineModelImplCopyWith<_$OrderTimelineModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
