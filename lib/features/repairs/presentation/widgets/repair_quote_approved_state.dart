import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../providers/repair_providers.dart';
import 'repair_formatters.dart';
import 'repair_garage_info_row.dart';
import 'repair_navigation.dart';
import 'repair_payment_prompt_card.dart';

class RepairQuoteApprovedState extends ConsumerWidget {
  const RepairQuoteApprovedState({
    super.key,
    required this.orderId,
    required this.job,
    required this.currency,
    this.onOpenChat,
  });

  final String orderId;
  final RepairJob job;
  final CurrencyModel currency;
  final VoidCallback? onOpenChat;

  String _statusSubtitle(PaymentRequestModel? pendingPayment) {
    if (job.depositPaid) {
      return RepairConstants.quoteApprovedDepositPaidSub;
    }
    if (pendingPayment != null) {
      return RepairConstants.quoteApprovedDepositDueSub;
    }
    if (job.depositPaymentRequestId != null) {
      return RepairConstants.quoteApprovedDepositConfirmingSub;
    }
    return RepairConstants.quoteApprovedDepositPendingSub;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(repairPendingPaymentProvider(orderId));
    final pendingPayment = pendingAsync.valueOrNull;
    final agentName =
        ref.watch(agentFirstNameProvider(orderId)).valueOrNull ?? 'Your agent';
    final garageName = job.garageNameCustom ?? 'Partner garage';

    return SingleChildScrollView(
      padding: DashboardLayout.flowScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RepairConstants.quoteApprovedHeroTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusSubtitle(pendingPayment),
                        style: AppTextStyles.cardLabel.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!job.depositPaid) ...[
            const SizedBox(height: 16),
            RepairDepositDueSummary(job: job, currency: currency),
          ],
          if (pendingPayment != null) ...[
            const SizedBox(height: 16),
            RepairPaymentPromptCard(
              orderId: orderId,
              payment: pendingPayment,
              currency: currency,
              buttonLabel: pendingPayment.type == PaymentRequestType.repairBalance
                  ? RepairConstants.payRepairBalanceButton
                  : RepairConstants.payRepairDepositButton,
            ),
          ],
          const SizedBox(height: 20),
          CardContainer(
            paddingType: CardContainerPaddingType.xlarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RepairConstants.approvedQuoteSummaryLabel,
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                RepairGarageInfoRow(
                  label: RepairConstants.garageLabel,
                  value: garageName,
                ),
                if (job.garageLocation != null &&
                    job.garageLocation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  RepairGarageInfoRow(
                    label: RepairConstants.locationLabel,
                    value: job.garageLocation!,
                  ),
                ],
                if (job.workDescription != null &&
                    job.workDescription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    job.workDescription!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                RepairQuotePricingSection(
                  job: job,
                  currency: currency,
                  showPaymentSplit: true,
                  showPaymentTiming: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderSolid),
              ),
              child: Text(
                RepairConstants.askAgentButton(agentName),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
