// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSessionModel _$UserSessionModelFromJson(Map<String, dynamic> json) {
  return _UserSessionModel.fromJson(json);
}

/// @nodoc
mixin _$UserSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get deviceToken => throw _privateConstructorUsedError;
  String? get sessionToken => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSessionModelCopyWith<UserSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSessionModelCopyWith<$Res> {
  factory $UserSessionModelCopyWith(
    UserSessionModel value,
    $Res Function(UserSessionModel) then,
  ) = _$UserSessionModelCopyWithImpl<$Res, UserSessionModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? deviceToken,
    String? sessionToken,
    String role,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UserSessionModelCopyWithImpl<$Res, $Val extends UserSessionModel>
    implements $UserSessionModelCopyWith<$Res> {
  _$UserSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceToken = freezed,
    Object? sessionToken = freezed,
    Object? role = null,
    Object? expiresAt = freezed,
    Object? lastUsedAt = freezed,
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
            deviceToken: freezed == deviceToken
                ? _value.deviceToken
                : deviceToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionToken: freezed == sessionToken
                ? _value.sessionToken
                : sessionToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastUsedAt: freezed == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$UserSessionModelImplCopyWith<$Res>
    implements $UserSessionModelCopyWith<$Res> {
  factory _$$UserSessionModelImplCopyWith(
    _$UserSessionModelImpl value,
    $Res Function(_$UserSessionModelImpl) then,
  ) = __$$UserSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? deviceToken,
    String? sessionToken,
    String role,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserSessionModelImplCopyWithImpl<$Res>
    extends _$UserSessionModelCopyWithImpl<$Res, _$UserSessionModelImpl>
    implements _$$UserSessionModelImplCopyWith<$Res> {
  __$$UserSessionModelImplCopyWithImpl(
    _$UserSessionModelImpl _value,
    $Res Function(_$UserSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceToken = freezed,
    Object? sessionToken = freezed,
    Object? role = null,
    Object? expiresAt = freezed,
    Object? lastUsedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserSessionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceToken: freezed == deviceToken
            ? _value.deviceToken
            : deviceToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionToken: freezed == sessionToken
            ? _value.sessionToken
            : sessionToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastUsedAt: freezed == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$UserSessionModelImpl implements _UserSessionModel {
  const _$UserSessionModelImpl({
    required this.id,
    required this.userId,
    this.deviceToken,
    this.sessionToken,
    required this.role,
    this.expiresAt,
    this.lastUsedAt,
    this.createdAt,
  });

  factory _$UserSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? deviceToken;
  @override
  final String? sessionToken;
  @override
  final String role;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? lastUsedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserSessionModel(id: $id, userId: $userId, deviceToken: $deviceToken, sessionToken: $sessionToken, role: $role, expiresAt: $expiresAt, lastUsedAt: $lastUsedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceToken, deviceToken) ||
                other.deviceToken == deviceToken) &&
            (identical(other.sessionToken, sessionToken) ||
                other.sessionToken == sessionToken) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    deviceToken,
    sessionToken,
    role,
    expiresAt,
    lastUsedAt,
    createdAt,
  );

  /// Create a copy of UserSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSessionModelImplCopyWith<_$UserSessionModelImpl> get copyWith =>
      __$$UserSessionModelImplCopyWithImpl<_$UserSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSessionModelImplToJson(this);
  }
}

abstract class _UserSessionModel implements UserSessionModel {
  const factory _UserSessionModel({
    required final String id,
    required final String userId,
    final String? deviceToken,
    final String? sessionToken,
    required final String role,
    final DateTime? expiresAt,
    final DateTime? lastUsedAt,
    final DateTime? createdAt,
  }) = _$UserSessionModelImpl;

  factory _UserSessionModel.fromJson(Map<String, dynamic> json) =
      _$UserSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get deviceToken;
  @override
  String? get sessionToken;
  @override
  String get role;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get lastUsedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of UserSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSessionModelImplCopyWith<_$UserSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
