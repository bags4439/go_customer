import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_formatters.dart';
import 'repair_garage_info_row.dart';
import 'repair_navigation.dart';

class RepairQuoteReceivedState extends ConsumerStatefulWidget {
  const RepairQuoteReceivedState({
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

  @override
  ConsumerState<RepairQuoteReceivedState> createState() =>
      _RepairQuoteReceivedStateState();
}

class _RepairQuoteReceivedStateState
    extends ConsumerState<RepairQuoteReceivedState> {
  bool _accepting = false;
  bool _declining = false;

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final garageAsync = ref.watch(garageDetailsProvider(widget.job.garageId));
    final garage = garageAsync.valueOrNull;
    final garageName = widget.job.garageNameCustom ?? garage?.name ?? '—';
    final garageLocation =
        widget.job.garageLocation ?? garage?.location ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            RepairConstants.state2Heading(agentName),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            RepairConstants.state2Subtitle,
            style: AppTextStyles.cardLabel.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            garageName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            garageLocation,
                            style: AppTextStyles.caption.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAEEDA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        RepairConstants.quoteBadge,
                        style: AppTextStyles.badgeText.copyWith(
                          fontSize: 10,
                          letterSpacing: 0,
                          color: const Color(0xFF633806),
                        ),
                      ),
                    ),
                  ],
                ),
                if (garage?.isVetted == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      RepairConstants.vettedBadge,
                      style: AppTextStyles.sectionLabel.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        fontSize: 10,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
                if (widget.job.estimatedCompletion != null) ...[
                  const SizedBox(height: 8),
                  RepairGarageInfoRow(
                    label: RepairConstants.estCompletionLabel,
                    value: repairDisplayDateFormat.format(
                      widget.job.estimatedCompletion!,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (widget.job.workDescription != null &&
                    widget.job.workDescription!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.workDescription!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                RepairQuotePricingSection(
                  job: widget.job,
                  currency: widget.currency,
                  showPaymentSplit: true,
                  showPaymentTiming: true,
                ),
                const SizedBox(height: 16),
                RepairDepositDueSummary(
                  job: widget.job,
                  currency: widget.currency,
                  title: RepairConstants.repairDepositAfterApprovalLabel,
                  subtitle: RepairConstants.repairDepositAfterApprovalSub,
                  accentStyle: RepairDepositSummaryStyle.afterApproval,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _accepting || _declining
                        ? null
                        : () async {
                            setState(() => _accepting = true);
                            final result = await ref
                                .read(repairRepositoryProvider)
                                .acceptQuote(widget.orderId);
                            if (!mounted) return;
                            setState(() => _accepting = false);
                            result.fold(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    RepairConstants.writeErrorMessage,
                                  ),
                                ),
                              ),
                              (_) {},
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: _accepting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(RepairConstants.acceptQuoteButton),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _accepting || _declining
                        ? null
                        : () async {
                            setState(() => _declining = true);
                            final result = await ref
                                .read(repairRepositoryProvider)
                                .declineQuote(widget.orderId);
                            if (!mounted) return;
                            setState(() => _declining = false);
                            result.fold(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    RepairConstants.writeErrorMessage,
                                  ),
                                ),
                              ),
                              (_) {},
                            );
                          },
                    child: _declining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(RepairConstants.declineQuoteButton),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: repairScreenChatTap(
              context,
              widget.orderId,
              widget.onOpenChat,
            ),
            child: Text(
              RepairConstants.askSecondQuote(agentName),
              style: AppTextStyles.link.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
