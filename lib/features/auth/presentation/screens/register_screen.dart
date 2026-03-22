import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isLoading = false;

  Future<void> _submit() async {
    final form = ref.read(registrationFormProvider);
    final phoneDigits = form.phoneDigits.replaceAll(RegExp(r'[^0-9]'), '');
    if (form.fullName.trim().isEmpty ||
        form.location.trim().isEmpty ||
        phoneDigits.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid registration details.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(startPhoneVerificationUseCaseProvider).call(
          phoneNumber: form.fullPhone,
        );
    if (!mounted) return;
    result.fold(
      (failure) => showFailureSnackBar(context, failure),
      (session) {
        ref.read(otpVerificationSessionProvider.notifier).state = session;
        ref.read(otpAttemptCountProvider.notifier).state = 0;
        ref.read(otpCountdownControllerProvider).start();
        context.goNamed(RouteConstants.otpVerification, extra: {'register': true});
      },
    );
    if (mounted) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registrationFormProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Full name'),
              onChanged: (v) =>
                  ref.read(registrationFormProvider.notifier).updateFullName(v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    initialValue: form.countryCode,
                    decoration: const InputDecoration(labelText: 'Code'),
                    items: const [
                      DropdownMenuItem(value: '+233', child: Text('GH +233')),
                      DropdownMenuItem(value: '+234', child: Text('NG +234')),
                      DropdownMenuItem(value: '+1', child: Text('US +1')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(registrationFormProvider.notifier)
                            .updateCountryCode(v);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone number'),
                    onChanged: (v) => ref
                        .read(registrationFormProvider.notifier)
                        .updatePhoneDigits(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Location (city)'),
              onChanged: (v) =>
                  ref.read(registrationFormProvider.notifier).updateLocation(v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              initialValue: form.isFirstTimeBuyer,
              decoration:
                  const InputDecoration(labelText: 'First time importing a car?'),
              items: const [
                DropdownMenuItem(value: true, child: Text('Yes')),
                DropdownMenuItem(value: false, child: Text('No')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref
                      .read(registrationFormProvider.notifier)
                      .updateFirstTimeBuyer(v);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: Text(_isLoading ? 'Sending...' : 'Send verification code'),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text('By continuing you agree to our '),
                InkWell(
                  onTap: () => _openUrl('https://example.com/terms'),
                  child: const Text(
                    'Terms',
                    style: TextStyle(
                      color: Color(0xFF378ADD),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(' and '),
                InkWell(
                  onTap: () => _openUrl('https://example.com/privacy'),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF378ADD),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => context.goNamed(RouteConstants.login),
              child: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

