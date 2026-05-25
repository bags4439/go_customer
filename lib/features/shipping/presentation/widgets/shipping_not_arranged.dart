import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ShippingNotArranged extends StatelessWidget {
  const ShippingNotArranged({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: ValueKey('not_arranged_$orderId'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              'Shipping not yet arranged',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Your agent will update this screen once your vehicle has '
              'been booked for shipping.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                '← Back to order',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
