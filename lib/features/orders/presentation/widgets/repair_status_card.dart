import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import 'order_detail/order_detail_web_navigation.dart';

const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kTextSecondary = 0xFF666666;
const _kSuccess = 0xFF1D9E75;

/// Repair step when repair_jobs exists (no pending repair payment).
class RepairStatusCard extends ConsumerStatefulWidget {
  final RepairJobModel? repairJob;
  final String orderId;

  const RepairStatusCard({super.key, required this.orderId, this.repairJob});

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

  RepairJobModel get j => widget.repairJob!;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => OrderDetailWebNavigation.openRepair(
        context,
        ref,
        widget.orderId,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(_kSurface),
          borderRadius: BorderRadius.circular(10),
        ),
        child: widget.repairJob == null
            ? _buildNullState(context)
            : _buildBody(context),
      ),
    );
  }

  Widget _buildNullState(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.build_outlined, size: 16, color: Color(_kPrimary)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arrange repairs',
                style: AppTextStyles.cardValue.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to confirm your repair preference',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(_kTextSecondary),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Color(_kPrimary)),
      ],
    );
  }

  Widget _photoRow(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();
    const maxShow = 3;
    final show = urls.take(maxShow).toList();
    final more = urls.length - show.length;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          ...show.map(
            (u) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: u,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (more > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                OrderTimelineConstants.morePhotos.replaceAll('[n]', '$more'),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: const Color(_kTextSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (j.status) {
      case RepairStatus.notStarted:
        return _textBlock(
          OrderTimelineConstants.repairQuotePending,
          OrderTimelineConstants.repairQuotePendingSub,
        );
      case RepairStatus.quoteSent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textBlock(
              OrderTimelineConstants.repairQuoteSent,
              OrderTimelineConstants.repairQuoteSentSub,
            ),
            TextButton(
              onPressed: () {
                // final id = j.orderId;
                OrderDetailWebNavigation.openRepair(
                  context,
                  ref,
                  widget.orderId,
                );
              },
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(
                OrderTimelineConstants.viewQuote,
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(_kPrimary),
                ),
              ),
            ),
          ],
        );
      case RepairStatus.quoteApproved:
        return _textBlock(
          OrderTimelineConstants.repairQuoteApproved,
          OrderTimelineConstants.repairQuoteApprovedSub,
        );
      case RepairStatus.quoteDeclined:
        return _textBlock(
          OrderTimelineConstants.repairQuoteDeclined,
          OrderTimelineConstants.repairQuoteDeclinedSub,
        );
      case RepairStatus.inProgress:
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.75,
            end: 1,
          ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.build_outlined,
                    size: 16,
                    color: Color(_kPrimary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          OrderTimelineConstants.repairInProgressTitle,
                          style: AppTextStyles.cardValue.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${OrderTimelineConstants.repairGaragePrefix}${j.garageNameCustom ?? OrderTimelineConstants.partnerGarage}',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(_kTextSecondary),
                          ),
                        ),
                        if (j.estimatedCompletion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${OrderTimelineConstants.repairEstCompletion}${DateFormatter.formatDate(j.estimatedCompletion)}',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(_kTextSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              _photoRow(j.beforePhotoUrlsJson ?? const []),
            ],
          ),
        );
      case RepairStatus.completed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(_kSuccess),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    OrderTimelineConstants.repairCompleteTitle,
                    style: AppTextStyles.cardValue.copyWith(
                      color: const Color(_kSuccess),
                    ),
                  ),
                ),
              ],
            ),
            _photoRow(j.afterPhotoUrlsJson ?? const []),
          ],
        );
    }
  }

  Widget _textBlock(String title, String sub) {
    return Column(
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
    );
  }
}
