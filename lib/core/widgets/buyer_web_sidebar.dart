import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../layout/app_nav_destinations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'buyer_web_sidebar_nav_item.dart';

/// Full-width buyer web sidebar: brand, shell destinations, optional user strip.
///
/// Selection is by branch index (`0`…`items.length - 1`). Use `-1` when nothing
/// should appear selected (e.g. standalone route under [WebAppShell]).
class BuyerWebSidebar extends ConsumerWidget {
  const BuyerWebSidebar({
    super.key,
    required this.frameWidth,
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  /// Width of the clipped frame (used for responsive nav padding).
  final double frameWidth;

  /// Shell branch index, or `-1` for no selection.
  final int selectedIndex;

  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    final navPad = (10 * (frameWidth / 1200)).clamp(8.0, 14.0);

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BuyerWebBrandHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(navPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < AppNavDestinations.items.length; i++)
                    BuyerWebSidebarNavItem(
                      label: AppNavDestinations.items[i].label,
                      icon: i == selectedIndex
                          ? AppNavDestinations.items[i].activeIcon
                          : AppNavDestinations.items[i].icon,
                      isSelected: i == selectedIndex,
                      badgeCount: i == 1 ? unreadCount : 0,
                      onTap: () => onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
          if (user != null) _BuyerWebSidebarUserFooter(user: user),
        ],
      ),
    );
  }
}

class _BuyerWebBrandHeader extends StatelessWidget {
  const _BuyerWebBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'AutoImport', style: AppTextStyles.titleSmall),
                TextSpan(
                  text: ' GH',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyerWebSidebarUserFooter extends StatelessWidget {
  const _BuyerWebSidebarUserFooter({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.infoBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.split(' ').first,
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user.country} · ${user.preferredCurrency}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
