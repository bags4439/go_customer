import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';

class RepairCompleteDeliveryCard extends StatelessWidget {
  const RepairCompleteDeliveryCard({
    super.key,
    required this.orderId,
    required this.agentName,
    this.onOpenDelivery,
  });

  final String orderId;
  final String agentName;
  final VoidCallback? onOpenDelivery;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF185FA5);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        border: Border.all(color: const Color(0xFFB5D4F4)),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            RepairConstants.readyForDeliveryLabel,
            style: AppTextStyles.labelSmall.copyWith(color: activeColor),
          ),
          const SizedBox(height: 8),
          Text(
            RepairConstants.state4DeliveryBody(agentName),
            style: AppTextStyles.cardLabel.copyWith(
              color: activeColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed:
                  onOpenDelivery ??
                  () => context.push('/order/$orderId/delivery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                RepairConstants.confirmDeliveryButton,
                style: AppTextStyles.buttonMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
