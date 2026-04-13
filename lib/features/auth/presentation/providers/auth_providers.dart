import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/crash_reporter.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/auth_firebase_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/register_user_use_case.dart';
import '../../domain/usecases/start_phone_verification_use_case.dart';
import '../../domain/usecases/sync_onesignal_use_case.dart';
import '../../domain/usecases/upload_id_document_use_case.dart';
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

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  return RegisterUserUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final uploadIdDocumentUseCaseProvider = Provider<UploadIdDocumentUseCase>((ref) {
  return UploadIdDocumentUseCase(ref.watch(authRepositoryProvider));
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

class RegistrationFormState {
  final String fullName;
  final String countryCode;
  final String phoneDigits;
  final String location;
  final bool isFirstTimeBuyer;

  const RegistrationFormState({
    this.fullName = '',
    this.countryCode = '+233',
    this.phoneDigits = '',
    this.location = '',
    this.isFirstTimeBuyer = true,
  });

  String get fullPhone => '$countryCode$phoneDigits';

  RegistrationFormState copyWith({
    String? fullName,
    String? countryCode,
    String? phoneDigits,
    String? location,
    bool? isFirstTimeBuyer,
  }) {
    return RegistrationFormState(
      fullName: fullName ?? this.fullName,
      countryCode: countryCode ?? this.countryCode,
      phoneDigits: phoneDigits ?? this.phoneDigits,
      location: location ?? this.location,
      isFirstTimeBuyer: isFirstTimeBuyer ?? this.isFirstTimeBuyer,
    );
  }
}

class RegistrationFormNotifier extends StateNotifier<RegistrationFormState> {
  RegistrationFormNotifier() : super(const RegistrationFormState());

  void updateFullName(String value) => state = state.copyWith(fullName: value);
  void updateCountryCode(String value) =>
      state = state.copyWith(countryCode: value);
  void updatePhoneDigits(String value) =>
      state = state.copyWith(phoneDigits: value.replaceAll(RegExp(r'[^0-9]'), ''));
  void updateLocation(String value) => state = state.copyWith(location: value);
  void updateFirstTimeBuyer(bool value) =>
      state = state.copyWith(isFirstTimeBuyer: value);
}

final registrationFormProvider =
    StateNotifierProvider<RegistrationFormNotifier, RegistrationFormState>(
  (ref) => RegistrationFormNotifier(),
);

final otpTimerProvider = StateProvider<int>((ref) => 30);

final otpVerificationSessionProvider = StateProvider<PhoneVerificationSession?>(
  (ref) => null,
);

final otpAttemptCountProvider = StateProvider<int>((ref) => 0);

final selectedIdFileProvider = StateProvider<PlatformFile?>((ref) => null);

final otpCountdownControllerProvider = Provider<OtpCountdownController>((ref) {
  return OtpCountdownController(ref);
});

class OtpCountdownController {
  final Ref _ref;
  Timer? _timer;

  OtpCountdownController(this._ref);

  void start() {
    _timer?.cancel();
    _ref.read(otpTimerProvider.notifier).state = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _ref.read(otpTimerProvider);
      if (current <= 0) {
        timer.cancel();
      } else {
        _ref.read(otpTimerProvider.notifier).state = current - 1;
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

