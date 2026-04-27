import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step row with dot, optional connector, and label (searching journey).
class AgentConnectionAssignStep extends StatelessWidget {
  const AgentConnectionAssignStep({
    super.key,
    required this.done,
    required this.active,
    required this.text,
    this.isLast = false,
  });

  final bool done;
  final bool active;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.success
                      : active
                          ? AppColors.secondary
                          : AppColors.borderSolid,
                ),
                child: Icon(
                  done
                      ? Icons.check
                      : active
                          ? Icons.circle
                          : Icons.circle,
                  size: done ? 14 : 9,
                  color: (done || active)
                      ? Colors.white
                      : AppColors.textTertiary,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  color: done
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.borderSolid,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: (active
                        ? AppTextStyles.labelLarge
                        : AppTextStyles.bodyMedium)
                    .copyWith(
                  fontSize: 14,
                  color: done || active
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
