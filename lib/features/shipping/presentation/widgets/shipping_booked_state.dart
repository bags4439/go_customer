import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_agent_notes_section.dart';
import 'shipping_hero_banner.dart';
import 'shipping_stages_timeline.dart';
import 'shipping_vessel_details_card.dart';

class ShippingBookedState extends ConsumerWidget {
  const ShippingBookedState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      key: ValueKey('booked_$orderId'),
      padding: DashboardLayout.flowOuterPaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShippingHeroBanner(
            emoji: '🚢',
            title: 'Your car is being prepared for shipping',
            subtitle:
                'Your agent has booked ocean freight. Departure details will follow.',
            color: AppColors.secondary,
            bgColor: AppColors.infoBackground,
            textColor: AppColors.infoText,
          ),
          const SizedBox(height: 20),
          ShippingVesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          ShippingStagesTimeline(
            shipping: shipping,
            progress: 0,
            isArrived: false,
          ),
          ShippingAgentNotesSection(shipping: shipping),
        ],
      ),
    );
  }
}
