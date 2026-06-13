import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/returning_user_storage.dart';

final returningUserStorageProvider =
    FutureProvider<ReturningUserStorage>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ReturningUserStorage(prefs);
});

/// True when the buyer has completed OTP auth at least once before.
final isReturningLoginUserProvider = FutureProvider<bool>((ref) async {
  final storage = await ref.watch(returningUserStorageProvider.future);
  return storage.hasEverSignedIn;
});
