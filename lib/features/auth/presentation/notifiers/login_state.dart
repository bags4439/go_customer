import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// The five inline steps of the login screen.
enum LoginStep {
  phone, // Step 1 — enter phone number
  otp, // Step 2 — enter OTP
  name, // Step 3 — new users: enter full name
  referral, // Step 4 — new users: optional referral code
  contactChannels, // Step 5 — new users: contact channels (SMS, WhatsApp, email)
}

/// Navigation signal emitted by the notifier.
/// Consumed by the screen via ref.listen.
enum LoginNav {
  none, // no navigation needed
  goHome, // navigate to /home
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    // Input values
    @Default('') String phone,
    @Default('+233') String dialCode,
    @Default('🇬🇭') String countryFlag,
    @Default('') String verificationId,
    @Default('') String otp,
    @Default('') String fullName,
    @Default('') String country,
    @Default('') String referralCode,
    @Default('') String ghanaCardNumber,
    String? ghanaCardPhotoPath,
    @Default('ghana_card') String idDocumentType,
    @Default('') String smsPhone,
    @Default('+233') String smsDialCode,
    @Default('🇬🇭') String smsCountryFlag,
    @Default('') String whatsappPhone,
    @Default('+233') String whatsappDialCode,
    @Default('🇬🇭') String whatsappCountryFlag,
    @Default('') String email,

    // Step and navigation
    @Default(LoginStep.phone) LoginStep step,
    @Default(LoginNav.none) LoginNav nav,

    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isUploadingPhoto,

    // Error — null means no error
    String? error,

    // Generated after Step 3 completes
    String? generatedReferralCode,

    // OTP resend countdown
    @Default(60) int resendCountdown,
    @Default(false) bool resendEnabled,
  }) = _LoginState;
}
