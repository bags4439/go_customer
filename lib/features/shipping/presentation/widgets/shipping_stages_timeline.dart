import 'package:flutter/material.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_timeline_item.dart';

class ShippingStagesTimeline extends StatelessWidget {
  const ShippingStagesTimeline({
    super.key,
    required this.shipping,
    required this.progress,
    required this.isArrived,
  });

  final Shipping shipping;
  final double progress;
  final bool isArrived;

  @override
  Widget build(BuildContext context) {
    final status = shipping.status;
    final stage1Done = status != 'pending';
    final stage2Done = shipping.actualDeparture != null;
    final stage3Active = status == 'in_transit';
    final stage4Done = isArrived;
    final stage5Done = shipping.isReleased;
    final stage5Active = isArrived && !shipping.isReleased;

    return CardContainer(
        paddingType: CardContainerPaddingType.xlarge,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping stages', style: AppTextStyles.cardValue),
        const SizedBox(height: 14),
        ShippingTimelineItem(
          label: 'Booked',
          isDone: stage1Done,
          isActive: !stage1Done,
        ),
        ShippingTimelineItem(
          label: 'Departed ${shipping.originPort ?? "port"}',
          detail: shipping.vesselName != null
              ? 'Loaded onto ${shipping.vesselName}'
              : null,
          isDone: stage2Done,
          isActive: stage1Done && !stage2Done,
        ),
        ShippingTimelineItem(
          label: 'In transit',
          detail: '${progress.toStringAsFixed(0)}% of journey complete',
          isDone: isArrived,
          isActive: stage3Active,
        ),
        ShippingTimelineItem(
          label: 'Arrived at Tema port',
          detail: shipping.estimatedArrival != null
              ? DateFormatter.formatDate(shipping.estimatedArrival)
              : null,
          isDone: stage4Done,
          isActive: false,
        ),
        ShippingTimelineItem(
          label: 'Released from port',
          detail: stage5Active
              ? 'Your next step'
              : 'After duty & clearance',
          isDone: stage5Done,
          isActive: stage5Active,
          isLast: true,
        ),
      ],
    ));
  }
}
