import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repairs/presentation/widgets/repair_complete_photos_row.dart';
import '../../../repairs/presentation/widgets/repair_photo_thumbnail_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../utils/repair_timeline_resolver.dart';
import 'order_detail/order_detail_web_navigation.dart';

/// Timeline repair sub-card — driven by [repair_jobs] status and payments.
class RepairStatusCard extends ConsumerStatefulWidget {
  const RepairStatusCard({
    super.key,
    required this.orderId,
    this.repairJob,
    this.pendingPayment,
  });

  final String orderId;
  final RepairJobModel? repairJob;
  final PaymentRequestModel? pendingPayment;

  @override
  ConsumerState<RepairStatusCard> createState() => _RepairStatusCardState();
}

class _RepairStatusCardState extends ConsumerState<RepairStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  RepairJobModel? get j => widget.repairJob;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => OrderDetailWebNavigation.openRepair(
          context,
          ref,
          widget.orderId,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.borderSolid),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: j == null ? _buildNullState() : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildNullState() {
    return Row(
      children: [
        _iconCircle(Icons.build_outlined, AppColors.infoBackground, AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OrderTimelineConstants.repairTimelineNoJobDetail,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to confirm your repair preference',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.secondary),
      ],
    );
  }

  Widget _buildBody() {
    final phase = RepairTimelineResolver.phase(
      j,
      pendingPayment: widget.pendingPayment,
    );

    return switch (phase) {
      RepairTimelinePhase.noRepairs => _noRepairs(),
      RepairTimelinePhase.quotePending => _statusTile(
          icon: Icons.hourglass_empty_rounded,
          iconBg: AppColors.surface,
          iconColor: AppColors.textSecondary,
          title: OrderTimelineConstants.repairQuotePending,
          subtitle: OrderTimelineConstants.repairQuotePendingSub,
        ),
      RepairTimelinePhase.quoteSent => _quoteSent(),
      RepairTimelinePhase.quoteDeclined => _statusTile(
          icon: Icons.refresh_rounded,
          iconBg: AppColors.amberBackground,
          iconColor: AppColors.amberText,
          title: OrderTimelineConstants.repairQuoteDeclined,
          subtitle: OrderTimelineConstants.repairQuoteDeclinedSub,
        ),
      RepairTimelinePhase.quoteApprovedAwaitingRequest => _statusTile(
          icon: Icons.check_circle_outline,
          iconBg: AppColors.success.withValues(alpha: 0.12),
          iconColor: AppColors.success,
          title: OrderTimelineConstants.repairQuoteApproved,
          subtitle: OrderTimelineConstants.repairQuoteApprovedSub,
        ),
      RepairTimelinePhase.quoteApprovedDepositDue => _statusTile(
          icon: Icons.payments_outlined,
          iconBg: AppColors.amberBackground,
          iconColor: AppColors.amberText,
          title: OrderTimelineConstants.repairDepositDueTimelineDetail,
          subtitle: OrderTimelineConstants.repairQuoteApprovedSub,
        ),
      RepairTimelinePhase.quoteApprovedDepositPaid => _statusTile(
          icon: Icons.check_circle_outline,
          iconBg: AppColors.success.withValues(alpha: 0.12),
          iconColor: AppColors.success,
          title: OrderTimelineConstants.repairDepositPaid,
          subtitle: OrderTimelineConstants.repairDepositPaidSub,
        ),
      RepairTimelinePhase.inProgress => _inProgress(pulsing: true),
      RepairTimelinePhase.inProgressBalanceDue => _inProgress(
          balanceNote: OrderTimelineConstants.repairBalanceDueTimelineDetail,
          pulsing: true,
        ),
      RepairTimelinePhase.inProgressBalancePaid => _inProgress(
          balanceNote: OrderTimelineConstants.repairBalancePaidSub,
          pulsing: true,
        ),
      RepairTimelinePhase.completed => _completed(),
      _ => _statusTile(
          icon: Icons.build_outlined,
          iconBg: AppColors.infoBackground,
          iconColor: AppColors.secondary,
          title: OrderTimelineConstants.repairQuotePending,
          subtitle: OrderTimelineConstants.repairQuotePendingSub,
        ),
    };
  }

  Widget _quoteSent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusTile(
          icon: Icons.description_outlined,
          iconBg: AppColors.amberBackground,
          iconColor: AppColors.amberText,
          title: OrderTimelineConstants.repairQuoteSent,
          subtitle: OrderTimelineConstants.repairQuoteSentSub,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: FilledButton(
            onPressed: () => OrderDetailWebNavigation.openRepair(
              context,
              ref,
              widget.orderId,
            ),
            style: AppButtonStyles.primary(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Text(
              OrderTimelineConstants.viewQuote,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inProgress({String? balanceNote, bool pulsing = false}) {
    final job = j!;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusTile(
          icon: Icons.build_outlined,
          iconBg: AppColors.infoBackground,
          iconColor: AppColors.infoText,
          title: OrderTimelineConstants.repairInProgressTitle,
          subtitle:
              '${OrderTimelineConstants.repairGaragePrefix}${job.garageNameCustom ?? OrderTimelineConstants.partnerGarage}',
        ),
        if (job.estimatedCompletion != null) ...[
          const SizedBox(height: 8),
          Text(
            '${OrderTimelineConstants.repairEstCompletion}${DateFormatter.formatDate(job.estimatedCompletion)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
        if (balanceNote != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              balanceNote,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
        _photoStrip(
          job.beforePhotoUrlsJson ?? const [],
          job.afterPhotoUrlsJson ?? const [],
        ),
      ],
    );

    if (!pulsing) return content;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.82, end: 1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: content,
    );
  }

  Widget _completed() {
    final job = j!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusTile(
          icon: Icons.check_circle_outline,
          iconBg: AppColors.success.withValues(alpha: 0.12),
          iconColor: AppColors.success,
          title: OrderTimelineConstants.repairCompleteTitle,
          subtitle: OrderTimelineConstants.repairCompleteTimelineDetail,
        ),
        _photoStrip(const [], job.afterPhotoUrlsJson ?? const []),
        const SizedBox(height: 8),
        Text(
          OrderTimelineConstants.repairViewSummary,
          style: AppTextStyles.link.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _noRepairs() {
    return Row(
      children: [
        _iconCircle(
          Icons.directions_car_rounded,
          AppColors.surface,
          AppColors.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OrderTimelineConstants.repairNoRepairsTitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                OrderTimelineConstants.repairNoRepairsSub,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.secondary),
      ],
    );
  }

  Widget _statusTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconCircle(icon, iconBg, iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, Color bg, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _photoStrip(List<String> beforeUrls, List<String> afterUrls) {
    if (beforeUrls.isEmpty && afterUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: RepairJobPhotoStrip(
          beforeUrls: beforeUrls,
          afterUrls: afterUrls,
          galleryId: widget.repairJob?.id ?? widget.orderId,
          size: RepairPhotoThumbnailSize.compact,
          maxVisible: 4,
        ),
      ),
    );
  }
}

/// Context strip shown above a repair-stage payment card on the timeline.
class RepairTimelinePaymentContext extends StatelessWidget {
  const RepairTimelinePaymentContext({
    super.key,
    required this.payment,
  });

  final PaymentRequestModel payment;

  @override
  Widget build(BuildContext context) {
    final isBalance = payment.type == PaymentRequestType.repairBalance;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBalance ? Icons.build_outlined : Icons.check_circle_outline,
            size: 16,
            color: AppColors.infoText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBalance
                  ? OrderTimelineConstants.repairPaymentContextBalance
                  : OrderTimelineConstants.repairPaymentContextDeposit,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.infoText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
