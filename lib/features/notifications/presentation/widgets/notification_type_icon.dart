import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Circular type icon for notification list and detail panels.
class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Widget content;

    switch (type) {
      case 'payment_request':
      case 'payment_confirmed':
        bgColor = const Color(0xFFE6F1FB);
        content = Text(
          'GHS',
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF185FA5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            height: 1.0,
          ),
        );
      case 'bid_won':
        bgColor = const Color(0xFFEAF3DE);
        content = const Text('🎉', style: TextStyle(fontSize: 15));
      case 'bid_lost':
        bgColor = AppColors.surface;
        content = const Text('😔', style: TextStyle(fontSize: 15));
      case 'shipping_update':
      case 'arrival':
        bgColor = const Color(0xFFE1F5EE);
        content = const Text('🚢', style: TextStyle(fontSize: 15));
      case 'message':
        bgColor = AppColors.surface;
        content = Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        );
      case 'agent_assigned':
        bgColor = const Color(0xFFE6F1FB);
        content = const Icon(
          Icons.person_outline,
          size: 16,
          color: Color(0xFF185FA5),
        );
      case 'vehicle_listing':
        bgColor = const Color(0xFFFAEEDA);
        content = const Icon(
          Icons.directions_car_outlined,
          size: 16,
          color: Color(0xFF633806),
        );
      case 'order_edited':
      case 'order_cancelled':
        bgColor = const Color(0xFFFAEEDA);
        content = const Icon(
          Icons.edit_outlined,
          size: 16,
          color: Color(0xFF633806),
        );
      case 'inactivity_reminder':
      case 'auction_deadline':
        bgColor = const Color(0xFFFAEEDA);
        content = Text(
          '!',
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 13,
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        );
      case 'id_reminder':
      case 'system':
      default:
        bgColor = AppColors.surface;
        content = Icon(
          Icons.info_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: content,
    );
  }
}
