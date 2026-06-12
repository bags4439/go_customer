import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_agent_notes_section.dart';
import 'shipping_formatters.dart';
import 'shipping_hero_banner.dart';
import 'shipping_route_visual.dart';
import 'shipping_section_label.dart';
import 'shipping_stages_timeline.dart';
import 'shipping_vessel_details_card.dart';

class ShippingArrivedState extends ConsumerWidget {
  const ShippingArrivedState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = shipping.actualArrival;
    final est = shipping.estimatedArrival;
    var scheduleText = '';
    if (actual != null && est != null) {
      final diff = est.difference(actual).inDays;
      if (diff > 0) {
        scheduleText = '$diff day${diff == 1 ? '' : 's'} ahead of schedule';
      } else if (diff < 0) {
        scheduleText = '${-diff} day${-diff == 1 ? '' : 's'} behind schedule';
      } else {
        scheduleText = 'Arrived on schedule';
      }
    }

    return SingleChildScrollView(
      key: ValueKey('arrived_$orderId'),
      padding: DashboardLayout.flowOuterPaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShippingHeroBanner(
            emoji: '⚓',
            title: 'Your car has arrived at Tema port!',
            subtitle: actual != null
                ? 'Arrived ${shippingDisplayDateFormat.format(actual)}'
                    '${scheduleText.isNotEmpty ? ' · $scheduleText' : ''}'
                : 'Your vehicle is at Tema port.',
            color: AppColors.success,
            bgColor: AppColors.successMutedBackground,
            textColor: AppColors.successMutedForeground,
          ),
          const SizedBox(height: 20),
          const ShippingSectionLabel('ROUTE — COMPLETED'),
          const SizedBox(height: 8),
          ShippingRouteVisual(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          const SizedBox(height: 20),
          ShippingVesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          ShippingStagesTimeline(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          ShippingAgentNotesSection(shipping: shipping),
        ],
      ),
    );
  }
}
