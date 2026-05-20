import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AgentConnectionNextStep extends StatelessWidget {
  const AgentConnectionNextStep({
    super.key,
    required this.number,
    required this.text,
    this.isLast = false,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.selectionTint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
