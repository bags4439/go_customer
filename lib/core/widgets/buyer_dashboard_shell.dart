import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../utils/responsive_layout.dart';

const Color _kPrimary = Color(0xFF378ADD);
const Color _kBgSecondary = Color(0xFFF5F4F0);
const Color _kBorder = Color(0xFFE0DFD8);
const Color _kTextTertiary = Color(0xFFAAAAAA);

/// Shell for Home / Notifications / Profile: bottom [NavigationBar] on mobile,
/// [NavigationRail] + inset content cell on tablet and web.
class BuyerDashboardShell extends ConsumerWidget {
  const BuyerDashboardShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const List<String> _labels = ['Home', 'Notifications', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final useRail = !ResponsiveLayout.isMobile(context);
    final extendedRail = ResponsiveLayout.isWeb(context);
    final index = navigationShell.currentIndex;

    Widget shellChild = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (index != 0) {
          navigationShell.goBranch(0);
        } else if (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android) {
          SystemNavigator.pop();
        }
      },
      child: useRail
          ? _TabletWebLayout(
              extendedRail: extendedRail,
              selectedIndex: index,
              unreadCount: unread,
              onDestinationSelected: (i) => _onBranchSelected(navigationShell, i),
              child: navigationShell,
            )
          : Scaffold(
              backgroundColor: Colors.white,
              body: navigationShell,
              bottomNavigationBar: _MobileNavigationBar(
                selectedIndex: index,
                unreadCount: unread,
                onDestinationSelected: (i) => _onBranchSelected(navigationShell, i),
              ),
            ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: _kPrimary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? _kPrimary : _kTextTertiary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? _kPrimary : _kTextTertiary,
              size: 24,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: const IconThemeData(color: _kPrimary, size: 24),
          unselectedIconTheme: const IconThemeData(color: _kTextTertiary, size: 24),
          selectedLabelTextStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kPrimary,
          ),
          unselectedLabelTextStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kTextTertiary,
          ),
          indicatorColor: _kPrimary.withValues(alpha: 0.12),
          useIndicator: true,
        ),
      ),
      child: shellChild,
    );
  }

  void _onBranchSelected(StatefulNavigationShell shell, int i) {
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }
}

class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: 72,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: BuyerDashboardShell._labels[0],
        ),
        NavigationDestination(
          icon: _NotificationNavIcon(
            outlined: true,
            unreadCount: unreadCount,
          ),
          selectedIcon: _NotificationNavIcon(
            outlined: false,
            unreadCount: unreadCount,
          ),
          label: BuyerDashboardShell._labels[1],
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: BuyerDashboardShell._labels[2],
        ),
      ],
    );
  }
}

class _NotificationNavIcon extends StatelessWidget {
  const _NotificationNavIcon({
    required this.outlined,
    required this.unreadCount,
  });

  final bool outlined;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      outlined ? Icons.notifications_outlined : Icons.notifications_rounded,
    );
    if (unreadCount <= 0) return icon;
    return Badge(
      label: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      child: icon,
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
      backgroundColor: _kBgSecondary,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationRail(
              extended: extendedRail,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              minWidth: extendedRail ? 88 : 72,
              minExtendedWidth: 220,
              leading: _RailBranding(extended: extendedRail),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: Text(BuyerDashboardShell._labels[0]),
                ),
                NavigationRailDestination(
                  icon: _RailNotificationIcon(
                    outlined: true,
                    unreadCount: unreadCount,
                  ),
                  selectedIcon: _RailNotificationIcon(
                    outlined: false,
                    unreadCount: unreadCount,
                  ),
                  label: Text(BuyerDashboardShell._labels[1]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: Text(BuyerDashboardShell._labels[2]),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: _kBorder),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: extended
          ? Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AI',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AutoImport',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'GH',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _kTextTertiary,
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
                    color: _kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AI',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RailNotificationIcon extends StatelessWidget {
  const _RailNotificationIcon({
    required this.outlined,
    required this.unreadCount,
  });

  final bool outlined;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      outlined ? Icons.notifications_outlined : Icons.notifications_rounded,
    );
    if (unreadCount <= 0) return icon;
    return Badge(
      label: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      child: icon,
    );
  }
}
