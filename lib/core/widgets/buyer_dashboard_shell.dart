import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_layout.dart';

class BuyerDashboardShell extends ConsumerWidget {
  const BuyerDashboardShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const List<String> _labels = [
    'Home',
    'Notifications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(unreadNotificationCountProvider);
    final useRail =
        !ResponsiveLayout.isMobile(context);
    final extendedRail =
        ResponsiveLayout.isWeb(context);
    final index = navigationShell.currentIndex;

    Widget shellChild = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (index != 0) {
          navigationShell.goBranch(0);
        } else if (!kIsWeb &&
            defaultTargetPlatform ==
                TargetPlatform.android) {
          SystemNavigator.pop();
        }
      },
      child: useRail
          ? _TabletWebLayout(
              extendedRail: extendedRail,
              selectedIndex: index,
              unreadCount: unread,
              onDestinationSelected: (i) =>
                  _onBranchSelected(
                      navigationShell, i),
              child: navigationShell,
            )
          : Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              body: navigationShell,
              bottomNavigationBar:
                  _FloatingNavBar(
                selectedIndex: index,
                unreadCount: unread,
                onDestinationSelected: (i) =>
                    _onBranchSelected(
                        navigationShell, i),
              ),
            ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        navigationRailTheme:
            NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: const IconThemeData(
            color: AppColors.secondary,
            size: 24,
          ),
          unselectedIconTheme:
              const IconThemeData(
            color: AppColors.textTertiary,
            size: 24,
          ),
          selectedLabelTextStyle:
              GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
          unselectedLabelTextStyle:
              GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
          indicatorColor: AppColors.secondary
              .withValues(alpha: 0.12),
          useIndicator: true,
        ),
      ),
      child: shellChild,
    );
  }

  void _onBranchSelected(
    StatefulNavigationShell shell,
    int i,
  ) {
    shell.goBranch(
        i, initialLocation: i == shell.currentIndex);
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
    final bottomInset =
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        bottomInset > 0
            ? bottomInset + 8
            : 16,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.04),
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
                badgeCount: i == 1
                    ? unreadCount
                    : 0,
                onTap: () =>
                    onDestinationSelected(i),
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
            duration: const Duration(
                milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconWithBadge(
                  icon: isSelected
                      ? item.activeIcon
                      : item.icon,
                  isSelected: isSelected,
                  badgeCount: badgeCount,
                ),
                AnimatedSize(
                  duration: const Duration(
                      milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: isSelected
                      ? Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const SizedBox(
                                width: 6),
                            Text(
                              item.label,
                              style: GoogleFonts
                                  .dmSans(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox
                          .shrink(),
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
      color: isSelected
          ? Colors.white
          : AppColors.textTertiary,
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
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            padding: const EdgeInsets
                .symmetric(
              horizontal: 4,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : AppColors.danger,
              borderRadius:
                  BorderRadius.circular(8),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
            ),
            child: Text(
              badgeCount > 99
                  ? '99+'
                  : '$badgeCount',
              style: GoogleFonts.dmSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.secondary
                    : Colors.white,
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

class _TabletWebLayout extends StatelessWidget {
  const _TabletWebLayout({
    required this.extendedRail,
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
    required this.child,
  });

  final bool extendedRail;
  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            NavigationRail(
              extended: extendedRail,
              selectedIndex: selectedIndex,
              onDestinationSelected:
                  onDestinationSelected,
              minWidth: extendedRail ? 88 : 72,
              minExtendedWidth: 220,
              leading: _RailBranding(
                  extended: extendedRail),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(
                      Icons.home_outlined),
                  selectedIcon: const Icon(
                      Icons.home_rounded),
                  label: Text(
                    BuyerDashboardShell
                        ._labels[0],
                  ),
                ),
                NavigationRailDestination(
                  icon: _RailNotificationIcon(
                    outlined: true,
                    unreadCount: unreadCount,
                  ),
                  selectedIcon:
                      _RailNotificationIcon(
                    outlined: false,
                    unreadCount: unreadCount,
                  ),
                  label: Text(
                    BuyerDashboardShell
                        ._labels[1],
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(
                    Icons.person_outline_rounded,
                  ),
                  selectedIcon: const Icon(
                      Icons.person_rounded),
                  label: Text(
                    BuyerDashboardShell
                        ._labels[2],
                  ),
                ),
              ],
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.borderSolid,
            ),
            Expanded(
              child: Padding(
                padding:
                  const EdgeInsets.fromLTRB(
                    12, 12, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                      BorderRadius.circular(
                          12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                          .withValues(
                              alpha: 0.06),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                          12),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailBranding extends StatelessWidget {
  const _RailBranding({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
              8, 0, 8, 16),
      child: extended
          ? Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary
                      .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AI',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight:
                        FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'AutoImport',
                        style:
                            GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight:
                            FontWeight.w600,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                      Text(
                        'GH',
                        style:
                            GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight:
                            FontWeight.w500,
                          color: AppColors
                              .textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary
                      .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AI',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RailNotificationIcon
    extends StatelessWidget {
  const _RailNotificationIcon({
    required this.outlined,
    required this.unreadCount,
  });

  final bool outlined;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      outlined
          ? Icons.notifications_outlined
          : Icons.notifications_rounded,
    );
    if (unreadCount <= 0) return icon;
    return Badge(
      label: Text(
        unreadCount > 99
            ? '99+'
            : '$unreadCount',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: icon,
    );
  }
}
