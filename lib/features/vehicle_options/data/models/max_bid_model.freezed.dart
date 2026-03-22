// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'max_bid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaxBidModel _$MaxBidModelFromJson(Map<String, dynamic> json) {
  return _MaxBidModel.fromJson(json);
}

/// @nodoc
mixin _$MaxBidModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get vehicleOptionId => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  double get maxBidUsd => throw _privateConstructorUsedError;
  double get maxBidGhs => throw _privateConstructorUsedError;
  double get exchangeRate => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  bool get agentNotified => throw _privateConstructorUsedError;
  DateTime? get agentNotifiedAt => throw _privateConstructorUsedError;

  /// Serializes this MaxBidModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaxBidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaxBidModelCopyWith<MaxBidModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaxBidModelCopyWith<$Res> {
  factory $MaxBidModelCopyWith(
    MaxBidModel value,
    $Res Function(MaxBidModel) then,
  ) = _$MaxBidModelCopyWithImpl<$Res, MaxBidModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String vehicleOptionId,
    String buyerId,
    double maxBidUsd,
    double maxBidGhs,
    double exchangeRate,
    DateTime? confirmedAt,
    bool agentNotified,
    DateTime? agentNotifiedAt,
  });
}

/// @nodoc
class _$MaxBidModelCopyWithImpl<$Res, $Val extends MaxBidModel>
    implements $MaxBidModelCopyWith<$Res> {
  _$MaxBidModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaxBidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vehicleOptionId = null,
    Object? buyerId = null,
    Object? maxBidUsd = null,
    Object? maxBidGhs = null,
    Object? exchangeRate = null,
    Object? confirmedAt = freezed,
    Object? agentNotified = null,
    Object? agentNotifiedAt = freezed,
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
            vehicleOptionId: null == vehicleOptionId
                ? _value.vehicleOptionId
                : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            maxBidUsd: null == maxBidUsd
                ? _value.maxBidUsd
                : maxBidUsd // ignore: cast_nullable_to_non_nullable
                      as double,
            maxBidGhs: null == maxBidGhs
                ? _value.maxBidGhs
                : maxBidGhs // ignore: cast_nullable_to_non_nullable
                      as double,
            exchangeRate: null == exchangeRate
                ? _value.exchangeRate
                : exchangeRate // ignore: cast_nullable_to_non_nullable
                      as double,
            confirmedAt: freezed == confirmedAt
                ? _value.confirmedAt
                : confirmedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            agentNotified: null == agentNotified
                ? _value.agentNotified
                : agentNotified // ignore: cast_nullable_to_non_nullable
                      as bool,
            agentNotifiedAt: freezed == agentNotifiedAt
                ? _value.agentNotifiedAt
                : agentNotifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaxBidModelImplCopyWith<$Res>
    implements $MaxBidModelCopyWith<$Res> {
  factory _$$MaxBidModelImplCopyWith(
    _$MaxBidModelImpl value,
    $Res Function(_$MaxBidModelImpl) then,
  ) = __$$MaxBidModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String vehicleOptionId,
    String buyerId,
    double maxBidUsd,
    double maxBidGhs,
    double exchangeRate,
    DateTime? confirmedAt,
    bool agentNotified,
    DateTime? agentNotifiedAt,
  });
}

/// @nodoc
class __$$MaxBidModelImplCopyWithImpl<$Res>
    extends _$MaxBidModelCopyWithImpl<$Res, _$MaxBidModelImpl>
    implements _$$MaxBidModelImplCopyWith<$Res> {
  __$$MaxBidModelImplCopyWithImpl(
    _$MaxBidModelImpl _value,
    $Res Function(_$MaxBidModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaxBidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vehicleOptionId = null,
    Object? buyerId = null,
    Object? maxBidUsd = null,
    Object? maxBidGhs = null,
    Object? exchangeRate = null,
    Object? confirmedAt = freezed,
    Object? agentNotified = null,
    Object? agentNotifiedAt = freezed,
  }) {
    return _then(
      _$MaxBidModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleOptionId: null == vehicleOptionId
            ? _value.vehicleOptionId
            : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        maxBidUsd: null == maxBidUsd
            ? _value.maxBidUsd
            : maxBidUsd // ignore: cast_nullable_to_non_nullable
                  as double,
        maxBidGhs: null == maxBidGhs
            ? _value.maxBidGhs
            : maxBidGhs // ignore: cast_nullable_to_non_nullable
                  as double,
        exchangeRate: null == exchangeRate
            ? _value.exchangeRate
            : exchangeRate // ignore: cast_nullable_to_non_nullable
                  as double,
        confirmedAt: freezed == confirmedAt
            ? _value.confirmedAt
            : confirmedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        agentNotified: null == agentNotified
            ? _value.agentNotified
            : agentNotified // ignore: cast_nullable_to_non_nullable
                  as bool,
        agentNotifiedAt: freezed == agentNotifiedAt
            ? _value.agentNotifiedAt
            : agentNotifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaxBidModelImpl implements _MaxBidModel {
  const _$MaxBidModelImpl({
    required this.id,
    required this.orderId,
    required this.vehicleOptionId,
    required this.buyerId,
    required this.maxBidUsd,
    required this.maxBidGhs,
    required this.exchangeRate,
    this.confirmedAt,
    this.agentNotified = false,
    this.agentNotifiedAt,
  });

  factory _$MaxBidModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaxBidModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String vehicleOptionId;
  @override
  final String buyerId;
  @override
  final double maxBidUsd;
  @override
  final double maxBidGhs;
  @override
  final double exchangeRate;
  @override
  final DateTime? confirmedAt;
  @override
  @JsonKey()
  final bool agentNotified;
  @override
  final DateTime? agentNotifiedAt;

  @override
  String toString() {
    return 'MaxBidModel(id: $id, orderId: $orderId, vehicleOptionId: $vehicleOptionId, buyerId: $buyerId, maxBidUsd: $maxBidUsd, maxBidGhs: $maxBidGhs, exchangeRate: $exchangeRate, confirmedAt: $confirmedAt, agentNotified: $agentNotified, agentNotifiedAt: $agentNotifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaxBidModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.vehicleOptionId, vehicleOptionId) ||
                other.vehicleOptionId == vehicleOptionId) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.maxBidUsd, maxBidUsd) ||
                other.maxBidUsd == maxBidUsd) &&
            (identical(other.maxBidGhs, maxBidGhs) ||
                other.maxBidGhs == maxBidGhs) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.agentNotified, agentNotified) ||
                other.agentNotified == agentNotified) &&
            (identical(other.agentNotifiedAt, agentNotifiedAt) ||
                other.agentNotifiedAt == agentNotifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    vehicleOptionId,
    buyerId,
    maxBidUsd,
    maxBidGhs,
    exchangeRate,
    confirmedAt,
    agentNotified,
    agentNotifiedAt,
  );

  /// Create a copy of MaxBidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaxBidModelImplCopyWith<_$MaxBidModelImpl> get copyWith =>
      __$$MaxBidModelImplCopyWithImpl<_$MaxBidModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaxBidModelImplToJson(this);
  }
}

abstract class _MaxBidModel implements MaxBidModel {
  const factory _MaxBidModel({
    required final String id,
    required final String orderId,
    required final String vehicleOptionId,
    required final String buyerId,
    required final double maxBidUsd,
    required final double maxBidGhs,
    required final double exchangeRate,
    final DateTime? confirmedAt,
    final bool agentNotified,
    final DateTime? agentNotifiedAt,
  }) = _$MaxBidModelImpl;

  factory _MaxBidModel.fromJson(Map<String, dynamic> json) =
      _$MaxBidModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get vehicleOptionId;
  @override
  String get buyerId;
  @override
  double get maxBidUsd;
  @override
  double get maxBidGhs;
  @override
  double get exchangeRate;
  @override
  DateTime? get confirmedAt;
  @override
  bool get agentNotified;
  @override
  DateTime? get agentNotifiedAt;

  /// Create a copy of MaxBidModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaxBidModelImplCopyWith<_$MaxBidModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
