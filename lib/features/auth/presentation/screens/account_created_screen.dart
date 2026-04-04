import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../providers/auth_providers.dart';

class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registrationFormProvider);
    final name = form.fullName.trim().isEmpty ? 'there' : form.fullName.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Account created')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 22),
            const Icon(Icons.check_circle, color: Color(0xFF1D9E75), size: 96),
            const SizedBox(height: 20),
            Text(
              "You're all set, $name!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your account is ready. Tell us what car you're looking for and we'll get started.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (form.isFirstTimeBuyer)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('First-time buyer · Your agent will guide you'),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.pushNamed(RouteConstants.preferencesNew),
              child: const Text('Find my car →'),
            ),
          ],
        ),
      ),
    );
  }
}

