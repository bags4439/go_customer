import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _countryCode = '+233';
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must have at least 9 digits.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    ref.read(registrationFormProvider.notifier).updateCountryCode(_countryCode);
    ref.read(registrationFormProvider.notifier).updatePhoneDigits(digits);
    final result = await ref.read(startPhoneVerificationUseCaseProvider).call(
          phoneNumber: '$_countryCode$digits',
        );
    if (!mounted) return;
    result.fold(
      (failure) => showFailureSnackBar(context, failure),
      (session) {
        ref.read(otpVerificationSessionProvider.notifier).state = session;
        ref.read(otpAttemptCountProvider.notifier).state = 0;
        ref.read(otpCountdownControllerProvider).start();
        context.goNamed(RouteConstants.otpVerification, extra: {'register': false});
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    initialValue: _countryCode,
                    decoration: const InputDecoration(labelText: 'Code'),
                    items: const [
                      DropdownMenuItem(value: '+233', child: Text('GH +233')),
                      DropdownMenuItem(value: '+234', child: Text('NG +234')),
                      DropdownMenuItem(value: '+1', child: Text('US +1')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _countryCode = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone number'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendCode,
              child: Text(_isLoading ? 'Sending...' : 'Send code'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.goNamed(RouteConstants.register),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

