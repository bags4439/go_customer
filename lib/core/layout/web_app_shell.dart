import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../widgets/buyer_web_app_frame.dart';
import '../widgets/buyer_web_sidebar.dart';
import 'app_breakpoints.dart';
import 'app_nav_destinations.dart';

/// Wraps screens outside [StatefulShellRoute] with the same web chrome as the
/// main buyer shell.
///
/// On non-web: renders [child] only (no sidebar).
/// On web: [BuyerWebAppFrame] + [BuyerWebSidebar] + [child] as the main column.
class WebAppShell extends ConsumerWidget {
  const WebAppShell({super.key, required this.child, this.activeRoute});

  /// The screen content to wrap.
  final Widget child;

  /// Optional route path to highlight in the sidebar (must match
  /// [AppNavDestinations.items] `.route` values, e.g. `/home`).
  final String? activeRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppBreakpoints.isWeb(context)) {
      return child;
    }

    final unread = ref.watch(unreadNotificationCountProvider);
    final selectedIndex = AppNavDestinations.indexForShellRoute(activeRoute);

    return BuyerWebAppFrame(
      sidebarBuilder: (frameWidth) => BuyerWebSidebar(
        frameWidth: frameWidth,
        selectedIndex: selectedIndex,
        unreadCount: unread,
        onDestinationSelected: (i) {
          context.go(AppNavDestinations.items[i].route);
        },
      ),
      content: child,
    );
  }
}
