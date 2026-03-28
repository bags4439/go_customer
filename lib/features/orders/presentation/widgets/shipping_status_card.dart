import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../core/constants/order_timeline_constants.dart';

const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kTextSecondary = 0xFF666666;
const _kTextTertiary = 0xFFAAAAAA;
const _kBorder = 0xFFE0DFD8;
const _kSuccess = 0xFF1D9E75;

/// Shipping step status when a shipping document exists (no pending payment).
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
    final shouldOpenShippingScreen =
        shipping.status == ShippingStatus.departed ||
        shipping.status == ShippingStatus.inTransit;

    return GestureDetector(
      onTap: shouldOpenShippingScreen
          ? () => context.push('/order/$orderId/shipping')
          : null,
      child: Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: shouldOpenShippingScreen
              ? const Color(0x66378ADD)
              : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: _buildByStatus(context),
      ),
    );
  }

  Widget _buildByStatus(BuildContext context) {
    switch (shipping.status) {
      case ShippingStatus.pending:
      case ShippingStatus.booked:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.directions_boat_outlined,
                size: 16, color: Color(_kPrimary)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderTimelineConstants.shippingArrangingTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    OrderTimelineConstants.shippingArrangingSub,
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
      case ShippingStatus.departed:
      case ShippingStatus.inTransit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shipping.vesselName != null &&
                shipping.vesselName!.isNotEmpty) ...[
              Text(
                shipping.vesselName!,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              '${shipping.originPort ?? '—'} → ${shipping.destinationPort}',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(_kTextSecondary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${OrderTimelineConstants.shippingEtaPrefix}${DateFormatter.formatDate(shipping.estimatedArrival)}',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(_kTextSecondary),
              ),
            ),
            if (shipping.journeyProgressPct != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (shipping.journeyProgressPct!.clamp(0, 100)) / 100,
                  minHeight: 4,
                  backgroundColor: const Color(_kBorder),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(_kPrimary)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  OrderTimelineConstants.shippingProgressComplete
                      .replaceAll('[n]', '${shipping.journeyProgressPct!.round()}'),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(_kTextTertiary),
                  ),
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
                    foregroundColor: const Color(_kPrimary),
                    side: const BorderSide(color: Color(_kPrimary)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    OrderTimelineConstants.trackShipment,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Open full shipping tracker',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(_kPrimary),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Color(_kPrimary),
                ),
              ],
            ),
          ],
        );
      case ShippingStatus.arrived:
      case ShippingStatus.released:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.anchor, size: 16, color: Color(_kSuccess)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderTimelineConstants.shippingArrivedTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(_kSuccess),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    OrderTimelineConstants.shippingArrivedSub,
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
}
