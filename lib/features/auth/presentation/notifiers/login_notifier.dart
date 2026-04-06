import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/features/auth/domain/usecases/sync_onesignal_use_case.dart';

import '../../domain/usecases/complete_profile_use_case.dart';
import '../../domain/usecases/get_authenticated_user_id_use_case.dart';
import '../../domain/usecases/request_otp_use_case.dart';
import '../../domain/usecases/save_ghana_card_use_case.dart';
import '../../domain/usecases/verify_otp_use_case.dart';
import '../../domain/value_objects/phone_number.dart';
import 'login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({
    required RequestOtpUseCase requestOtp,
    required VerifyOtpUseCase verifyOtp,
    required CompleteProfileUseCase completeProfile,
    required SaveGhanaCardUseCase saveGhanaCard,
    required GetAuthenticatedUserIdUseCase getAuthenticatedUserId,
    required SyncOneSignalUseCase syncOneSignalUseCase,
  }) : _requestOtp = requestOtp,
       _verifyOtp = verifyOtp,
       _completeProfile = completeProfile,
       _saveGhanaCard = saveGhanaCard,
       _getAuthenticatedUserId = getAuthenticatedUserId,
       _syncOneSignalUseCase = syncOneSignalUseCase,
       super(const LoginState());

  final RequestOtpUseCase _requestOtp;
  final VerifyOtpUseCase _verifyOtp;
  final CompleteProfileUseCase _completeProfile;
  final SaveGhanaCardUseCase _saveGhanaCard;
  final GetAuthenticatedUserIdUseCase _getAuthenticatedUserId;
  final SyncOneSignalUseCase _syncOneSignalUseCase;
  Timer? _resendTimer;
  bool _alive = true;

  // ─────────────────────────────────────────────────
  // Input Updates — called on every keystroke
  // ─────────────────────────────────────────────────

  void updatePhone(String v) => state = state.copyWith(phone: v, error: null);

  void updateOtp(String v) => state = state.copyWith(otp: v, error: null);

  void updateFullName(String v) =>
      state = state.copyWith(fullName: v, error: null);

  void updateReferralCode(String v) => state = state.copyWith(referralCode: v);

  void updateGhanaCardNumber(String v) =>
      state = state.copyWith(ghanaCardNumber: v);

  void setGhanaCardPhoto(String path) =>
      state = state.copyWith(ghanaCardPhotoPath: path);

  void clearGhanaCardPhoto() =>
      state = state.copyWith(ghanaCardPhotoPath: null);

  // ─────────────────────────────────────────────────
  // Step 1 — Request OTP
  // ─────────────────────────────────────────────────

  Future<void> requestOtp() async {
    final phoneResult = PhoneNumber.create(state.phone);
    await phoneResult.fold(
      (failure) async {
        state = state.copyWith(error: failure.message);
      },
      (phoneNumber) async {
        state = state.copyWith(isLoading: true, error: null);
        final result = await _requestOtp(phoneNumber);
        if (!_alive) return;
        result.fold(
          (failure) =>
              state = state.copyWith(isLoading: false, error: failure.message),
          (verificationId) {
            state = state.copyWith(
              isLoading: false,
              step: LoginStep.otp,
              verificationId: verificationId,
              otp: '',
              error: null,
            );
            _startResendCountdown();
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────
  // Step 2 — Verify OTP
  // ─────────────────────────────────────────────────

  Future<void> verifyOtp() async {
    if (state.otp.length != 6) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _verifyOtp(
      verificationId: state.verificationId,
      smsCode: state.otp,
    );

    if (!_alive) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        otp: '',
      ),
      (result) async {
        final (uid, isNewUser) = result;
        await _syncOneSignalUseCase.call(uid);
        if (isNewUser) {
          state = state.copyWith(
            isLoading: false,
            step: LoginStep.name,
            error: null,
          );
        } else {
          state = state.copyWith(isLoading: false, nav: LoginNav.goHome);
        }
      },
    );
  }

  // ─────────────────────────────────────────────────
  // Step 3 — Complete Profile (name + referral code gen)
  // ─────────────────────────────────────────────────

  Future<void> completeProfile() async {
    final name = state.fullName.trim();
    if (name.length < 2) {
      state = state.copyWith(error: 'Please enter your full name');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    final uidResult = await _getAuthenticatedUserId();
    if (!_alive) return;
    await uidResult.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (uid) async {
        final result = await _completeProfile(uid: uid, fullName: name);
        if (!_alive) return;
        result.fold(
          (failure) =>
              state = state.copyWith(isLoading: false, error: failure.message),
          (code) => state = state.copyWith(
            isLoading: false,
            generatedReferralCode: code,
            step: LoginStep.referral,
            error: null,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────
  // Step 4 — Referral Code
  // ─────────────────────────────────────────────────

  void proceedToGhanaCard() {
    state = state.copyWith(step: LoginStep.ghanaCard, error: null);
  }

  void skipReferral() => proceedToGhanaCard();

  // ─────────────────────────────────────────────────
  // Step 5 — Ghana Card
  // ─────────────────────────────────────────────────

  Future<void> saveGhanaCardAndFinish() async {
    final idNumber = state.ghanaCardNumber.trim();
    final photoPath = state.ghanaCardPhotoPath;
    final hasData = idNumber.isNotEmpty || photoPath != null;

    if (hasData) {
      state = state.copyWith(
        isLoading: true,
        isUploadingPhoto: photoPath != null,
        error: null,
      );
      final uidResult = await _getAuthenticatedUserId();
      if (!_alive) return;
      if (uidResult.isLeft()) {
        state = state.copyWith(
          isLoading: false,
          isUploadingPhoto: false,
          error: uidResult.fold((f) => f.message, (_) => ''),
        );
        return;
      }
      final uid = uidResult.getOrElse(() => '');
      final result = await _saveGhanaCard(
        uid: uid,
        idNumber: idNumber.isEmpty ? null : idNumber,
        photoPath: photoPath,
      );
      if (!_alive) return;
      if (result.isLeft()) {
        final message = result.fold((f) => f.message, (_) => '');
        state = state.copyWith(
          isLoading: false,
          isUploadingPhoto: false,
          error: message,
        );
        return;
      }
    }

    if (!_alive) return;
    state = state.copyWith(
      isLoading: false,
      isUploadingPhoto: false,
      nav: LoginNav.goHome,
    );
  }

  void skipGhanaCardAndFinish() {
    state = state.copyWith(nav: LoginNav.goHome);
  }

  // ─────────────────────────────────────────────────
  // Navigation helpers
  // ─────────────────────────────────────────────────

  void goBackToPhone() {
    _resendTimer?.cancel();
    state = const LoginState();
  }

  // ─────────────────────────────────────────────────
  // OTP Resend Countdown
  // ─────────────────────────────────────────────────

  void _startResendCountdown() {
    _resendTimer?.cancel();
    state = state.copyWith(resendCountdown: 60, resendEnabled: false);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_alive) {
        timer.cancel();
        return;
      }
      if (state.resendCountdown <= 1) {
        timer.cancel();
        state = state.copyWith(resendCountdown: 0, resendEnabled: true);
      } else {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      }
    });
  }

  Future<void> resendOtp() async {
    if (!state.resendEnabled) return;
    await requestOtp();
  }

  @override
  void dispose() {
    _alive = false;
    _resendTimer?.cancel();
    super.dispose();
  }
}
