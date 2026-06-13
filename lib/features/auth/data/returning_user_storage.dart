import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the buyer has successfully signed in at least once.
class ReturningUserStorage {
  ReturningUserStorage(this._prefs);

  static const String storageKey = 'has_ever_signed_in';

  final SharedPreferences _prefs;

  bool get hasEverSignedIn => _prefs.getBool(storageKey) ?? false;

  Future<void> markHasEverSignedIn() async {
    await _prefs.setBool(storageKey, true);
  }
}
