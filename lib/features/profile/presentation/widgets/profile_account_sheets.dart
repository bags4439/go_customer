import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/styled_snackbar.dart';

import '../../../auth/domain/entities/country.dart';
import '../../../auth/presentation/providers/auth_providers.dart'
    show startPhoneVerificationUseCaseProvider, verifyOtpUseCaseProvider;
import '../../../auth/presentation/providers/countries_providers.dart';
import '../../../auth/presentation/widgets/phone_dial_input_field.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import 'package:go_customer/core/theme/app_button_styles.dart';

class ProfileDeleteAccountBottomSheet extends ConsumerStatefulWidget {
  const ProfileDeleteAccountBottomSheet({
    super.key,
    required this.userId,
    required this.onDeleted,
  });

  final String userId;
  final VoidCallback onDeleted;

  @override
  ConsumerState<ProfileDeleteAccountBottomSheet> createState() =>
      _ProfileDeleteAccountBottomSheetState();
}

class _ProfileDeleteAccountBottomSheetState
    extends ConsumerState<ProfileDeleteAccountBottomSheet> {
  final _controller = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _canConfirm = _controller.text == 'DELETE');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ProfileConstants.deleteConfirmHeading,
            style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileConstants.deleteConfirmWarning,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amberBackground,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppColors.warning, width: 3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ProfileConstants.deleteConfirmWarning,
                    style: AppTextStyles.cardLabel.copyWith(
                      color: AppColors.amberText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: ProfileConstants.deleteTypeToConfirm,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) =>
                setState(() => _canConfirm = _controller.text == 'DELETE'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ProfileConstants.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canConfirm ? _confirmDelete : null,
                  style: AppButtonStyles.destructive(enabled: _canConfirm),
                  child: Text(
                    ProfileConstants.deleteConfirmButton,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final result = await ref
        .read(profileRepositoryProvider)
        .deleteUserAccount(widget.userId);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(context, 'Could not delete account.'),
      (_) {
        Navigator.pop(context);
        widget.onDeleted();
      },
    );
  }
}

class ProfilePhoneChangeSheet extends ConsumerStatefulWidget {
  const ProfilePhoneChangeSheet({
    super.key,
    required this.currentPhone,
    required this.onVerified,
  });

  final String currentPhone;
  final VoidCallback onVerified;

  @override
  ConsumerState<ProfilePhoneChangeSheet> createState() =>
      _ProfilePhoneChangeSheetState();
}

class _ProfilePhoneChangeSheetState
    extends ConsumerState<ProfilePhoneChangeSheet> {
  int _step = 0;
  final _otpCtrl = TextEditingController();
  bool _busy = false;
  String? _verificationId;
  int? _resendToken;
  String? _newPhone;
  int _countdown = 0;
  String _otpCode = '';
  String _phoneDigits = '';
  Timer? _countdownTimer;
  String _dialCode = '+233';
  String _countryFlag = '🇬🇭';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final iso =
          ref.read(currentUserProfileProvider).valueOrNull?.country ?? 'GH';
      setState(() {
        _dialCode = _dialCodeForCountry(iso);
        _countryFlag = _flagForCountry(iso);
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  Country? _countryMatch(String isoCode) {
    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    for (final c in countries) {
      if (c.isoCode == isoCode) return c;
    }
    return null;
  }

  String _dialCodeForCountry(String isoCode) {
    final match = _countryMatch(isoCode);
    return (match != null && match.dialCode.isNotEmpty)
        ? match.dialCode
        : '+233';
  }

  String _flagForCountry(String isoCode) {
    final match = _countryMatch(isoCode);
    return (match != null && match.flag.isNotEmpty) ? match.flag : '🇬🇭';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown <= 1) {
          _countdown = 0;
          t.cancel();
        } else {
          _countdown--;
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    final digits = _phoneDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      showErrorSnackBar(context, 'Enter a valid phone number');
      return;
    }

    final phone = '$_dialCode$digits';

    setState(() => _busy = true);

    final result = await ref
        .read(startPhoneVerificationUseCaseProvider)
        .call(phoneNumber: phone, resendToken: _resendToken);

    if (!mounted) return;
    setState(() => _busy = false);

    result.fold((f) => showErrorSnackBar(context, f.message), (session) {
      setState(() {
        _verificationId = session.verificationId;
        _resendToken = session.resendToken;
        _newPhone = phone;
        _step = 1;
        _countdown = 30;
      });
      _startCountdown();
    });
  }

  Future<void> _resend() async {
    if (_countdown > 0 || _newPhone == null) return;
    setState(() => _busy = true);

    final result = await ref
        .read(startPhoneVerificationUseCaseProvider)
        .call(phoneNumber: _newPhone!, resendToken: _resendToken);

    if (!mounted) return;
    setState(() => _busy = false);

    result.fold((f) => showErrorSnackBar(context, f.message), (session) {
      setState(() {
        _verificationId = session.verificationId;
        _resendToken = session.resendToken;
        _countdown = 30;
      });
      _startCountdown();
      showSuccessSnackBar(context, 'New code sent.');
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6 || _verificationId == null) return;
    setState(() => _busy = true);

    final result = await ref
        .read(verifyOtpUseCaseProvider)
        .call(verificationId: _verificationId!, smsCode: _otpCode);

    if (!mounted) return;

    await result.fold<Future<void>>(
      (failure) async {
        if (!mounted) return;
        setState(() => _busy = false);
        showErrorSnackBar(context, failure.message);
      },
      (userId) async {
        final updateResult = await ref
            .read(profileRepositoryProvider)
            .updatePhone(userId, _newPhone!);
        if (!mounted) return;
        setState(() => _busy = false);
        updateResult.fold((f) => showErrorSnackBar(context, f.message), (_) {
          ref.invalidate(currentUserProfileProvider);
          Navigator.pop(context);
          widget.onVerified();
          showSuccessSnackBar(context, 'Phone number updated.');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (_step == 0) ...[
            Text('Change phone number', style: AppTextStyles.appBarTitle),
            const SizedBox(height: 4),
            Text(
              'Enter your new phone number. '
              'We will send a verification code.',
              style: AppTextStyles.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            PhoneDialInputField(
              dialCode: _dialCode,
              countryFlag: _countryFlag,
              initialDigits: _phoneDigits,
              onDigitsChanged: (digits) => setState(() => _phoneDigits = digits),
              onDialCodeChanged: (code, flag) => setState(() {
                _dialCode = code;
                _countryFlag = flag;
              }),
              onSubmit: _busy ? null : _sendOtp,
              autofocus: true,
              pickerSubtitle: 'Choose the country for this phone number.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _busy ? null : _sendOtp,
                style: AppButtonStyles.primary(),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send code',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _step = 0;
                    _otpCtrl.clear();
                    _otpCode = '';
                  }),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Enter verification code',
                  style: AppTextStyles.appBarTitle,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Code sent to $_newPhone', style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),
            TextField(
              controller: _otpCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle: AppTextStyles.titleLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 12,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() => _otpCode = v);
                if (v.length == 6) _verifyOtp();
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _countdown > 0 ? null : _resend,
              child: Text(
                _countdown > 0
                    ? 'Resend code in ${_countdown}s'
                    : 'Resend code',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _countdown > 0
                      ? AppColors.textTertiary
                      : AppColors.secondary,
                  fontWeight: _countdown > 0
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: (_otpCode.length == 6 && !_busy) ? _verifyOtp : null,
                style: AppButtonStyles.primary(),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Verify & update',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
