import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'package:go_customer/core/theme/app_colors.dart';

class HomeMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final bool pulse;

  const HomeMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pulse
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.borderSolid,
          width: pulse ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
