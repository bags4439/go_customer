import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/constants/repair_constants.dart';

class RepairNotAvailableState extends StatelessWidget {
  const RepairNotAvailableState({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_outlined,
              size: 72,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              RepairConstants.state0Heading,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              RepairConstants.state0Body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(height: 1.55),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/order/$orderId'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSolid),
                ),
                child: Text(
                  RepairConstants.state0BackButton,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
