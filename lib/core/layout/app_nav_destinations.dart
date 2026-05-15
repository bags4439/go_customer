import 'package:flutter/material.dart';

/// Defines every navigation
/// destination in the shell.
///
/// Add, remove, or reorder
/// destinations here — the sidebar,
/// icon rail, and bottom nav all
/// read from this single list.
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  /// Optional badge count.
  /// Provided externally at runtime
  /// — not hardcoded here.
  final int? badgeCount;
}

class AppNavDestinations {
  AppNavDestinations._();

  /// Branch index for [route], or `-1` if it does not match any shell item.
  static int indexForShellRoute(String? route) {
    if (route == null || route.isEmpty) return -1;
    final i = items.indexWhere((d) => d.route == route);
    return i >= 0 ? i : -1;
  }

  /// The ordered list of shell nav
  /// destinations. Order determines
  /// the branch index in GoRouter.
  static const List<AppNavDestination> items = [
    AppNavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: '/home',
    ),
    AppNavDestination(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      route: '/notifications',
    ),
    AppNavDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: '/profile',
    ),
  ];
}
