import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import 'app_breakpoints.dart';
import 'app_nav_destinations.dart';
import 'panel_divider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Wraps screens outside the
/// StatefulShellRoute with the
/// same sidebar on web.
///
/// On mobile/tablet: renders
/// [child] only.
/// On web: sidebar (left) +
/// [child] (right, expanded).
class WebAppShell extends ConsumerWidget {
  const WebAppShell({super.key, required this.child, this.activeRoute});

  /// The screen content to wrap.
  final Widget child;

  /// Optional route name to
  /// highlight in the sidebar.
  /// Defaults to none highlighted.
  final String? activeRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppBreakpoints.isWeb(context)) {
      return child;
    }

    final unread = ref.watch(unreadNotificationCountProvider);
    final user = ref.watch(currentUserProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final sw = AppBreakpoints.sidebarWidth(totalWidth);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: sw,
                        child: _WebShellSidebar(
                          activeRoute: activeRoute,
                          unreadCount: unread,
                          user: user,
                        ),
                      ),
                      const PanelDivider(),
                      Expanded(child: child),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sidebar rendered inside
/// WebAppShell. Uses context.go
/// for navigation since there is
/// no StatefulNavigationShell.
class _WebShellSidebar extends StatelessWidget {
  const _WebShellSidebar({
    required this.activeRoute,
    required this.unreadCount,
    required this.user,
  });

  final String? activeRoute;
  final int unreadCount;
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand header
          Container(
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
                      TextSpan(
                        text: 'AutoImport',
                        style: AppTextStyles.titleSmall,
                      ),
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
          ),

          // Nav items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...AppNavDestinations.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final dest = entry.value;
                    final isActive = activeRoute == dest.route;
                    final badge = i == 1 ? unreadCount : 0;
                    return _ShellNavItem(
                      label: dest.label,
                      icon: isActive ? dest.activeIcon : dest.icon,
                      isSelected: isActive,
                      badgeCount: badge,
                      onTap: () => context.go(dest.route),
                    );
                  }),
                ],
              ),
            ),
          ),

          // User footer
          if (user != null)
            Container(
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
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
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
                          '${user.country}'
                          ' · '
                          '${user.preferredCurrency}',
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

/// A single nav item in
/// _WebShellSidebar.
class _ShellNavItem extends StatefulWidget {
  const _ShellNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<_ShellNavItem> createState() => _ShellNavItemState();
}

class _ShellNavItemState extends State<_ShellNavItem> {
  bool _hovered = false;

  Color get _bg {
    if (widget.isSelected) {
      return _hovered ? AppColors.hoverSelected : AppColors.infoBackground;
    }
    return _hovered ? AppColors.hoverSurface : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(9),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      widget.icon,
                      key: ValueKey(widget.isSelected),
                      size: 18,
                      color: widget.isSelected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: widget.isSelected
                            ? AppColors.infoText
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.badgeCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 9,
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
