import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/app_nav_destinations.dart';
import '../theme/app_colors.dart';

/// Floating pill bottom navigation for the buyer dashboard on **mobile** only.
///
/// Branch order and icons follow [AppNavDestinations.items] (same as tablet/web).
class BuyerDashboardMobileNavBar extends StatelessWidget {
  const BuyerDashboardMobileNavBar({
    super.key,
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final items = AppNavDestinations.items;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        bottomInset > 0 ? bottomInset + 8 : 16,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (i) => Expanded(
              child: _MobileNavTile(
                icon: items[i].icon,
                activeIcon: items[i].activeIcon,
                label: items[i].label,
                isSelected: selectedIndex == i,
                badgeCount: i == 1 ? unreadCount : 0,
                onTap: () => onDestinationSelected(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavTile extends StatelessWidget {
  const _MobileNavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MobileNavIconWithBadge(
                  icon: isSelected ? activeIcon : icon,
                  isSelected: isSelected,
                  badgeCount: badgeCount,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavIconWithBadge extends StatelessWidget {
  const _MobileNavIconWithBadge({
    required this.icon,
    required this.isSelected,
    required this.badgeCount,
  });

  final IconData icon;
  final bool isSelected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: isSelected ? Colors.white : AppColors.textTertiary,
    );

    if (badgeCount <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: -5,
          right: -7,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : AppColors.danger,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              badgeCount > 99 ? '99+' : '$badgeCount',
              style: GoogleFonts.dmSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.secondary : Colors.white,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
