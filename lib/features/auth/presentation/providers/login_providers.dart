import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/complete_profile_use_case.dart';
import '../../domain/usecases/get_authenticated_user_id_use_case.dart';
import '../../domain/usecases/request_otp_use_case.dart';
import '../../domain/usecases/save_ghana_card_use_case.dart';
import '../../domain/usecases/verify_otp_use_case.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/login_state.dart';
import 'auth_providers.dart';

final requestOtpUseCaseProvider = Provider<RequestOtpUseCase>(
  (ref) => RequestOtpUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final completeProfileUseCaseProvider = Provider<CompleteProfileUseCase>(
  (ref) => CompleteProfileUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final saveGhanaCardUseCaseProvider = Provider<SaveGhanaCardUseCase>(
  (ref) => SaveGhanaCardUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final loginNotifierProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(
    requestOtp: ref.watch(requestOtpUseCaseProvider),
    verifyOtp: ref.watch(verifyOtpUseCaseProvider),
    completeProfile: ref.watch(completeProfileUseCaseProvider),
    saveGhanaCard: ref.watch(saveGhanaCardUseCaseProvider),
    getAuthenticatedUserId: GetAuthenticatedUserIdUseCase(
      ref.watch(authRepositoryProvider),
    ),
    syncOneSignalUseCase: ref.watch(syncOneSignalUseCaseProvider)
  ),
);
