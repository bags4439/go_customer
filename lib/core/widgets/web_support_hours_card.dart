import 'package:flutter/material.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

/// Support hours card for the web dashboard right panel.
/// Matches the hours card inside [SupportBottomSheet] exactly.
class WebSupportHoursCard extends StatelessWidget {
  const WebSupportHoursCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 5),
              Text(
                'SUPPORT HOURS',
                style: AppTextStyles.badgeText.copyWith(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _HoursRow(day: 'Monday – Friday', hours: '8:00 AM – 6:00 PM'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: AppColors.borderSolid),
          ),
          const _HoursRow(day: 'Saturday', hours: '9:00 AM – 2:00 PM'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: AppColors.borderSolid),
          ),
          const _HoursRow(day: 'Sunday', hours: 'Closed', isClosed: true),
        ],
      ),
    );
  }
}

/// Single hours row.
/// Private — only used by [WebSupportHoursCard].
/// Matches [_HoursRow] in [SupportBottomSheet] exactly.
class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  final String day;
  final String hours;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.0,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
          ),
        ),
        Text(
          hours,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 13,
            color: isClosed ? AppColors.textTertiary : AppColors.textPrimary,
            fontWeight: isClosed ? FontWeight.w400 : FontWeight.w500,
            letterSpacing: 0.0,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
