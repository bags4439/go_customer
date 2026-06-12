import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/onboarding_seen_storage.dart';

final onboardingSeenStorageProvider =
    FutureProvider<OnboardingSeenStorage>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return OnboardingSeenStorage(prefs);
});
