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
  String? get smsPhone => throw _privateConstructorUsedError;
  String? get whatsappPhone => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'buyer' | 'agent' | 'admin'
  String? get location => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  bool get isFirstTimeBuyer => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  String? get ghanaCardPhotoUrl => throw _privateConstructorUsedError;
  String? get ghanaCardNumber => throw _privateConstructorUsedError;
  String get idDocumentType => throw _privateConstructorUsedError;
  String get preferredCurrency => throw _privateConstructorUsedError;
  String get preferredLanguage => throw _privateConstructorUsedError;
  String get referralCode => throw _privateConstructorUsedError;
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
    String? smsPhone,
    String? whatsappPhone,
    String role,
    String? location,
    String country,
    bool isFirstTimeBuyer,
    bool isVerified,
    String? ghanaCardPhotoUrl,
    String? ghanaCardNumber,
    String idDocumentType,
    String preferredCurrency,
    String preferredLanguage,
    String referralCode,
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
    Object? smsPhone = freezed,
    Object? whatsappPhone = freezed,
    Object? role = null,
    Object? location = freezed,
    Object? country = null,
    Object? isFirstTimeBuyer = null,
    Object? isVerified = null,
    Object? ghanaCardPhotoUrl = freezed,
    Object? ghanaCardNumber = freezed,
    Object? idDocumentType = null,
    Object? preferredCurrency = null,
    Object? preferredLanguage = null,
    Object? referralCode = null,
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
            smsPhone: freezed == smsPhone
                ? _value.smsPhone
                : smsPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            whatsappPhone: freezed == whatsappPhone
                ? _value.whatsappPhone
                : whatsappPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            isFirstTimeBuyer: null == isFirstTimeBuyer
                ? _value.isFirstTimeBuyer
                : isFirstTimeBuyer // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            ghanaCardPhotoUrl: freezed == ghanaCardPhotoUrl
                ? _value.ghanaCardPhotoUrl
                : ghanaCardPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            ghanaCardNumber: freezed == ghanaCardNumber
                ? _value.ghanaCardNumber
                : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            idDocumentType: null == idDocumentType
                ? _value.idDocumentType
                : idDocumentType // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredCurrency: null == preferredCurrency
                ? _value.preferredCurrency
                : preferredCurrency // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredLanguage: null == preferredLanguage
                ? _value.preferredLanguage
                : preferredLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            referralCode: null == referralCode
                ? _value.referralCode
                : referralCode // ignore: cast_nullable_to_non_nullable
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
    String? smsPhone,
    String? whatsappPhone,
    String role,
    String? location,
    String country,
    bool isFirstTimeBuyer,
    bool isVerified,
    String? ghanaCardPhotoUrl,
    String? ghanaCardNumber,
    String idDocumentType,
    String preferredCurrency,
    String preferredLanguage,
    String referralCode,
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
    Object? smsPhone = freezed,
    Object? whatsappPhone = freezed,
    Object? role = null,
    Object? location = freezed,
    Object? country = null,
    Object? isFirstTimeBuyer = null,
    Object? isVerified = null,
    Object? ghanaCardPhotoUrl = freezed,
    Object? ghanaCardNumber = freezed,
    Object? idDocumentType = null,
    Object? preferredCurrency = null,
    Object? preferredLanguage = null,
    Object? referralCode = null,
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
        smsPhone: freezed == smsPhone
            ? _value.smsPhone
            : smsPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        whatsappPhone: freezed == whatsappPhone
            ? _value.whatsappPhone
            : whatsappPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        isFirstTimeBuyer: null == isFirstTimeBuyer
            ? _value.isFirstTimeBuyer
            : isFirstTimeBuyer // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        ghanaCardPhotoUrl: freezed == ghanaCardPhotoUrl
            ? _value.ghanaCardPhotoUrl
            : ghanaCardPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        ghanaCardNumber: freezed == ghanaCardNumber
            ? _value.ghanaCardNumber
            : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        idDocumentType: null == idDocumentType
            ? _value.idDocumentType
            : idDocumentType // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredCurrency: null == preferredCurrency
            ? _value.preferredCurrency
            : preferredCurrency // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredLanguage: null == preferredLanguage
            ? _value.preferredLanguage
            : preferredLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        referralCode: null == referralCode
            ? _value.referralCode
            : referralCode // ignore: cast_nullable_to_non_nullable
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
    this.smsPhone,
    this.whatsappPhone,
    required this.role,
    this.location,
    this.country = '',
    this.isFirstTimeBuyer = false,
    this.isVerified = false,
    this.ghanaCardPhotoUrl,
    this.ghanaCardNumber,
    this.idDocumentType = '',
    this.preferredCurrency = 'GHS',
    this.preferredLanguage = 'en',
    this.referralCode = '',
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
  final String? smsPhone;
  @override
  final String? whatsappPhone;
  @override
  final String role;
  // 'buyer' | 'agent' | 'admin'
  @override
  final String? location;
  @override
  @JsonKey()
  final String country;
  @override
  @JsonKey()
  final bool isFirstTimeBuyer;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final String? ghanaCardPhotoUrl;
  @override
  final String? ghanaCardNumber;
  @override
  @JsonKey()
  final String idDocumentType;
  @override
  @JsonKey()
  final String preferredCurrency;
  @override
  @JsonKey()
  final String preferredLanguage;
  @override
  @JsonKey()
  final String referralCode;
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
    return 'UserModel(id: $id, fullName: $fullName, phone: $phone, email: $email, smsPhone: $smsPhone, whatsappPhone: $whatsappPhone, role: $role, location: $location, country: $country, isFirstTimeBuyer: $isFirstTimeBuyer, isVerified: $isVerified, ghanaCardPhotoUrl: $ghanaCardPhotoUrl, ghanaCardNumber: $ghanaCardNumber, idDocumentType: $idDocumentType, preferredCurrency: $preferredCurrency, preferredLanguage: $preferredLanguage, referralCode: $referralCode, pushToken: $pushToken, notificationPreferences: $notificationPreferences, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.smsPhone, smsPhone) ||
                other.smsPhone == smsPhone) &&
            (identical(other.whatsappPhone, whatsappPhone) ||
                other.whatsappPhone == whatsappPhone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.isFirstTimeBuyer, isFirstTimeBuyer) ||
                other.isFirstTimeBuyer == isFirstTimeBuyer) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.ghanaCardPhotoUrl, ghanaCardPhotoUrl) ||
                other.ghanaCardPhotoUrl == ghanaCardPhotoUrl) &&
            (identical(other.ghanaCardNumber, ghanaCardNumber) ||
                other.ghanaCardNumber == ghanaCardNumber) &&
            (identical(other.idDocumentType, idDocumentType) ||
                other.idDocumentType == idDocumentType) &&
            (identical(other.preferredCurrency, preferredCurrency) ||
                other.preferredCurrency == preferredCurrency) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
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
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    fullName,
    phone,
    email,
    smsPhone,
    whatsappPhone,
    role,
    location,
    country,
    isFirstTimeBuyer,
    isVerified,
    ghanaCardPhotoUrl,
    ghanaCardNumber,
    idDocumentType,
    preferredCurrency,
    preferredLanguage,
    referralCode,
    pushToken,
    const DeepCollectionEquality().hash(_notificationPreferences),
    lastActiveAt,
    createdAt,
    updatedAt,
  ]);

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
    final String? smsPhone,
    final String? whatsappPhone,
    required final String role,
    final String? location,
    final String country,
    final bool isFirstTimeBuyer,
    final bool isVerified,
    final String? ghanaCardPhotoUrl,
    final String? ghanaCardNumber,
    final String idDocumentType,
    final String preferredCurrency,
    final String preferredLanguage,
    final String referralCode,
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
  String? get smsPhone;
  @override
  String? get whatsappPhone;
  @override
  String get role; // 'buyer' | 'agent' | 'admin'
  @override
  String? get location;
  @override
  String get country;
  @override
  bool get isFirstTimeBuyer;
  @override
  bool get isVerified;
  @override
  String? get ghanaCardPhotoUrl;
  @override
  String? get ghanaCardNumber;
  @override
  String get idDocumentType;
  @override
  String get preferredCurrency;
  @override
  String get preferredLanguage;
  @override
  String get referralCode;
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
