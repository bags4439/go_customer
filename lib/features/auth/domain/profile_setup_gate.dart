import 'entities/app_user.dart';

/// Minimum buyer profile required before entering the main app shell.
///
/// Matches [AuthRepositoryImpl.verifyOtp] new-user detection plus [country],
/// which is always written with [fullName] in [completeProfile].
bool isProfileMinimumCompleteMap(Map<String, dynamic>? data, {required bool exists}) {
  if (!exists || data == null) return false;
  final fullName = data['fullName'] as String?;
  if (fullName == null || fullName.trim().isEmpty) return false;
  final country = data['country'] as String?;
  if (country == null || country.trim().isEmpty) return false;
  return true;
}

bool isProfileMinimumIncompleteMap(Map<String, dynamic>? data, {required bool exists}) =>
    !isProfileMinimumCompleteMap(data, exists: exists);

bool isProfileMinimumCompleteUser(AppUser? user) {
  if (user == null) return false;
  return user.fullName.trim().isNotEmpty && user.country.trim().isNotEmpty;
}
