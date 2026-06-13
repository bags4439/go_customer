import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../../clearance/presentation/utils/clearance_timeline_helper.dart';
import '../../core/constants/order_timeline_constants.dart';
import 'order_detail/order_detail_web_navigation.dart';


/// Clearance step when duty_clearance exists (no pending clearance payment).
class ClearanceStatusCard extends ConsumerWidget {
  final DutyClearanceModel clearance;
  final String orderId;
  final VoidCallback? onChatTap;

  const ClearanceStatusCard({
    super.key,
    required this.clearance,
    required this.orderId,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final updateCaption = clearanceTimelineUpdateCaption(clearance);
    final agentNote = clearance.notes?.trim();
    final hasAgentNote = agentNote != null && agentNote.isNotEmpty;

    return GestureDetector(
      onTap: () =>
          OrderDetailWebNavigation.openClearance(context, ref, orderId),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (updateCaption != null) ...[
                    Text(
                      updateCaption,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.amberText,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _statusBlock(preferredCurrency),
                  if (clearance.handledBy == 'agent') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.infoBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        OrderTimelineConstants.managedByAgent,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasAgentNote) _ClearanceAgentNoteStrip(note: agentNote),
            const _ClearanceViewDetailsRow(),
            if (clearance.handledBy == 'agent' && onChatTap != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onChatTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      minimumSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      OrderTimelineConstants.questionsChat,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBlock(CurrencyModel preferredCurrency) {
    switch (clearance.graStatus) {
      case GraStatus.notStarted:
        return _row(
          Icons.pending_outlined,
          AppColors.warning,
          OrderTimelineConstants.clearanceInProgressTitle,
          OrderTimelineConstants.clearanceInProgressSub,
        );
      case GraStatus.submitted:
        return _row(
          Icons.upload_file_outlined,
          AppColors.secondary,
          OrderTimelineConstants.clearanceSubmittedTitle,
          OrderTimelineConstants.clearanceSubmittedSub,
        );
      case GraStatus.assessed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              Icons.calculate_outlined,
              AppColors.warning,
              OrderTimelineConstants.clearanceAssessedTitle,
              OrderTimelineConstants.clearanceAssessedSub,
            ),
            if (clearance.totalPayableUsd != null) ...[
              const SizedBox(height: 8),
              Text(
                '${OrderTimelineConstants.clearanceTotalDuty}${CurrencyFormatter.formatForDisplay(usdAmount: clearance.totalPayableUsd!, preferredCurrency: preferredCurrency).primary}',
                style: AppTextStyles.cardValue.copyWith(color: Colors.black87),
              ),
            ],
          ],
        );
      case GraStatus.paid:
        return _row(
          Icons.payments_outlined,
          AppColors.secondary,
          OrderTimelineConstants.clearancePaidTitle,
          OrderTimelineConstants.clearancePaidSub,
        );
      case GraStatus.cleared:
        return _row(
          Icons.check_circle_outline,
          AppColors.success,
          OrderTimelineConstants.clearanceClearedTitle,
          OrderTimelineConstants.clearanceClearedSub,
        );
    }
  }

  Widget _row(IconData icon, Color color, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardValue.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClearanceAgentNoteStrip extends StatelessWidget {
  const _ClearanceAgentNoteStrip({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OrderTimelineConstants.agentNoteLabel,
            style: AppTextStyles.badgeText.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: AppTextStyles.cardLabel.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearanceViewDetailsRow extends StatelessWidget {
  const _ClearanceViewDetailsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            OrderTimelineConstants.clearanceViewDetails,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 13,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
