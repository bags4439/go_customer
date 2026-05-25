import 'package:flutter/material.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/duty_clearance.dart';
import 'clearance_field_row.dart';

class ClearanceDetailsCard extends StatelessWidget {
  const ClearanceDetailsCard({
    super.key,
    required this.duty,
    required this.preferredCurrency,
  });

  final DutyClearance duty;
  final CurrencyModel preferredCurrency;

  @override
  Widget build(BuildContext context) {
    final totalFormatted = duty.totalPayableUsd != null
        ? CurrencyFormatter.formatForDisplay(
            usdAmount: duty.totalPayableUsd!,
            preferredCurrency: preferredCurrency,
          )
        : null;

    return CardContainer(
        paddingType: CardContainerPaddingType.xlarge,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            'CLEARANCE DETAILS',
            style: AppTextStyles.sectionLabel,
          ),
        ),
        Container(height: 0.5, color: AppColors.borderSolid),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (duty.icumsRef != null) ...[
                ClearanceFieldRow(label: 'ICUMS ref', value: duty.icumsRef!),
                const SizedBox(height: 10),
              ],
              if (duty.clearingAgentName != null) ...[
                ClearanceFieldRow(
                  label: 'Clearing agent',
                  value: duty.clearingAgentName!,
                ),
                const SizedBox(height: 10),
              ],
              if (totalFormatted != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderSolid,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total duty', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        totalFormatted.primary,
                        style: AppTextStyles.amountMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (totalFormatted.hasSecondary) ...[
                        const SizedBox(height: 2),
                        Text(
                          totalFormatted.secondary!,
                          style: AppTextStyles.amountSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (duty.notes != null && duty.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.secondary, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AGENT NOTE', style: AppTextStyles.badgeText),
                      const SizedBox(height: 4),
                      Text(
                        duty.notes!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ));
  }
}
