import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../layout/app_breakpoints.dart';
import '../theme/app_colors.dart';
import 'buyer_tablet_app_frame.dart';
import 'buyer_web_app_frame.dart';
import 'buyer_web_sidebar.dart';

class BuyerDashboardShell extends ConsumerWidget {
  const BuyerDashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final useRail = !AppBreakpoints.isMobile(context);
    final isWeb = AppBreakpoints.isWeb(context);
    final index = navigationShell.currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (index != 0) {
          navigationShell.goBranch(0);
        } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          SystemNavigator.pop();
        }
      },
      child: useRail
          ? (isWeb
                ? BuyerWebAppFrame(
                    sidebarBuilder: (frameWidth) => BuyerWebSidebar(
                      frameWidth: frameWidth,
                      selectedIndex: index,
                      unreadCount: unread,
                      onDestinationSelected: (i) =>
                          _onBranchSelected(navigationShell, i),
                    ),
                    content: navigationShell,
                  )
                : BuyerTabletAppFrame(
                    selectedIndex: index,
                    unreadCount: unread,
                    onDestinationSelected: (i) =>
                        _onBranchSelected(navigationShell, i),
                    child: navigationShell,
                  ))
          : Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              body: navigationShell,
              bottomNavigationBar: _FloatingNavBar(
                selectedIndex: index,
                unreadCount: unread,
                onDestinationSelected: (i) =>
                    _onBranchSelected(navigationShell, i),
              ),
            ),
    );
  }

  void _onBranchSelected(StatefulNavigationShell shell, int i) {
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
            _items.length,
            (i) => Expanded(
              child: _NavTile(
                item: _items[i],
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final _NavItem item;
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
                _IconWithBadge(
                  icon: isSelected ? item.activeIcon : item.icon,
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
                              item.label,
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

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
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
