import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/entities/app_user.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/auth_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final bool registerFlow;
  final bool phoneChange;
  final String? newPhone;

  const OtpVerificationScreen({
    super.key,
    required this.registerFlow,
    this.phoneChange = false,
    this.newPhone,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _controllers =
      List.generate(6, (_) => TextEditingController(), growable: false);
  final _focusNodes = List.generate(6, (_) => FocusNode(), growable: false);
  bool _isBusy = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((e) => e.text).join();

  Future<void> _verify() async {
    final session = ref.read(otpVerificationSessionProvider);
    if (session == null) return;
    final attempts = ref.read(otpAttemptCountProvider);
    if (attempts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max OTP attempts reached. Try again later.')),
      );
      return;
    }
    if (DateTime.now().isAfter(session.expiresAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP expired. Please request a new code.')),
      );
      return;
    }
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code.')),
      );
      return;
    }

    ref.read(otpAttemptCountProvider.notifier).state = attempts + 1;
    setState(() => _isBusy = true);
    final verifyResult = await ref.read(verifyOtpUseCaseProvider).call(
          verificationId: session.verificationId,
          smsCode: _code,
        );
    if (!mounted) return;
    await verifyResult.fold(
      (failure) async {
        await showFailureSnackBar(context, failure);
      },
      (userId) async {
        if (widget.registerFlow) {
          final form = ref.read(registrationFormProvider);
          final registerResult = await ref.read(registerUserUseCaseProvider).call(
                RegisterUserParams(
                  userId: userId,
                  fullName: form.fullName.trim(),
                  phone: form.fullPhone,
                  email: null,
                  location: form.location.trim(),
                  isFirstTimeBuyer: form.isFirstTimeBuyer,
                ),
              );
          final syncResult =
              await ref.read(syncOneSignalUseCaseProvider).call(userId);
          if (!mounted) return;
          registerResult.fold(
            (f) => showFailureSnackBar(context, f),
            (_) => syncResult.fold(
              (f) => showFailureSnackBar(context, f),
              (_) => context.goNamed(RouteConstants.idUpload),
            ),
          );
        } else {
          if (widget.phoneChange && widget.newPhone != null) {
            final updateResult = await ref
                .read(profileRepositoryProvider)
                .updatePhone(userId, widget.newPhone!);
            if (!mounted) return;
            updateResult.fold(
              (f) => showFailureSnackBar(context, f),
              (_) {
                ref.invalidate(currentUserProfileProvider);
                context.goNamed(RouteConstants.profile);
              },
            );
            return;
          }
          final syncResult =
              await ref.read(syncOneSignalUseCaseProvider).call(userId);
          final profileResult =
              await ref.read(getCurrentUserUseCaseProvider).call();
          if (!mounted) return;
          syncResult.fold(
            (f) => showFailureSnackBar(context, f),
            (_) {
              profileResult.fold(
                (f) => showFailureSnackBar(context, f),
                (_) => context.goNamed(RouteConstants.home),
              );
            },
          );
        }
      },
    );
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _resend() async {
    final timer = ref.read(otpTimerProvider);
    if (timer > 0) return;

    final form = ref.read(registrationFormProvider);
    final existing = ref.read(otpVerificationSessionProvider);
    final result = await ref.read(startPhoneVerificationUseCaseProvider).call(
          phoneNumber: form.fullPhone,
          resendToken: existing?.resendToken,
        );
    if (!mounted) return;
    result.fold(
      (failure) => showFailureSnackBar(context, failure),
      (session) {
        ref.read(otpVerificationSessionProvider.notifier).state = session;
        ref.read(otpCountdownControllerProvider).start();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(otpTimerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your number')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter the 6-digit code sent to your phone'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 46,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(timer > 0 ? 'Resend in ${timer}s' : 'You can resend code now'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: timer > 0 ? null : _resend,
              child: const Text('Resend code'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isBusy ? null : _verify,
              child: Text(_isBusy ? 'Verifying...' : 'Verify & continue'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Use a different number'),
            ),
          ],
        ),
      ),
    );
  }
}

