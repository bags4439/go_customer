import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_banner.dart';

/// Maps Firestore notification [type] values to banner styling.
AppTopBannerAppearance notificationBannerAppearance(String? type) {
  switch (type) {
    case 'agent_assigned':
      return const AppTopBannerAppearance(
        icon: Icons.person_rounded,
        accent: AppColors.secondary,
        accentBg: AppColors.selectionTint,
      );
    case 'bid_won':
      return const AppTopBannerAppearance(
        icon: Icons.emoji_events_rounded,
        accent: AppColors.success,
        accentBg: AppColors.successMutedBackground,
      );
    case 'bid_lost':
      return const AppTopBannerAppearance(
        icon: Icons.info_rounded,
        accent: AppColors.warning,
        accentBg: AppColors.amberBackground,
      );
    case 'arrival':
      return const AppTopBannerAppearance(
        icon: Icons.anchor_rounded,
        accent: AppColors.secondary,
        accentBg: AppColors.selectionTint,
      );
    case 'repair_quote':
      return const AppTopBannerAppearance(
        icon: Icons.build_rounded,
        accent: AppColors.warning,
        accentBg: AppColors.amberBackground,
      );
    case 'quote_approved':
      return const AppTopBannerAppearance(
        icon: Icons.build_rounded,
        accent: AppColors.success,
        accentBg: AppColors.successMutedBackground,
      );
    case 'payment_request':
      return const AppTopBannerAppearance(
        icon: Icons.credit_card_rounded,
        accent: AppColors.danger,
        accentBg: AppColors.dangerMutedBackground,
      );
    case 'payment_confirmed':
      return const AppTopBannerAppearance(
        icon: Icons.check_circle_rounded,
        accent: AppColors.success,
        accentBg: AppColors.successMutedBackground,
      );
    case 'order_cancelled':
      return const AppTopBannerAppearance(
        icon: Icons.cancel_rounded,
        accent: AppColors.danger,
        accentBg: AppColors.dangerMutedBackground,
      );
    case 'delivery_location_set':
      return const AppTopBannerAppearance(
        icon: Icons.location_on_rounded,
        accent: AppColors.success,
        accentBg: AppColors.successMutedBackground,
      );
    case 'delivery_confirmed':
      return const AppTopBannerAppearance(
        icon: Icons.local_shipping_rounded,
        accent: AppColors.success,
        accentBg: AppColors.successMutedBackground,
      );
    case 'stage_update':
    default:
      return const AppTopBannerAppearance(
        icon: Icons.notifications_rounded,
        accent: AppColors.secondary,
        accentBg: AppColors.selectionTint,
      );
  }
}
