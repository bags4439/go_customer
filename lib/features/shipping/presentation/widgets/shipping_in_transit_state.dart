import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/shipping.dart';
import '../providers/shipping_providers.dart';
import 'shipping_agent_notes_section.dart';
import 'shipping_formatters.dart';
import 'shipping_hero_banner.dart';
import 'shipping_route_visual.dart';
import 'shipping_section_label.dart';
import 'shipping_stages_timeline.dart';
import 'shipping_vessel_details_card.dart';

class ShippingInTransitState extends ConsumerWidget {
  const ShippingInTransitState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(journeyProgressProvider(orderId));
    final eta = shipping.estimatedArrival;
    final daysLeft = eta != null
        ? eta.difference(DateTime.now()).inDays.clamp(0, 999)
        : 0;

    return SingleChildScrollView(
      key: ValueKey('intransit_$orderId'),
      padding: DashboardLayout.flowOuterPaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShippingHeroBanner(
            emoji: '🚢',
            title: 'Your car is on its way',
            subtitle: eta != null
                ? 'ETA ${shippingDisplayDateFormat.format(eta)} · $daysLeft day'
                    '${daysLeft == 1 ? '' : 's'} remaining'
                : 'En route to Tema, Ghana',
            color: AppColors.secondary,
            bgColor: AppColors.infoBackground,
            textColor: AppColors.infoText,
          ),
          const SizedBox(height: 20),
          const ShippingSectionLabel('ROUTE'),
          const SizedBox(height: 8),
          ShippingRouteVisual(
            shipping: shipping,
            progress: progress,
            isArrived: false,
          ),
          const SizedBox(height: 20),
          ShippingVesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          ShippingStagesTimeline(
            shipping: shipping,
            progress: progress,
            isArrived: false,
          ),
          ShippingAgentNotesSection(shipping: shipping),
        ],
      ),
    );
  }
}
