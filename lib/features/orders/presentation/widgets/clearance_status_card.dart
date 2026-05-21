import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import 'order_detail/order_detail_web_navigation.dart';

const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kPrimaryText = 0xFF185FA5;
const _kInfoBg = 0xFFE6F1FB;
const _kTextSecondary = 0xFF666666;
const _kWarn = 0xFFBA7517;
const _kSuccess = 0xFF1D9E75;

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
    return GestureDetector(
      onTap: () =>
          OrderDetailWebNavigation.openClearance(context, ref, orderId),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(_kSurface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x66378ADD), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBlock(preferredCurrency),
            if (clearance.handledBy == 'agent') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(_kInfoBg),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  OrderTimelineConstants.managedByAgent,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    color: const Color(_kPrimaryText),
                  ),
                ),
              ),
            ],
            if (clearance.handledBy == 'agent') ...[
              const SizedBox(height: 8),
              TextButton(
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
                    color: const Color(_kPrimary),
                  ),
                ),
              ),
            ],
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
          const Color(_kWarn),
          OrderTimelineConstants.clearanceInProgressTitle,
          OrderTimelineConstants.clearanceInProgressSub,
        );
      case GraStatus.submitted:
        return _row(
          Icons.upload_file_outlined,
          const Color(_kPrimary),
          OrderTimelineConstants.clearanceSubmittedTitle,
          OrderTimelineConstants.clearanceSubmittedSub,
        );
      case GraStatus.assessed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(
              Icons.calculate_outlined,
              const Color(_kWarn),
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
          const Color(_kPrimary),
          OrderTimelineConstants.clearancePaidTitle,
          OrderTimelineConstants.clearancePaidSub,
        );
      case GraStatus.cleared:
        return _row(
          Icons.check_circle_outline,
          const Color(_kSuccess),
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
                  color: const Color(_kTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
