import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/styled_snackbar.dart';

import '../../../auth/domain/entities/country.dart';
import '../../../auth/domain/value_objects/phone_number.dart';
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
  final Future<void> Function() onDeleted;

  @override
  ConsumerState<ProfileDeleteAccountBottomSheet> createState() =>
      _ProfileDeleteAccountBottomSheetState();
}

class _ProfileDeleteAccountBottomSheetState
    extends ConsumerState<ProfileDeleteAccountBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _canConfirm = false;
  bool _deleting = false;
  bool _focused = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
    _controller.addListener(_syncConfirmState);
  }

  void _syncConfirmState() {
    final canConfirm = _controller.text.trim() == 'DELETE';
    if (canConfirm != _canConfirm || _error != null) {
      setState(() {
        _canConfirm = canConfirm;
        if (_error != null) _error = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_syncConfirmState);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    final sheet = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_forever_outlined,
                      color: AppColors.danger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ProfileConstants.deleteConfirmHeading,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ProfileConstants.deleteConfirmSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DeleteWarningCard(
                items: ProfileConstants.deleteConfirmBulletItems,
              ),
              const SizedBox(height: 20),
              Text(
                ProfileConstants.deleteTypeToConfirm.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _DeleteConfirmField(
                controller: _controller,
                focusNode: _focusNode,
                focused: _focused,
                confirmed: _canConfirm,
                enabled: !_deleting,
                onSubmit:
                    _canConfirm && !_deleting ? _confirmDelete : null,
              ),
              _DeleteAccountErrorBanner(message: _error),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      _deleting ? null : () => Navigator.pop(context),
                  style: AppButtonStyles.outlined(),
                  child: Text(
                    ProfileConstants.cancel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _canConfirm && !_deleting ? _confirmDelete : null,
                  style: AppButtonStyles.destructive(
                    enabled: _canConfirm && !_deleting,
                    minimumHeight: 52,
                  ),
                  child: _deleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onBrand,
                          ),
                        )
                      : Text(
                          ProfileConstants.deleteConfirmButton,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.onBrand,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: sheet,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (!_canConfirm || _deleting) return;
    setState(() {
      _deleting = true;
      _error = null;
    });

    final result = await ref
        .read(profileRepositoryProvider)
        .deleteUserAccount(widget.userId);

    if (!mounted) return;
    setState(() => _deleting = false);

    await result.fold(
      (failure) async {
        setState(() => _error = failure.message);
      },
      (_) async {
        Navigator.pop(context);
        await widget.onDeleted();
      },
    );
  }
}

class _DeleteAccountErrorBanner extends StatelessWidget {
  const _DeleteAccountErrorBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerMutedBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.22),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.dangerMutedText,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DeleteWarningCard extends StatelessWidget {
  const _DeleteWarningCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerMutedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'You will lose access to',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.dangerMutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerMutedText,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.dangerMutedText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmField extends StatelessWidget {
  const _DeleteConfirmField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.confirmed,
    required this.enabled,
    this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool confirmed;
  final bool enabled;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: confirmed
            ? AppColors.successMutedBackground
            : AppColors.surface,
        border: Border.all(
          color: confirmed
              ? AppColors.success
              : focused
              ? AppColors.brand
              : AppColors.borderSolid,
          width: confirmed || focused ? 1.25 : 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmit?.call(),
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'DELETE',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            letterSpacing: 1.2,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: confirmed
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 34,
          ),
        ),
      ),
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
    final phoneResult = PhoneNumber.fromDialCodeAndDigits(
      dialCode: _dialCode,
      digits: _phoneDigits,
    );
    final phone = phoneResult.fold<String?>((failure) {
      showErrorSnackBar(context, failure.message);
      return null;
    }, (value) => value.value);
    if (phone == null) return;

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
