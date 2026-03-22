// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'buyer' | 'agent' | 'admin'
  String? get location => throw _privateConstructorUsedError;
  bool get isFirstTimeBuyer => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  String? get ghanaidUrl => throw _privateConstructorUsedError;
  bool get ghanaidVerified => throw _privateConstructorUsedError;
  DateTime? get ghanaidVerifiedAt => throw _privateConstructorUsedError;
  String get preferredCurrency => throw _privateConstructorUsedError;
  String get preferredLanguage => throw _privateConstructorUsedError;
  String? get pushToken => throw _privateConstructorUsedError;
  Map<String, dynamic>? get notificationPreferences =>
      throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String fullName,
    String phone,
    String? email,
    String role,
    String? location,
    bool isFirstTimeBuyer,
    bool isVerified,
    String? ghanaidUrl,
    bool ghanaidVerified,
    DateTime? ghanaidVerifiedAt,
    String preferredCurrency,
    String preferredLanguage,
    String? pushToken,
    Map<String, dynamic>? notificationPreferences,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = freezed,
    Object? role = null,
    Object? location = freezed,
    Object? isFirstTimeBuyer = null,
    Object? isVerified = null,
    Object? ghanaidUrl = freezed,
    Object? ghanaidVerified = null,
    Object? ghanaidVerifiedAt = freezed,
    Object? preferredCurrency = null,
    Object? preferredLanguage = null,
    Object? pushToken = freezed,
    Object? notificationPreferences = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFirstTimeBuyer: null == isFirstTimeBuyer
                ? _value.isFirstTimeBuyer
                : isFirstTimeBuyer // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            ghanaidUrl: freezed == ghanaidUrl
                ? _value.ghanaidUrl
                : ghanaidUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            ghanaidVerified: null == ghanaidVerified
                ? _value.ghanaidVerified
                : ghanaidVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            ghanaidVerifiedAt: freezed == ghanaidVerifiedAt
                ? _value.ghanaidVerifiedAt
                : ghanaidVerifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            preferredCurrency: null == preferredCurrency
                ? _value.preferredCurrency
                : preferredCurrency // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredLanguage: null == preferredLanguage
                ? _value.preferredLanguage
                : preferredLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            pushToken: freezed == pushToken
                ? _value.pushToken
                : pushToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationPreferences: freezed == notificationPreferences
                ? _value.notificationPreferences
                : notificationPreferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fullName,
    String phone,
    String? email,
    String role,
    String? location,
    bool isFirstTimeBuyer,
    bool isVerified,
    String? ghanaidUrl,
    bool ghanaidVerified,
    DateTime? ghanaidVerifiedAt,
    String preferredCurrency,
    String preferredLanguage,
    String? pushToken,
    Map<String, dynamic>? notificationPreferences,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = freezed,
    Object? role = null,
    Object? location = freezed,
    Object? isFirstTimeBuyer = null,
    Object? isVerified = null,
    Object? ghanaidUrl = freezed,
    Object? ghanaidVerified = null,
    Object? ghanaidVerifiedAt = freezed,
    Object? preferredCurrency = null,
    Object? preferredLanguage = null,
    Object? pushToken = freezed,
    Object? notificationPreferences = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFirstTimeBuyer: null == isFirstTimeBuyer
            ? _value.isFirstTimeBuyer
            : isFirstTimeBuyer // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        ghanaidUrl: freezed == ghanaidUrl
            ? _value.ghanaidUrl
            : ghanaidUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        ghanaidVerified: null == ghanaidVerified
            ? _value.ghanaidVerified
            : ghanaidVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        ghanaidVerifiedAt: freezed == ghanaidVerifiedAt
            ? _value.ghanaidVerifiedAt
            : ghanaidVerifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        preferredCurrency: null == preferredCurrency
            ? _value.preferredCurrency
            : preferredCurrency // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredLanguage: null == preferredLanguage
            ? _value.preferredLanguage
            : preferredLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        pushToken: freezed == pushToken
            ? _value.pushToken
            : pushToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationPreferences: freezed == notificationPreferences
            ? _value._notificationPreferences
            : notificationPreferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
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
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.location,
    this.isFirstTimeBuyer = false,
    this.isVerified = false,
    this.ghanaidUrl,
    this.ghanaidVerified = false,
    this.ghanaidVerifiedAt,
    this.preferredCurrency = 'GHS',
    this.preferredLanguage = 'en',
    this.pushToken,
    final Map<String, dynamic>? notificationPreferences,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
  }) : _notificationPreferences = notificationPreferences;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String? email;
  @override
  final String role;
  // 'buyer' | 'agent' | 'admin'
  @override
  final String? location;
  @override
  @JsonKey()
  final bool isFirstTimeBuyer;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final String? ghanaidUrl;
  @override
  @JsonKey()
  final bool ghanaidVerified;
  @override
  final DateTime? ghanaidVerifiedAt;
  @override
  @JsonKey()
  final String preferredCurrency;
  @override
  @JsonKey()
  final String preferredLanguage;
  @override
  final String? pushToken;
  final Map<String, dynamic>? _notificationPreferences;
  @override
  Map<String, dynamic>? get notificationPreferences {
    final value = _notificationPreferences;
    if (value == null) return null;
    if (_notificationPreferences is EqualUnmodifiableMapView)
      return _notificationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? lastActiveAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, phone: $phone, email: $email, role: $role, location: $location, isFirstTimeBuyer: $isFirstTimeBuyer, isVerified: $isVerified, ghanaidUrl: $ghanaidUrl, ghanaidVerified: $ghanaidVerified, ghanaidVerifiedAt: $ghanaidVerifiedAt, preferredCurrency: $preferredCurrency, preferredLanguage: $preferredLanguage, pushToken: $pushToken, notificationPreferences: $notificationPreferences, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isFirstTimeBuyer, isFirstTimeBuyer) ||
                other.isFirstTimeBuyer == isFirstTimeBuyer) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.ghanaidUrl, ghanaidUrl) ||
                other.ghanaidUrl == ghanaidUrl) &&
            (identical(other.ghanaidVerified, ghanaidVerified) ||
                other.ghanaidVerified == ghanaidVerified) &&
            (identical(other.ghanaidVerifiedAt, ghanaidVerifiedAt) ||
                other.ghanaidVerifiedAt == ghanaidVerifiedAt) &&
            (identical(other.preferredCurrency, preferredCurrency) ||
                other.preferredCurrency == preferredCurrency) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.pushToken, pushToken) ||
                other.pushToken == pushToken) &&
            const DeepCollectionEquality().equals(
              other._notificationPreferences,
              _notificationPreferences,
            ) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
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
    fullName,
    phone,
    email,
    role,
    location,
    isFirstTimeBuyer,
    isVerified,
    ghanaidUrl,
    ghanaidVerified,
    ghanaidVerifiedAt,
    preferredCurrency,
    preferredLanguage,
    pushToken,
    const DeepCollectionEquality().hash(_notificationPreferences),
    lastActiveAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String id,
    required final String fullName,
    required final String phone,
    final String? email,
    required final String role,
    final String? location,
    final bool isFirstTimeBuyer,
    final bool isVerified,
    final String? ghanaidUrl,
    final bool ghanaidVerified,
    final DateTime? ghanaidVerifiedAt,
    final String preferredCurrency,
    final String preferredLanguage,
    final String? pushToken,
    final Map<String, dynamic>? notificationPreferences,
    final DateTime? lastActiveAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  String? get email;
  @override
  String get role; // 'buyer' | 'agent' | 'admin'
  @override
  String? get location;
  @override
  bool get isFirstTimeBuyer;
  @override
  bool get isVerified;
  @override
  String? get ghanaidUrl;
  @override
  bool get ghanaidVerified;
  @override
  DateTime? get ghanaidVerifiedAt;
  @override
  String get preferredCurrency;
  @override
  String get preferredLanguage;
  @override
  String? get pushToken;
  @override
  Map<String, dynamic>? get notificationPreferences;
  @override
  DateTime? get lastActiveAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
