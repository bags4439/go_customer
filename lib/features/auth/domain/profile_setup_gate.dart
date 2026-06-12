import 'entities/app_user.dart';

/// Firestore [registrationWizardStep] values for resuming the setup wizard.
abstract final class RegistrationWizardStepKeys {
  static const String referral = 'referral';
  static const String contactChannels = 'contactChannels';
}

/// Identity fields required before referral / contact steps.
bool isProfileMinimumCompleteMap(
  Map<String, dynamic>? data, {
  required bool exists,
}) {
  if (!exists || data == null) return false;
  final fullName = data['fullName'] as String?;
  if (fullName == null || fullName.trim().isEmpty) return false;
  final country = data['country'] as String?;
  if (country == null || country.trim().isEmpty) return false;
  return true;
}

bool isProfileMinimumIncompleteMap(
  Map<String, dynamic>? data, {
  required bool exists,
}) =>
    !isProfileMinimumCompleteMap(data, exists: exists);

bool isProfileMinimumCompleteUser(AppUser? user) {
  if (user == null) return false;
  return user.fullName.trim().isNotEmpty && user.country.trim().isNotEmpty;
}

/// True when the buyer may enter the main app (/home).
///
/// New users: [registrationComplete] must be explicitly `true` (set after
/// contact channels finish or skip).
///
/// Legacy users: when [registrationComplete] is absent but identity is
/// complete, treat as registered (grandfather).
bool isRegistrationCompleteMap(
  Map<String, dynamic>? data, {
  required bool exists,
}) {
  if (!exists || data == null) return false;

  final explicit = data['registrationComplete'];
  if (explicit is bool) return explicit;

  return isProfileMinimumCompleteMap(data, exists: exists);
}

bool isRegistrationIncompleteMap(
  Map<String, dynamic>? data, {
  required bool exists,
}) => !isRegistrationCompleteMap(data, exists: exists);

bool isRegistrationCompleteUser(AppUser? user) {
  if (user == null) return false;

  final explicit = user.registrationComplete;
  if (explicit == true) return true;
  if (explicit == false) return false;

  return isProfileMinimumCompleteUser(user);
}

/// Resume key for an authenticated user with incomplete registration.
///
/// Returns `name`, [RegistrationWizardStepKeys.referral],
/// [RegistrationWizardStepKeys.contactChannels], or null when complete.
String? registrationResumeStepKey(
  Map<String, dynamic>? data, {
  required bool exists,
}) {
  if (isRegistrationCompleteMap(data, exists: exists)) return null;
  if (!isProfileMinimumCompleteMap(data, exists: exists)) return 'name';

  final step = data?['registrationWizardStep'] as String?;
  if (step == RegistrationWizardStepKeys.contactChannels) {
    return RegistrationWizardStepKeys.contactChannels;
  }
  return RegistrationWizardStepKeys.referral;
}

String? registrationResumeStepKeyFromUser(AppUser? user) {
  if (user == null || isRegistrationCompleteUser(user)) return null;
  if (!isProfileMinimumCompleteUser(user)) return 'name';

  final step = user.registrationWizardStep;
  if (step == RegistrationWizardStepKeys.contactChannels) {
    return RegistrationWizardStepKeys.contactChannels;
  }
  return RegistrationWizardStepKeys.referral;
}
