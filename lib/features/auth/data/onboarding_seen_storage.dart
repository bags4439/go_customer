import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the buyer has completed the first-run onboarding carousel.
class OnboardingSeenStorage {
  OnboardingSeenStorage(this._prefs);

  static const String storageKey = 'has_seen_onboarding';

  final SharedPreferences _prefs;

  bool get hasSeenOnboarding => _prefs.getBool(storageKey) ?? false;

  Future<void> markOnboardingSeen() async {
    await _prefs.setBool(storageKey, true);
  }
}
