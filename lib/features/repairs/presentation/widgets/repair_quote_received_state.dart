import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_formatters.dart';
import 'repair_garage_info_row.dart';
import 'repair_navigation.dart';
import 'repair_quote_line_row.dart';

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
    final garageLocation = widget.job.garageLocation ?? garage?.location ?? '—';

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
                const SizedBox(height: 16),
                if (widget.job.workDescription != null &&
                    widget.job.workDescription!.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        widget.job.workDescription!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                if (widget.job.platformServiceFeeGhs != null) ...[
                  const SizedBox(height: 8),
                  RepairQuoteLineRow(
                    label: RepairConstants.platformServiceFeeLabel,
                    value: CurrencyFormatter.format(
                      widget.job.platformServiceFeeGhs! *
                          widget.currency.usdToRate,
                      widget.currency,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RepairConstants.totalLabel,
                      style: AppTextStyles.labelLarge,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.job.totalQuotedGhs != null
                              ? CurrencyFormatter.format(
                                  widget.job.totalQuotedGhs! *
                                      widget.currency.usdToRate,
                                  widget.currency,
                                )
                              : '—',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        if (widget.currency.code != 'USD' &&
                            widget.job.totalQuotedGhs != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '≈ ${CurrencyFormatter.formatUsd(
                              widget.job.totalQuotedGhs!,
                            )}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RepairGarageInfoRow(
                  label: RepairConstants.garageLabel,
                  value: garageName,
                ),
                RepairGarageInfoRow(
                  label: RepairConstants.locationLabel,
                  value: garageLocation,
                ),
                if (garage?.isVetted == true) ...[
                  const SizedBox(height: 6),
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
                if (garage?.rating != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '★ ${garage!.rating!.toStringAsFixed(1)}',
                    style: AppTextStyles.cardLabel,
                  ),
                ],
                if (widget.job.estimatedCompletion != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${RepairConstants.estCompletionLabel}: ${repairDisplayDateFormat.format(widget.job.estimatedCompletion!)}',
                    style: AppTextStyles.cardLabel,
                  ),
                ],
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
