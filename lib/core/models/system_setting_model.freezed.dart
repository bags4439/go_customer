// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_setting_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemSettingModel _$SystemSettingModelFromJson(Map<String, dynamic> json) {
  return _SystemSettingModel.fromJson(json);
}

/// @nodoc
mixin _$SystemSettingModel {
  String get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
  Object? get value => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SystemSettingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemSettingModelCopyWith<SystemSettingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemSettingModelCopyWith<$Res> {
  factory $SystemSettingModelCopyWith(
    SystemSettingModel value,
    $Res Function(SystemSettingModel) then,
  ) = _$SystemSettingModelCopyWithImpl<$Res, SystemSettingModel>;
  @useResult
  $Res call({
    String id,
    String key,
    @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson) Object? value,
    String? label,
    String? updatedBy,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$SystemSettingModelCopyWithImpl<$Res, $Val extends SystemSettingModel>
    implements $SystemSettingModelCopyWith<$Res> {
  _$SystemSettingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = freezed,
    Object? label = freezed,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value ? _value.value : value,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedBy: freezed == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$SystemSettingModelImplCopyWith<$Res>
    implements $SystemSettingModelCopyWith<$Res> {
  factory _$$SystemSettingModelImplCopyWith(
    _$SystemSettingModelImpl value,
    $Res Function(_$SystemSettingModelImpl) then,
  ) = __$$SystemSettingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String key,
    @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson) Object? value,
    String? label,
    String? updatedBy,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SystemSettingModelImplCopyWithImpl<$Res>
    extends _$SystemSettingModelCopyWithImpl<$Res, _$SystemSettingModelImpl>
    implements _$$SystemSettingModelImplCopyWith<$Res> {
  __$$SystemSettingModelImplCopyWithImpl(
    _$SystemSettingModelImpl _value,
    $Res Function(_$SystemSettingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? key = null,
    Object? value = freezed,
    Object? label = freezed,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SystemSettingModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value ? _value.value : value,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedBy: freezed == updatedBy
            ? _value.updatedBy
            : updatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$SystemSettingModelImpl implements _SystemSettingModel {
  const _$SystemSettingModelImpl({
    required this.id,
    required this.key,
    @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson) this.value,
    this.label,
    this.updatedBy,
    this.updatedAt,
  });

  factory _$SystemSettingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemSettingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String key;
  @override
  @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
  final Object? value;
  @override
  final String? label;
  @override
  final String? updatedBy;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SystemSettingModel(id: $id, key: $key, value: $value, label: $label, updatedBy: $updatedBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemSettingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    key,
    const DeepCollectionEquality().hash(value),
    label,
    updatedBy,
    updatedAt,
  );

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemSettingModelImplCopyWith<_$SystemSettingModelImpl> get copyWith =>
      __$$SystemSettingModelImplCopyWithImpl<_$SystemSettingModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemSettingModelImplToJson(this);
  }
}

abstract class _SystemSettingModel implements SystemSettingModel {
  const factory _SystemSettingModel({
    required final String id,
    required final String key,
    @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
    final Object? value,
    final String? label,
    final String? updatedBy,
    final DateTime? updatedAt,
  }) = _$SystemSettingModelImpl;

  factory _SystemSettingModel.fromJson(Map<String, dynamic> json) =
      _$SystemSettingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get key;
  @override
  @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
  Object? get value;
  @override
  String? get label;
  @override
  String? get updatedBy;
  @override
  DateTime? get updatedAt;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemSettingModelImplCopyWith<_$SystemSettingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
