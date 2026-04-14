import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_view.dart';

String orderDetailOriginLabel(String origin) => switch (origin) {
  'us_canada' => '🇺🇸 US / Canada',
  'dubai' => '🇦🇪 Dubai',
  'china' => '🇨🇳 China',
  _ => origin,
};

Color orderDetailOriginBg(String origin) => switch (origin) {
  'us_canada' => AppColors.selectionTint,
  'dubai' => AppColors.amberBackground,
  'china' => AppColors.successMutedBackground,
  _ => AppColors.surface,
};

Color orderDetailOriginText(String origin) => switch (origin) {
  'us_canada' => AppColors.infoText,
  'dubai' => AppColors.amberText,
  'china' => AppColors.successMutedForeground,
  _ => AppColors.textSecondary,
};

class OrderDetailPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const OrderDetailPill({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class OrderDetailCarCard extends StatelessWidget {
  final OrderView order;

  const OrderDetailCarCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final carName =
        '${order.make ?? 'Vehicle'} ${order.model ?? ''}'.trim();

    final chips = <String>[];
    if (order.purchaseOrigin != 'any') {
      chips.add(
        orderDetailOriginLabel(
          order.purchaseOrigin,
        ),
      );
    }
    if (order.trim != null &&
        order.trim!.isNotEmpty &&
        order.trim != 'Other') {
      chips.add(order.trim!);
    }
    if (order.isNewVehicle) {
      chips.add('New vehicle');
    }

    final subtitle = chips.isNotEmpty ? chips.join(' · ') : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSolid,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary,
                  AppColors.infoText,
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(9),
              ),
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  carName,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.orderRef,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
