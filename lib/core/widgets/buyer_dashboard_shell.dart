import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../layout/app_breakpoints.dart';
import 'buyer_dashboard_mobile_nav_bar.dart';
import 'buyer_web_app_frame.dart';
import 'buyer_web_sidebar.dart';

class BuyerDashboardShell extends ConsumerWidget {
  const BuyerDashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final useWebShell = AppBreakpoints.useWebShell(context);
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
      child: useWebShell
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
          : Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              body: navigationShell,
              bottomNavigationBar: BuyerDashboardMobileNavBar(
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
