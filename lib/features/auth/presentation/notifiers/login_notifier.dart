import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/features/auth/domain/usecases/sync_onesignal_use_case.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../domain/usecases/complete_profile_use_case.dart';
import '../../domain/usecases/get_authenticated_user_id_use_case.dart';
import '../../domain/usecases/request_otp_use_case.dart';
import '../../domain/usecases/verify_otp_use_case.dart';
import '../../domain/value_objects/phone_number.dart';
import 'login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({
    required Ref ref,
    required RequestOtpUseCase requestOtp,
    required VerifyOtpUseCase verifyOtp,
    required CompleteProfileUseCase completeProfile,
    required GetAuthenticatedUserIdUseCase getAuthenticatedUserId,
    required SyncOneSignalUseCase syncOneSignalUseCase,
  }) : _ref = ref,
       _requestOtp = requestOtp,
       _verifyOtp = verifyOtp,
       _completeProfile = completeProfile,
       _getAuthenticatedUserId = getAuthenticatedUserId,
       _syncOneSignalUseCase = syncOneSignalUseCase,
       super(const LoginState());

  final Ref _ref;
  final RequestOtpUseCase _requestOtp;
  final VerifyOtpUseCase _verifyOtp;
  final CompleteProfileUseCase _completeProfile;
  final GetAuthenticatedUserIdUseCase _getAuthenticatedUserId;
  final SyncOneSignalUseCase _syncOneSignalUseCase;
  Timer? _resendTimer;
  bool _alive = true;

  // ─────────────────────────────────────────────────
  // Input Updates — called on every keystroke
  // ─────────────────────────────────────────────────

  void updatePhone(String v) => state = state.copyWith(phone: v, error: null);

  void updateDialCode(String dialCode, String flag) {
    state = state.copyWith(dialCode: dialCode, countryFlag: flag, error: null);
  }

  void updateOtp(String v) => state = state.copyWith(otp: v, error: null);

  void updateFullName(String v) =>
      state = state.copyWith(fullName: v, error: null);

  void updateCountry(String isoCode) => state = state.copyWith(
    country: isoCode,
    error: null,
    idDocumentType: isoCode == 'GH' ? 'ghana_card' : 'passport',
  );

  void updateReferralCode(String v) => state = state.copyWith(referralCode: v);

  void updateIdDocumentType(String type) =>
      state = state.copyWith(idDocumentType: type);

  void updateSmsPhone(String value) {
    state = state.copyWith(smsPhone: value, error: null);
  }

  void updateWhatsappPhone(String value) {
    state = state.copyWith(whatsappPhone: value, error: null);
  }

  void updateContactEmail(String value) {
    state = state.copyWith(email: value, error: null);
  }

  void updateSmsDialCode(String dialCode, String flag) {
    state = state.copyWith(smsDialCode: dialCode, smsCountryFlag: flag);
  }

  void updateWhatsappDialCode(String dialCode, String flag) {
    state = state.copyWith(
      whatsappDialCode: dialCode,
      whatsappCountryFlag: flag,
    );
  }

  // ─────────────────────────────────────────────────
  // Step 1 — Request OTP
  // ─────────────────────────────────────────────────

  Future<void> requestOtp() async {
    final phoneResult = PhoneNumber.fromDialCodeAndDigits(
      dialCode: state.dialCode,
      digits: state.phone,
    );
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
    if (state.country.isEmpty) {
      state = state.copyWith(error: 'Please select your country');
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
        final result = await _completeProfile(
          uid: uid,
          fullName: name,
          country: state.country,
        );
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

  void proceedToContactChannels() {
    state = state.copyWith(
      step: LoginStep.contactChannels,
      error: null,
      idDocumentType: state.country == 'GH' ? 'ghana_card' : 'passport',
    );
  }

  void skipReferral() => proceedToContactChannels();

  // ─────────────────────────────────────────────────
  // Step 5 — Contact channels
  // ─────────────────────────────────────────────────

  Future<void> saveContactChannelsAndFinish() async {
    final smsDigits = state.smsPhone.trim().replaceAll(RegExp(r'\D'), '');
    final whatsappDigits = state.whatsappPhone.trim().replaceAll(
      RegExp(r'\D'),
      '',
    );
    final email = state.email.trim();

    if (smsDigits.isEmpty) {
      state = state.copyWith(error: 'Please enter your SMS number');
      return;
    }

    final smsE164 = PhoneNumber.fromDialCodeAndDigits(
      dialCode: state.smsDialCode,
      digits: smsDigits,
    );
    final smsResolved = smsE164.fold<String?>((f) => null, (p) => p.value);
    if (smsResolved == null) {
      state = state.copyWith(error: smsE164.fold((f) => f.message, (_) => ''));
      return;
    }

    String? whatsappE164Value;
    if (whatsappDigits.isNotEmpty) {
      final waResult = PhoneNumber.fromDialCodeAndDigits(
        dialCode: state.whatsappDialCode,
        digits: whatsappDigits,
      );
      whatsappE164Value = waResult.fold((f) {
        state = state.copyWith(error: f.message);
        return null;
      }, (p) => p.value);
      if (whatsappE164Value == null) return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final uidResult = await _getAuthenticatedUserId();
    if (!_alive) return;
    if (uidResult.isLeft()) {
      state = state.copyWith(
        isLoading: false,
        error: uidResult.fold((f) => f.message, (_) => ''),
      );
      return;
    }

    final uid = uidResult.getOrElse(() => '');

    try {
      final firestore = _ref.read(firestoreProvider);
      final updates = <String, dynamic>{
        'role': FirestoreEnumValues.roleBuyer,
        'smsPhone': smsResolved,
        if (whatsappE164Value != null) 'whatsappPhone': whatsappE164Value,
        if (email.isNotEmpty) 'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update(updates);
    } catch (_) {
      // Non-fatal — proceed to home even if contact save fails
    }

    if (!_alive) return;
    state = state.copyWith(isLoading: false, nav: LoginNav.goHome);
  }

  void skipContactChannelsAndFinish() {
    state = state.copyWith(nav: LoginNav.goHome);
  }

  // ─────────────────────────────────────────────────
  // Navigation helpers
  // ─────────────────────────────────────────────────

  void goBackToPhone() {
    _resendTimer?.cancel();
    state = const LoginState();
  }

  /// Goes back one onboarding step.
  /// Only valid for steps that have
  /// a previous step:
  ///   referral → name
  ///   contactChannels → referral
  void goBack() {
    switch (state.step) {
      case LoginStep.referral:
        state = state.copyWith(step: LoginStep.name, error: null);
        break;
      case LoginStep.contactChannels:
        state = state.copyWith(step: LoginStep.referral, error: null);
        break;
      default:
        break;
    }
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
