import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'clearance_formatters.dart';

class ClearanceTimelineStageRow extends StatelessWidget {
  const ClearanceTimelineStageRow({
    super.key,
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.date,
    required this.visible,
    this.pulseAnimation,
    this.isLast = false,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isActive;
  final DateTime? date;
  final bool visible;
  final Animation<double>? pulseAnimation;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const dotSize = 22.0;
    const lineWidth = 1.5;

    Widget dot;
    if (isDone) {
      dot = Container(
        width: dotSize,
        height: dotSize,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
      );
    } else if (isActive && pulseAnimation != null) {
      dot = AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(pulseAnimation!.value);
          return Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3 + 0.2 * t),
                  blurRadius: 6 + 4 * t,
                  spreadRadius: 1 + 2 * t,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    } else {
      dot = Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSolid, width: 1.5),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: dotSize,
              child: Column(
                children: [
                  dot,
                  if (!isLast)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: lineWidth,
                          color: isDone
                              ? AppColors.success.withValues(alpha: 0.4)
                              : AppColors.borderSolid,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isDone || isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? AppColors.secondary
                            : isDone
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        clearanceArrivalDateFormat.format(date!),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
