import 'package:flutter/material.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import 'repair_done_row.dart';

class RepairCompleteWorkCard extends StatelessWidget {
  const RepairCompleteWorkCard({
    super.key,
    required this.job,
    required this.currency,
  });

  final RepairJob job;
  final CurrencyModel currency;

  @override
  Widget build(BuildContext context) {
    final totalPaid = job.finalCostGhs ?? job.totalQuotedGhs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
          Text(
            RepairConstants.workCompletedLabel,
            style: AppTextStyles.sectionLabel.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          if (job.workDescription != null && job.workDescription!.isNotEmpty)
            RepairDoneRow(label: job.workDescription!),
          if (job.platformServiceFeeGhs != null)
            RepairDoneRow(
              label:
                  '${RepairConstants.platformServiceFeeLabel} ${CurrencyFormatter.format(
                job.platformServiceFeeGhs! * currency.usdToRate,
                currency,
              )}',
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                RepairConstants.totalPaidLabel,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalPaid != null
                        ? CurrencyFormatter.format(
                            totalPaid * currency.usdToRate,
                            currency,
                          )
                        : '—',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                  ),
                  if (currency.code != 'USD' && totalPaid != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${CurrencyFormatter.formatUsd(totalPaid)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
