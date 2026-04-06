import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes guide seen state to
/// SharedPreferences. Only this class touches
/// SharedPreferences for the guide feature.
class GuideLocalDataSource {
  const GuideLocalDataSource();

  Future<bool> hasSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> markSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// Clears all guide keys so every coach mark
  /// shows again from the beginning.
  Future<void> resetAll(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
