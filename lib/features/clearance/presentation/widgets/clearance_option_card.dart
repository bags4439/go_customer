import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/clearance_constants.dart';
import '../providers/clearance_providers.dart';

class ClearanceOptionCard extends ConsumerWidget {
  const ClearanceOptionCard({
    super.key,
    required this.orderId,
    required this.type,
    required this.isSelected,
    required this.agentFirstName,
    required this.priceLabel,
    required this.priceSubLabel,
    required this.bullets,
    required this.iconBgColor,
    required this.iconData,
  });

  final String orderId;
  final ClearanceOption type;
  final bool isSelected;
  final String agentFirstName;
  final String? priceLabel;
  final String priceSubLabel;
  final List<String> bullets;
  final Color iconBgColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      selectedClearanceOptionProvider(orderId).notifier,
    );
    final isSubmitting = ref.watch(clearanceChoiceSubmittingProvider(orderId));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSubmitting ? null : () => notifier.state = type,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectionTint : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type == ClearanceOption.agentHandles
                              ? ClearanceConstants.optionAgentTitle
                              : ClearanceConstants.optionSelfTitle,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (priceLabel != null)
                              Text(
                                priceLabel!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: type == ClearanceOption.selfClearance
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              priceSubLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bullets
                          .map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(color: AppColors.textTertiary),
                                  ),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: AppTextStyles.cardLabel
                                          .copyWith(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                crossFadeState: isSelected
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
