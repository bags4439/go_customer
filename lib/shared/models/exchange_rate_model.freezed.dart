// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExchangeRateModel _$ExchangeRateModelFromJson(Map<String, dynamic> json) {
  return _ExchangeRateModel.fromJson(json);
}

/// @nodoc
mixin _$ExchangeRateModel {
  String get id => throw _privateConstructorUsedError;
  double get usdToGhs => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  DateTime? get fetchedAt => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;

  /// Serializes this ExchangeRateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateModelCopyWith<ExchangeRateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateModelCopyWith<$Res> {
  factory $ExchangeRateModelCopyWith(
    ExchangeRateModel value,
    $Res Function(ExchangeRateModel) then,
  ) = _$ExchangeRateModelCopyWithImpl<$Res, ExchangeRateModel>;
  @useResult
  $Res call({
    String id,
    double usdToGhs,
    String? source,
    DateTime? fetchedAt,
    bool isCurrent,
  });
}

/// @nodoc
class _$ExchangeRateModelCopyWithImpl<$Res, $Val extends ExchangeRateModel>
    implements $ExchangeRateModelCopyWith<$Res> {
  _$ExchangeRateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usdToGhs = null,
    Object? source = freezed,
    Object? fetchedAt = freezed,
    Object? isCurrent = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            usdToGhs: null == usdToGhs
                ? _value.usdToGhs
                : usdToGhs // ignore: cast_nullable_to_non_nullable
                      as double,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            fetchedAt: freezed == fetchedAt
                ? _value.fetchedAt
                : fetchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCurrent: null == isCurrent
                ? _value.isCurrent
                : isCurrent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateModelImplCopyWith<$Res>
    implements $ExchangeRateModelCopyWith<$Res> {
  factory _$$ExchangeRateModelImplCopyWith(
    _$ExchangeRateModelImpl value,
    $Res Function(_$ExchangeRateModelImpl) then,
  ) = __$$ExchangeRateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double usdToGhs,
    String? source,
    DateTime? fetchedAt,
    bool isCurrent,
  });
}

/// @nodoc
class __$$ExchangeRateModelImplCopyWithImpl<$Res>
    extends _$ExchangeRateModelCopyWithImpl<$Res, _$ExchangeRateModelImpl>
    implements _$$ExchangeRateModelImplCopyWith<$Res> {
  __$$ExchangeRateModelImplCopyWithImpl(
    _$ExchangeRateModelImpl _value,
    $Res Function(_$ExchangeRateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usdToGhs = null,
    Object? source = freezed,
    Object? fetchedAt = freezed,
    Object? isCurrent = null,
  }) {
    return _then(
      _$ExchangeRateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        usdToGhs: null == usdToGhs
            ? _value.usdToGhs
            : usdToGhs // ignore: cast_nullable_to_non_nullable
                  as double,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        fetchedAt: freezed == fetchedAt
            ? _value.fetchedAt
            : fetchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCurrent: null == isCurrent
            ? _value.isCurrent
            : isCurrent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExchangeRateModelImpl implements _ExchangeRateModel {
  const _$ExchangeRateModelImpl({
    required this.id,
    required this.usdToGhs,
    this.source,
    this.fetchedAt,
    this.isCurrent = true,
  });

  factory _$ExchangeRateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExchangeRateModelImplFromJson(json);

  @override
  final String id;
  @override
  final double usdToGhs;
  @override
  final String? source;
  @override
  final DateTime? fetchedAt;
  @override
  @JsonKey()
  final bool isCurrent;

  @override
  String toString() {
    return 'ExchangeRateModel(id: $id, usdToGhs: $usdToGhs, source: $source, fetchedAt: $fetchedAt, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.usdToGhs, usdToGhs) ||
                other.usdToGhs == usdToGhs) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, usdToGhs, source, fetchedAt, isCurrent);

  /// Create a copy of ExchangeRateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateModelImplCopyWith<_$ExchangeRateModelImpl> get copyWith =>
      __$$ExchangeRateModelImplCopyWithImpl<_$ExchangeRateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExchangeRateModelImplToJson(this);
  }
}

abstract class _ExchangeRateModel implements ExchangeRateModel {
  const factory _ExchangeRateModel({
    required final String id,
    required final double usdToGhs,
    final String? source,
    final DateTime? fetchedAt,
    final bool isCurrent,
  }) = _$ExchangeRateModelImpl;

  factory _ExchangeRateModel.fromJson(Map<String, dynamic> json) =
      _$ExchangeRateModelImpl.fromJson;

  @override
  String get id;
  @override
  double get usdToGhs;
  @override
  String? get source;
  @override
  DateTime? get fetchedAt;
  @override
  bool get isCurrent;

  /// Create a copy of ExchangeRateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateModelImplCopyWith<_$ExchangeRateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
