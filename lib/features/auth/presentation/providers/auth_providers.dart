import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/crash_reporter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/auth_firebase_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/start_phone_verification_use_case.dart';
import '../../domain/usecases/sync_onesignal_use_case.dart';
import '../../domain/usecases/verify_phone_otp_uid_use_case.dart';

final authDataSourceProvider = Provider<AuthFirebaseDataSource>((ref) {
  return AuthFirebaseDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final startPhoneVerificationUseCaseProvider =
    Provider<StartPhoneVerificationUseCase>((ref) {
  return StartPhoneVerificationUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyPhoneOtpUidUseCase>((ref) {
  return VerifyPhoneOtpUidUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final syncOneSignalUseCaseProvider = Provider<SyncOneSignalUseCase>((ref) {
  return SyncOneSignalUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Side-effect provider — sets Crashlytics
/// user identity whenever auth state changes.
/// Must be watched somewhere that is always
/// alive (e.g. the root widget or shell).
final crashlyticsUserSyncProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  authState.whenData((uid) {
    CrashReporter.setUser(uid);
  });
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final result = await ref.watch(getCurrentUserUseCaseProvider).call();
  return result.fold((_) => null, (user) => user);
});
