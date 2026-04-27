import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

class AgentConnectionNotFoundView extends StatelessWidget {
  const AgentConnectionNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = ResponsiveLayout.contentPadding(context);
    return Center(
      child: Padding(
        padding: pad,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Order not found',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16, height: 1.2, letterSpacing: 0.0),
            ),
            const SizedBox(height: 8),
            Text(
              'This order may have been removed or the link is invalid.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
