import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../providers/repair_providers.dart';

class RepairOptionCard extends ConsumerWidget {
  const RepairOptionCard({
    super.key,
    required this.orderId,
    required this.isYes,
    required this.isSelected,
    required this.estimateLabel,
    required this.agentFirstName,
    this.coordinationFeeDisplay,
  });

  final String orderId;
  final bool isYes;
  final bool isSelected;
  final String? estimateLabel;
  final String agentFirstName;
  final CurrencyDisplay? coordinationFeeDisplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(repairChoiceProvider(orderId).notifier);
    final bullets = isYes
        ? [
            RepairConstants.optionYesBullet1,
            RepairConstants.optionYesBullet2,
            RepairConstants.optionYesBullet3,
            RepairConstants.optionYesBullet4,
          ]
        : [
            RepairConstants.optionNoBullet1,
            RepairConstants.optionNoBullet2,
            RepairConstants.optionNoBullet3(agentFirstName),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => notifier.state = isYes,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEBF4FD) : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                      color: isYes
                          ? AppColors.infoBackground
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isYes ? Icons.build : Icons.directions_car,
                      size: 22,
                      color: isYes ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isYes
                              ? RepairConstants.optionYesTitle
                              : RepairConstants.optionNoTitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (isYes && coordinationFeeDisplay != null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coordinationFeeDisplay!.primary,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (coordinationFeeDisplay!.hasSecondary)
                                Text(
                                  coordinationFeeDisplay!.secondary!,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              Text(
                                RepairConstants.optionYesPriceLabel,
                                style: AppTextStyles.sectionLabel.copyWith(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0,
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ] else if (isYes) ...[
                          Text(
                            RepairConstants.estVaries,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ] else ...[
                          Text(
                            RepairConstants.optionNoPriceLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
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
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bullets
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: AppTextStyles.cardLabel
                                              .copyWith(
                                            color: isYes
                                                ? AppColors.success
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            b,
                                            style: AppTextStyles.cardLabel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
