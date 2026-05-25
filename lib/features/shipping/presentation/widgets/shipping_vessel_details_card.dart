import 'package:flutter/material.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_detail_row.dart';

class ShippingVesselDetailsCard extends StatelessWidget {
  const ShippingVesselDetailsCard({super.key, required this.shipping});

  final Shipping shipping;

  @override
  Widget build(BuildContext context) {
    final hasTracking = shipping.trackingUrl != null &&
        shipping.trackingUrl!.trim().isNotEmpty;

    return CardContainer(
        paddingType: CardContainerPaddingType.xlarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Vessel details',
                  style: AppTextStyles.cardValue.copyWith(letterSpacing: 0.2),
                ),
                const Spacer(),
                if (hasTracking)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(shipping.trackingUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      'Track live →',
                      style: AppTextStyles.cardValue
                          .copyWith(color: AppColors.secondary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ShippingDetailRow('Vessel', shipping.vesselName ?? '—'),
            ShippingDetailRow('Shipping line', shipping.shippingLine ?? '—'),
            ShippingDetailRow('Container', shipping.containerNumber ?? '—'),
            ShippingDetailRow('Bill of lading', shipping.blNumber ?? '—'),
            ShippingDetailRow('Origin port', shipping.originPort ?? '—'),
            ShippingDetailRow(
              'Destination',
              shipping.destinationPort ?? 'Tema, Ghana',
            ),
            if (shipping.estimatedDeparture != null)
              ShippingDetailRow(
                'Est. departure',
                DateFormatter.formatDate(shipping.estimatedDeparture),
              ),
            ShippingDetailRow(
              'Departed',
              DateFormatter.formatDate(shipping.actualDeparture),
            ),
            ShippingDetailRow(
              'ETA Tema',
              DateFormatter.formatDate(shipping.estimatedArrival),
            ),
            if (shipping.actualArrival != null)
              ShippingDetailRow(
                'Arrived',
                DateFormatter.formatDate(shipping.actualArrival),
              ),
          ],
        ));
  }
}
