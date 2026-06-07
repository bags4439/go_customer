import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';

/// Fixed header + scrollable body for embedded order tasks on web.
class OrderDetailWebPanelChrome extends StatelessWidget {
  const OrderDetailWebPanelChrome({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.orderRef,
    this.backLabel = 'Back',
    this.trailing,
  });

  final String title;
  final String? orderRef;
  final String backLabel;
  final VoidCallback onBack;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColors.borderSolid,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      backLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    trailing!,
                    if (orderRef != null) const SizedBox(width: 8),
                  ],
                  if (orderRef != null)
                    Text(
                      orderRef!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 0.5, color: AppColors.borderSolid),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
