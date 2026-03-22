// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgentModel _$AgentModelFromJson(Map<String, dynamic> json) {
  return _AgentModel.fromJson(json);
}

/// @nodoc
mixin _$AgentModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get employeeId => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // active|inactive|suspended
  int get maxActiveOrders => throw _privateConstructorUsedError;
  int get totalOrdersCompleted => throw _privateConstructorUsedError;
  double get successRate => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AgentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentModelCopyWith<AgentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentModelCopyWith<$Res> {
  factory $AgentModelCopyWith(
    AgentModel value,
    $Res Function(AgentModel) then,
  ) = _$AgentModelCopyWithImpl<$Res, AgentModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? employeeId,
    String status,
    int maxActiveOrders,
    int totalOrdersCompleted,
    double successRate,
    double rating,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AgentModelCopyWithImpl<$Res, $Val extends AgentModel>
    implements $AgentModelCopyWith<$Res> {
  _$AgentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? employeeId = freezed,
    Object? status = null,
    Object? maxActiveOrders = null,
    Object? totalOrdersCompleted = null,
    Object? successRate = null,
    Object? rating = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: freezed == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            maxActiveOrders: null == maxActiveOrders
                ? _value.maxActiveOrders
                : maxActiveOrders // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOrdersCompleted: null == totalOrdersCompleted
                ? _value.totalOrdersCompleted
                : totalOrdersCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            successRate: null == successRate
                ? _value.successRate
                : successRate // ignore: cast_nullable_to_non_nullable
                      as double,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$AgentModelImplCopyWith<$Res>
    implements $AgentModelCopyWith<$Res> {
  factory _$$AgentModelImplCopyWith(
    _$AgentModelImpl value,
    $Res Function(_$AgentModelImpl) then,
  ) = __$$AgentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? employeeId,
    String status,
    int maxActiveOrders,
    int totalOrdersCompleted,
    double successRate,
    double rating,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AgentModelImplCopyWithImpl<$Res>
    extends _$AgentModelCopyWithImpl<$Res, _$AgentModelImpl>
    implements _$$AgentModelImplCopyWith<$Res> {
  __$$AgentModelImplCopyWithImpl(
    _$AgentModelImpl _value,
    $Res Function(_$AgentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? employeeId = freezed,
    Object? status = null,
    Object? maxActiveOrders = null,
    Object? totalOrdersCompleted = null,
    Object? successRate = null,
    Object? rating = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AgentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: freezed == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        maxActiveOrders: null == maxActiveOrders
            ? _value.maxActiveOrders
            : maxActiveOrders // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOrdersCompleted: null == totalOrdersCompleted
            ? _value.totalOrdersCompleted
            : totalOrdersCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        successRate: null == successRate
            ? _value.successRate
            : successRate // ignore: cast_nullable_to_non_nullable
                  as double,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$AgentModelImpl implements _AgentModel {
  const _$AgentModelImpl({
    required this.id,
    required this.userId,
    this.employeeId,
    this.status = 'active',
    this.maxActiveOrders = 15,
    this.totalOrdersCompleted = 0,
    this.successRate = 0.0,
    this.rating = 0.0,
    this.createdAt,
  });

  factory _$AgentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? employeeId;
  @override
  @JsonKey()
  final String status;
  // active|inactive|suspended
  @override
  @JsonKey()
  final int maxActiveOrders;
  @override
  @JsonKey()
  final int totalOrdersCompleted;
  @override
  @JsonKey()
  final double successRate;
  @override
  @JsonKey()
  final double rating;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AgentModel(id: $id, userId: $userId, employeeId: $employeeId, status: $status, maxActiveOrders: $maxActiveOrders, totalOrdersCompleted: $totalOrdersCompleted, successRate: $successRate, rating: $rating, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.maxActiveOrders, maxActiveOrders) ||
                other.maxActiveOrders == maxActiveOrders) &&
            (identical(other.totalOrdersCompleted, totalOrdersCompleted) ||
                other.totalOrdersCompleted == totalOrdersCompleted) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    employeeId,
    status,
    maxActiveOrders,
    totalOrdersCompleted,
    successRate,
    rating,
    createdAt,
  );

  /// Create a copy of AgentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentModelImplCopyWith<_$AgentModelImpl> get copyWith =>
      __$$AgentModelImplCopyWithImpl<_$AgentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentModelImplToJson(this);
  }
}

abstract class _AgentModel implements AgentModel {
  const factory _AgentModel({
    required final String id,
    required final String userId,
    final String? employeeId,
    final String status,
    final int maxActiveOrders,
    final int totalOrdersCompleted,
    final double successRate,
    final double rating,
    final DateTime? createdAt,
  }) = _$AgentModelImpl;

  factory _AgentModel.fromJson(Map<String, dynamic> json) =
      _$AgentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get employeeId;
  @override
  String get status; // active|inactive|suspended
  @override
  int get maxActiveOrders;
  @override
  int get totalOrdersCompleted;
  @override
  double get successRate;
  @override
  double get rating;
  @override
  DateTime? get createdAt;

  /// Create a copy of AgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentModelImplCopyWith<_$AgentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
