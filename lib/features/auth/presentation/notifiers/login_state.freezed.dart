// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LoginState {
  // Input values
  String get phone => throw _privateConstructorUsedError;
  String get dialCode => throw _privateConstructorUsedError;
  String get countryFlag => throw _privateConstructorUsedError;
  String get verificationId => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get referralCode => throw _privateConstructorUsedError;
  String get ghanaCardNumber => throw _privateConstructorUsedError;
  String? get ghanaCardPhotoPath => throw _privateConstructorUsedError;
  String get idDocumentType => throw _privateConstructorUsedError;
  String get smsPhone => throw _privateConstructorUsedError;
  String get smsDialCode => throw _privateConstructorUsedError;
  String get smsCountryFlag => throw _privateConstructorUsedError;
  String get whatsappPhone => throw _privateConstructorUsedError;
  String get whatsappDialCode => throw _privateConstructorUsedError;
  String get whatsappCountryFlag => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError; // Step and navigation
  LoginStep get step => throw _privateConstructorUsedError;
  LoginNav get nav => throw _privateConstructorUsedError; // Loading states
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isUploadingPhoto =>
      throw _privateConstructorUsedError; // Error — null means no error
  String? get error =>
      throw _privateConstructorUsedError; // Generated after Step 3 completes
  String? get generatedReferralCode =>
      throw _privateConstructorUsedError; // OTP resend countdown
  int get resendCountdown => throw _privateConstructorUsedError;
  bool get resendEnabled => throw _privateConstructorUsedError;

  /// Create a copy of LoginState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginStateCopyWith<LoginState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginStateCopyWith<$Res> {
  factory $LoginStateCopyWith(
    LoginState value,
    $Res Function(LoginState) then,
  ) = _$LoginStateCopyWithImpl<$Res, LoginState>;
  @useResult
  $Res call({
    String phone,
    String dialCode,
    String countryFlag,
    String verificationId,
    String otp,
    String fullName,
    String country,
    String referralCode,
    String ghanaCardNumber,
    String? ghanaCardPhotoPath,
    String idDocumentType,
    String smsPhone,
    String smsDialCode,
    String smsCountryFlag,
    String whatsappPhone,
    String whatsappDialCode,
    String whatsappCountryFlag,
    String email,
    LoginStep step,
    LoginNav nav,
    bool isLoading,
    bool isUploadingPhoto,
    String? error,
    String? generatedReferralCode,
    int resendCountdown,
    bool resendEnabled,
  });
}

/// @nodoc
class _$LoginStateCopyWithImpl<$Res, $Val extends LoginState>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? dialCode = null,
    Object? countryFlag = null,
    Object? verificationId = null,
    Object? otp = null,
    Object? fullName = null,
    Object? country = null,
    Object? referralCode = null,
    Object? ghanaCardNumber = null,
    Object? ghanaCardPhotoPath = freezed,
    Object? idDocumentType = null,
    Object? smsPhone = null,
    Object? smsDialCode = null,
    Object? smsCountryFlag = null,
    Object? whatsappPhone = null,
    Object? whatsappDialCode = null,
    Object? whatsappCountryFlag = null,
    Object? email = null,
    Object? step = null,
    Object? nav = null,
    Object? isLoading = null,
    Object? isUploadingPhoto = null,
    Object? error = freezed,
    Object? generatedReferralCode = freezed,
    Object? resendCountdown = null,
    Object? resendEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            dialCode: null == dialCode
                ? _value.dialCode
                : dialCode // ignore: cast_nullable_to_non_nullable
                      as String,
            countryFlag: null == countryFlag
                ? _value.countryFlag
                : countryFlag // ignore: cast_nullable_to_non_nullable
                      as String,
            verificationId: null == verificationId
                ? _value.verificationId
                : verificationId // ignore: cast_nullable_to_non_nullable
                      as String,
            otp: null == otp
                ? _value.otp
                : otp // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            referralCode: null == referralCode
                ? _value.referralCode
                : referralCode // ignore: cast_nullable_to_non_nullable
                      as String,
            ghanaCardNumber: null == ghanaCardNumber
                ? _value.ghanaCardNumber
                : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            ghanaCardPhotoPath: freezed == ghanaCardPhotoPath
                ? _value.ghanaCardPhotoPath
                : ghanaCardPhotoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            idDocumentType: null == idDocumentType
                ? _value.idDocumentType
                : idDocumentType // ignore: cast_nullable_to_non_nullable
                      as String,
            smsPhone: null == smsPhone
                ? _value.smsPhone
                : smsPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            smsDialCode: null == smsDialCode
                ? _value.smsDialCode
                : smsDialCode // ignore: cast_nullable_to_non_nullable
                      as String,
            smsCountryFlag: null == smsCountryFlag
                ? _value.smsCountryFlag
                : smsCountryFlag // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappPhone: null == whatsappPhone
                ? _value.whatsappPhone
                : whatsappPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappDialCode: null == whatsappDialCode
                ? _value.whatsappDialCode
                : whatsappDialCode // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappCountryFlag: null == whatsappCountryFlag
                ? _value.whatsappCountryFlag
                : whatsappCountryFlag // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as LoginStep,
            nav: null == nav
                ? _value.nav
                : nav // ignore: cast_nullable_to_non_nullable
                      as LoginNav,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isUploadingPhoto: null == isUploadingPhoto
                ? _value.isUploadingPhoto
                : isUploadingPhoto // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            generatedReferralCode: freezed == generatedReferralCode
                ? _value.generatedReferralCode
                : generatedReferralCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            resendCountdown: null == resendCountdown
                ? _value.resendCountdown
                : resendCountdown // ignore: cast_nullable_to_non_nullable
                      as int,
            resendEnabled: null == resendEnabled
                ? _value.resendEnabled
                : resendEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginStateImplCopyWith<$Res>
    implements $LoginStateCopyWith<$Res> {
  factory _$$LoginStateImplCopyWith(
    _$LoginStateImpl value,
    $Res Function(_$LoginStateImpl) then,
  ) = __$$LoginStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String phone,
    String dialCode,
    String countryFlag,
    String verificationId,
    String otp,
    String fullName,
    String country,
    String referralCode,
    String ghanaCardNumber,
    String? ghanaCardPhotoPath,
    String idDocumentType,
    String smsPhone,
    String smsDialCode,
    String smsCountryFlag,
    String whatsappPhone,
    String whatsappDialCode,
    String whatsappCountryFlag,
    String email,
    LoginStep step,
    LoginNav nav,
    bool isLoading,
    bool isUploadingPhoto,
    String? error,
    String? generatedReferralCode,
    int resendCountdown,
    bool resendEnabled,
  });
}

/// @nodoc
class __$$LoginStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoginStateImpl>
    implements _$$LoginStateImplCopyWith<$Res> {
  __$$LoginStateImplCopyWithImpl(
    _$LoginStateImpl _value,
    $Res Function(_$LoginStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? dialCode = null,
    Object? countryFlag = null,
    Object? verificationId = null,
    Object? otp = null,
    Object? fullName = null,
    Object? country = null,
    Object? referralCode = null,
    Object? ghanaCardNumber = null,
    Object? ghanaCardPhotoPath = freezed,
    Object? idDocumentType = null,
    Object? smsPhone = null,
    Object? smsDialCode = null,
    Object? smsCountryFlag = null,
    Object? whatsappPhone = null,
    Object? whatsappDialCode = null,
    Object? whatsappCountryFlag = null,
    Object? email = null,
    Object? step = null,
    Object? nav = null,
    Object? isLoading = null,
    Object? isUploadingPhoto = null,
    Object? error = freezed,
    Object? generatedReferralCode = freezed,
    Object? resendCountdown = null,
    Object? resendEnabled = null,
  }) {
    return _then(
      _$LoginStateImpl(
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        dialCode: null == dialCode
            ? _value.dialCode
            : dialCode // ignore: cast_nullable_to_non_nullable
                  as String,
        countryFlag: null == countryFlag
            ? _value.countryFlag
            : countryFlag // ignore: cast_nullable_to_non_nullable
                  as String,
        verificationId: null == verificationId
            ? _value.verificationId
            : verificationId // ignore: cast_nullable_to_non_nullable
                  as String,
        otp: null == otp
            ? _value.otp
            : otp // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        referralCode: null == referralCode
            ? _value.referralCode
            : referralCode // ignore: cast_nullable_to_non_nullable
                  as String,
        ghanaCardNumber: null == ghanaCardNumber
            ? _value.ghanaCardNumber
            : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        ghanaCardPhotoPath: freezed == ghanaCardPhotoPath
            ? _value.ghanaCardPhotoPath
            : ghanaCardPhotoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        idDocumentType: null == idDocumentType
            ? _value.idDocumentType
            : idDocumentType // ignore: cast_nullable_to_non_nullable
                  as String,
        smsPhone: null == smsPhone
            ? _value.smsPhone
            : smsPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        smsDialCode: null == smsDialCode
            ? _value.smsDialCode
            : smsDialCode // ignore: cast_nullable_to_non_nullable
                  as String,
        smsCountryFlag: null == smsCountryFlag
            ? _value.smsCountryFlag
            : smsCountryFlag // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappPhone: null == whatsappPhone
            ? _value.whatsappPhone
            : whatsappPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappDialCode: null == whatsappDialCode
            ? _value.whatsappDialCode
            : whatsappDialCode // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappCountryFlag: null == whatsappCountryFlag
            ? _value.whatsappCountryFlag
            : whatsappCountryFlag // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as LoginStep,
        nav: null == nav
            ? _value.nav
            : nav // ignore: cast_nullable_to_non_nullable
                  as LoginNav,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isUploadingPhoto: null == isUploadingPhoto
            ? _value.isUploadingPhoto
            : isUploadingPhoto // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        generatedReferralCode: freezed == generatedReferralCode
            ? _value.generatedReferralCode
            : generatedReferralCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        resendCountdown: null == resendCountdown
            ? _value.resendCountdown
            : resendCountdown // ignore: cast_nullable_to_non_nullable
                  as int,
        resendEnabled: null == resendEnabled
            ? _value.resendEnabled
            : resendEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$LoginStateImpl implements _LoginState {
  const _$LoginStateImpl({
    this.phone = '',
    this.dialCode = '+233',
    this.countryFlag = '🇬🇭',
    this.verificationId = '',
    this.otp = '',
    this.fullName = '',
    this.country = '',
    this.referralCode = '',
    this.ghanaCardNumber = '',
    this.ghanaCardPhotoPath,
    this.idDocumentType = 'ghana_card',
    this.smsPhone = '',
    this.smsDialCode = '+233',
    this.smsCountryFlag = '🇬🇭',
    this.whatsappPhone = '',
    this.whatsappDialCode = '+233',
    this.whatsappCountryFlag = '🇬🇭',
    this.email = '',
    this.step = LoginStep.phone,
    this.nav = LoginNav.none,
    this.isLoading = false,
    this.isUploadingPhoto = false,
    this.error,
    this.generatedReferralCode,
    this.resendCountdown = 60,
    this.resendEnabled = false,
  });

  // Input values
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String dialCode;
  @override
  @JsonKey()
  final String countryFlag;
  @override
  @JsonKey()
  final String verificationId;
  @override
  @JsonKey()
  final String otp;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String country;
  @override
  @JsonKey()
  final String referralCode;
  @override
  @JsonKey()
  final String ghanaCardNumber;
  @override
  final String? ghanaCardPhotoPath;
  @override
  @JsonKey()
  final String idDocumentType;
  @override
  @JsonKey()
  final String smsPhone;
  @override
  @JsonKey()
  final String smsDialCode;
  @override
  @JsonKey()
  final String smsCountryFlag;
  @override
  @JsonKey()
  final String whatsappPhone;
  @override
  @JsonKey()
  final String whatsappDialCode;
  @override
  @JsonKey()
  final String whatsappCountryFlag;
  @override
  @JsonKey()
  final String email;
  // Step and navigation
  @override
  @JsonKey()
  final LoginStep step;
  @override
  @JsonKey()
  final LoginNav nav;
  // Loading states
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUploadingPhoto;
  // Error — null means no error
  @override
  final String? error;
  // Generated after Step 3 completes
  @override
  final String? generatedReferralCode;
  // OTP resend countdown
  @override
  @JsonKey()
  final int resendCountdown;
  @override
  @JsonKey()
  final bool resendEnabled;

  @override
  String toString() {
    return 'LoginState(phone: $phone, dialCode: $dialCode, countryFlag: $countryFlag, verificationId: $verificationId, otp: $otp, fullName: $fullName, country: $country, referralCode: $referralCode, ghanaCardNumber: $ghanaCardNumber, ghanaCardPhotoPath: $ghanaCardPhotoPath, idDocumentType: $idDocumentType, smsPhone: $smsPhone, smsDialCode: $smsDialCode, smsCountryFlag: $smsCountryFlag, whatsappPhone: $whatsappPhone, whatsappDialCode: $whatsappDialCode, whatsappCountryFlag: $whatsappCountryFlag, email: $email, step: $step, nav: $nav, isLoading: $isLoading, isUploadingPhoto: $isUploadingPhoto, error: $error, generatedReferralCode: $generatedReferralCode, resendCountdown: $resendCountdown, resendEnabled: $resendEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginStateImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.dialCode, dialCode) ||
                other.dialCode == dialCode) &&
            (identical(other.countryFlag, countryFlag) ||
                other.countryFlag == countryFlag) &&
            (identical(other.verificationId, verificationId) ||
                other.verificationId == verificationId) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.ghanaCardNumber, ghanaCardNumber) ||
                other.ghanaCardNumber == ghanaCardNumber) &&
            (identical(other.ghanaCardPhotoPath, ghanaCardPhotoPath) ||
                other.ghanaCardPhotoPath == ghanaCardPhotoPath) &&
            (identical(other.idDocumentType, idDocumentType) ||
                other.idDocumentType == idDocumentType) &&
            (identical(other.smsPhone, smsPhone) ||
                other.smsPhone == smsPhone) &&
            (identical(other.smsDialCode, smsDialCode) ||
                other.smsDialCode == smsDialCode) &&
            (identical(other.smsCountryFlag, smsCountryFlag) ||
                other.smsCountryFlag == smsCountryFlag) &&
            (identical(other.whatsappPhone, whatsappPhone) ||
                other.whatsappPhone == whatsappPhone) &&
            (identical(other.whatsappDialCode, whatsappDialCode) ||
                other.whatsappDialCode == whatsappDialCode) &&
            (identical(other.whatsappCountryFlag, whatsappCountryFlag) ||
                other.whatsappCountryFlag == whatsappCountryFlag) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.nav, nav) || other.nav == nav) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUploadingPhoto, isUploadingPhoto) ||
                other.isUploadingPhoto == isUploadingPhoto) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.generatedReferralCode, generatedReferralCode) ||
                other.generatedReferralCode == generatedReferralCode) &&
            (identical(other.resendCountdown, resendCountdown) ||
                other.resendCountdown == resendCountdown) &&
            (identical(other.resendEnabled, resendEnabled) ||
                other.resendEnabled == resendEnabled));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    phone,
    dialCode,
    countryFlag,
    verificationId,
    otp,
    fullName,
    country,
    referralCode,
    ghanaCardNumber,
    ghanaCardPhotoPath,
    idDocumentType,
    smsPhone,
    smsDialCode,
    smsCountryFlag,
    whatsappPhone,
    whatsappDialCode,
    whatsappCountryFlag,
    email,
    step,
    nav,
    isLoading,
    isUploadingPhoto,
    error,
    generatedReferralCode,
    resendCountdown,
    resendEnabled,
  ]);

  /// Create a copy of LoginState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginStateImplCopyWith<_$LoginStateImpl> get copyWith =>
      __$$LoginStateImplCopyWithImpl<_$LoginStateImpl>(this, _$identity);
}

abstract class _LoginState implements LoginState {
  const factory _LoginState({
    final String phone,
    final String dialCode,
    final String countryFlag,
    final String verificationId,
    final String otp,
    final String fullName,
    final String country,
    final String referralCode,
    final String ghanaCardNumber,
    final String? ghanaCardPhotoPath,
    final String idDocumentType,
    final String smsPhone,
    final String smsDialCode,
    final String smsCountryFlag,
    final String whatsappPhone,
    final String whatsappDialCode,
    final String whatsappCountryFlag,
    final String email,
    final LoginStep step,
    final LoginNav nav,
    final bool isLoading,
    final bool isUploadingPhoto,
    final String? error,
    final String? generatedReferralCode,
    final int resendCountdown,
    final bool resendEnabled,
  }) = _$LoginStateImpl;

  // Input values
  @override
  String get phone;
  @override
  String get dialCode;
  @override
  String get countryFlag;
  @override
  String get verificationId;
  @override
  String get otp;
  @override
  String get fullName;
  @override
  String get country;
  @override
  String get referralCode;
  @override
  String get ghanaCardNumber;
  @override
  String? get ghanaCardPhotoPath;
  @override
  String get idDocumentType;
  @override
  String get smsPhone;
  @override
  String get smsDialCode;
  @override
  String get smsCountryFlag;
  @override
  String get whatsappPhone;
  @override
  String get whatsappDialCode;
  @override
  String get whatsappCountryFlag;
  @override
  String get email; // Step and navigation
  @override
  LoginStep get step;
  @override
  LoginNav get nav; // Loading states
  @override
  bool get isLoading;
  @override
  bool get isUploadingPhoto; // Error — null means no error
  @override
  String? get error; // Generated after Step 3 completes
  @override
  String? get generatedReferralCode; // OTP resend countdown
  @override
  int get resendCountdown;
  @override
  bool get resendEnabled;

  /// Create a copy of LoginState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginStateImplCopyWith<_$LoginStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
