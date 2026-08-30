import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../providers/order_creation_context.dart';

class AssistedOrderSuccessScreen extends ConsumerWidget {
  const AssistedOrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 72,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Customer order created',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The order now belongs to the customer and has been assigned to you.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    label: 'Create another customer order',
                    onPressed: () {
                      ref.read(assistedCustomerProvider.notifier).state = null;
                      context.go('/preferences/customer');
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      ref.read(assistedCustomerProvider.notifier).state = null;
                      context.go('/home');
                    },
                    child: const Text('Return to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
