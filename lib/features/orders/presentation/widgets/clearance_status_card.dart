import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../core/constants/order_timeline_constants.dart';

const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kPrimaryText = 0xFF185FA5;
const _kInfoBg = 0xFFE6F1FB;
const _kTextSecondary = 0xFF666666;
const _kWarn = 0xFFBA7517;
const _kSuccess = 0xFF1D9E75;

/// Clearance step when duty_clearance exists (no pending clearance payment).
class ClearanceStatusCard extends StatelessWidget {
  final DutyClearanceModel clearance;
  final String orderId;

  const ClearanceStatusCard({
    super.key,
    required this.clearance,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBlock(),
          if (clearance.handledBy == 'agent') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(_kInfoBg),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                OrderTimelineConstants.managedByAgent,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kPrimaryText),
                ),
              ),
            ),
          ],
          if (clearance.handledBy == 'agent') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/order/$orderId?tab=chat'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                OrderTimelineConstants.questionsChat,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBlock() {
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
            if (clearance.totalPayableGhs != null) ...[
              const SizedBox(height: 8),
              Text(
                '${OrderTimelineConstants.clearanceTotalDuty}${CurrencyFormatter.formatGhs(clearance.totalPayableGhs!)}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
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
