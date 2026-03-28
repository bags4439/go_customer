import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// The five inline steps of the login screen.
enum LoginStep {
  phone, // Step 1 — enter phone number
  otp, // Step 2 — enter OTP
  name, // Step 3 — new users: enter full name
  referral, // Step 4 — new users: optional referral code
  ghanaCard, // Step 5 — new users: optional Ghana card
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
    @Default('') String verificationId,
    @Default('') String otp,
    @Default('') String fullName,
    @Default('') String referralCode,
    @Default('') String ghanaCardNumber,
    String? ghanaCardPhotoPath,

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
