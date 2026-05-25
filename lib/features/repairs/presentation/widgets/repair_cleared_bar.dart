import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/constants/repair_constants.dart';
import 'repair_formatters.dart';

class RepairClearedBar extends StatelessWidget {
  const RepairClearedBar({
    super.key,
    required this.animation,
    this.clearedAt,
  });

  final Animation<double> animation;
  final DateTime? clearedAt;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successMutedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.successMutedBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RepairConstants.clearedBarTitle,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 13,
                      color: AppColors.successMutedForeground,
                    ),
                  ),
                  if (clearedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      repairDisplayDateFormat.format(clearedAt!),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ] else
                    Text(
                      RepairConstants.clearedBarSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
