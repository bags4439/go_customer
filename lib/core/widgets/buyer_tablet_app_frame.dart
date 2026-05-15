import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import '../layout/app_nav_destinations.dart';
import '../layout/panel_divider.dart';
import '../theme/app_colors.dart';

/// Tablet layout for the buyer dashboard: icon rail + divider + main content.
///
/// Used when the shell shows a rail but not the full web sidebar (see
/// [AppBreakpoints.isWeb] vs tablet width in [BuyerDashboardShell]).
class BuyerTabletAppFrame extends StatelessWidget {
  const BuyerTabletAppFrame({
    super.key,
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
    required this.child,
  });

  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BuyerIconRail(
            selectedIndex: selectedIndex,
            unreadCount: unreadCount,
            onDestinationSelected: onDestinationSelected,
          ),
          const PanelDivider(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BuyerIconRail extends StatelessWidget {
  const _BuyerIconRail({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppBreakpoints.iconRailWidth,
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car_filled,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...AppNavDestinations.items.asMap().entries.map((entry) {
            final i = entry.key;
            final dest = entry.value;
            final isSelected = i == selectedIndex;
            final badge = i == 1 ? unreadCount : 0;
            return _BuyerIconRailItem(
              icon: isSelected ? dest.activeIcon : dest.icon,
              label: dest.label,
              isSelected: isSelected,
              badgeCount: badge,
              onTap: () => onDestinationSelected(i),
            );
          }),
        ],
      ),
    );
  }
}

class _BuyerIconRailItem extends StatelessWidget {
  const _BuyerIconRailItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: isSelected ? AppColors.infoBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textTertiary,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
