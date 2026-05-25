import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'repair_formatters.dart';

class RepairTimelineStage extends StatelessWidget {
  const RepairTimelineStage({
    super.key,
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.date,
    required this.visible,
    this.pulseAnimation,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isActive;
  final DateTime? date;
  final bool visible;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF185FA5);
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDone)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else if (isActive && pulseAnimation != null)
              AnimatedBuilder(
                animation: pulseAnimation!,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(pulseAnimation!.value);
                  final scale = 1.0 + 0.4 * t;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? activeColor
                          : isDone
                          ? AppColors.textPrimary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      repairDisplayDateFormat.format(date!),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
