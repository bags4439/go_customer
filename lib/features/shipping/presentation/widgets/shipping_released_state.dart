import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_agent_notes_section.dart';
import 'shipping_hero_banner.dart';
import 'shipping_route_visual.dart';
import 'shipping_section_label.dart';
import 'shipping_stages_timeline.dart';
import 'shipping_vessel_details_card.dart';

class ShippingReleasedState extends ConsumerWidget {
  const ShippingReleasedState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      key: ValueKey('released_$orderId'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ShippingHeroBanner(
            emoji: '✅',
            title: 'Your car has been released from port',
            subtitle:
                'Port clearance is complete. Your agent is arranging final delivery.',
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
