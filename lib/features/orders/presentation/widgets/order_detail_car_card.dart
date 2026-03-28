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

  const OrderDetailCarCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.infoText],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.make ?? 'Vehicle'} ${order.model ?? ''}'.trim(),
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  order.orderRef,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (order.purchaseOrigin != 'any')
                      OrderDetailPill(
                        label: orderDetailOriginLabel(order.purchaseOrigin),
                        bg: orderDetailOriginBg(order.purchaseOrigin),
                        textColor: orderDetailOriginText(order.purchaseOrigin),
                      ),
                    if (order.trim != null &&
                        order.trim!.isNotEmpty &&
                        order.trim != 'Other')
                      OrderDetailPill(
                        label: order.trim!,
                        bg: AppColors.surface,
                        textColor: AppColors.textSecondary,
                      ),
                    if (order.isNewVehicle)
                      OrderDetailPill(
                        label: 'New vehicle',
                        bg: AppColors.successMutedBackground,
                        textColor: AppColors.successMutedForeground,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
