import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../core/constants/order_timeline_constants.dart';

/// Inline shipping status card shown inside the active shipping timeline
/// step. Tappable for all statuses — opens the full shipping tracker.
class ShippingStatusCard extends StatelessWidget {
  final ShippingModel shipping;
  final String orderId;

  const ShippingStatusCard({
    super.key,
    required this.shipping,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/order/$orderId/shipping'),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
              child: _buildBody(context),
            ),
            if (shipping.agentNotes != null &&
                shipping.agentNotes!.trim().isNotEmpty)
              _AgentNoteStrip(note: shipping.agentNotes!),
            const _ViewDetailsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (shipping.status) {
      case ShippingStatus.pending:
        return _StatusRow(
          icon: Icons.directions_boat_outlined,
          iconColor: AppColors.secondary,
          title: OrderTimelineConstants.shippingArrangingTitle,
          subtitle: OrderTimelineConstants.shippingArrangingSub,
          titleColor: AppColors.textPrimary,
        );

      case ShippingStatus.booked:
        return _BookedBody(shipping: shipping);

      case ShippingStatus.departed:
      case ShippingStatus.inTransit:
        return _InTransitBody(shipping: shipping);

      case ShippingStatus.arrived:
        return _StatusRow(
          icon: Icons.anchor_rounded,
          iconColor: AppColors.success,
          title: OrderTimelineConstants.shippingArrivedTitle,
          subtitle: shipping.actualArrival != null
              ? 'Arrived ${DateFormatter.formatDate(shipping.actualArrival)}'
              : OrderTimelineConstants.shippingArrivedSub,
          titleColor: AppColors.success,
        );

      case ShippingStatus.released:
        return _StatusRow(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          title: OrderTimelineConstants.shippingReleasedTitle,
          subtitle: OrderTimelineConstants.shippingReleasedSub,
          titleColor: AppColors.success,
        );
    }
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 13,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTextStyles.cardLabel.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookedBody extends StatelessWidget {
  final ShippingModel shipping;
  const _BookedBody({required this.shipping});

  @override
  Widget build(BuildContext context) {
    final hasVessel =
        shipping.vesselName != null && shipping.vesselName!.isNotEmpty;
    final hasEta = shipping.estimatedArrival != null;
    final hasLine =
        shipping.shippingLine != null && shipping.shippingLine!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.directions_boat_outlined,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderTimelineConstants.shippingBookedTitle,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    OrderTimelineConstants.shippingBookedSub,
                    style: AppTextStyles.cardLabel.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (hasVessel || hasEta || hasLine) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSolid, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasVessel)
                  _InfoRow(label: 'Vessel', value: shipping.vesselName!),
                if (hasLine)
                  _InfoRow(label: 'Line', value: shipping.shippingLine!),
                if (hasEta)
                  _InfoRow(
                    label: 'ETA Tema',
                    value: DateFormatter.formatDate(shipping.estimatedArrival),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InTransitBody extends StatelessWidget {
  final ShippingModel shipping;
  const _InTransitBody({required this.shipping});

  @override
  Widget build(BuildContext context) {
    final hasProg = shipping.journeyProgressPct != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shipping.vesselName != null && shipping.vesselName!.isNotEmpty)
          Text(
            shipping.vesselName!,
            style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
          ),
        if (shipping.vesselName != null && shipping.vesselName!.isNotEmpty)
          const SizedBox(height: 4),
        Text(
          '${shipping.originPort ?? '—'} → ${shipping.destinationPort}',
          style: AppTextStyles.cardLabel,
        ),
        const SizedBox(height: 4),
        Text(
          '${OrderTimelineConstants.shippingEtaPrefix}'
          '${DateFormatter.formatDate(shipping.estimatedArrival)}',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (hasProg) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (shipping.journeyProgressPct!.clamp(0, 100)) / 100,
              minHeight: 5,
              backgroundColor: AppColors.borderSolid,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              OrderTimelineConstants.shippingProgressComplete.replaceAll(
                '[n]',
                '${shipping.journeyProgressPct!.round()}',
              ),
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ),
        ],
        if (shipping.trackingUrl != null &&
            shipping.trackingUrl!.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final uri = Uri.parse(shipping.trackingUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary, width: 1),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                OrderTimelineConstants.trackShipment,
                style: AppTextStyles.labelMedium,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AgentNoteStrip extends StatelessWidget {
  final String note;
  const _AgentNoteStrip({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
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

class _ViewDetailsRow extends StatelessWidget {
  const _ViewDetailsRow();

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
            OrderTimelineConstants.shippingViewDetails,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text(label, style: AppTextStyles.caption)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
