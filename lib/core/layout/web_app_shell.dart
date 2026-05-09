import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../features/orders/presentation/providers/order_providers.dart';
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
    final orders = ref.watch(buyerOrdersProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
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
                  orders: orders,
                ),
              ),
              const PanelDivider(),
              Expanded(child: child),
            ],
          );
        },
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
    required this.orders,
  });

  final String? activeRoute;
  final int unreadCount;
  final dynamic user;
  final List<OrderView> orders;

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

          // Nav items (+ scrollable active orders)
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

                  // Active orders list
                  if (orders.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(height: .5, color: AppColors.borderSolid),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        'ACTIVE ORDERS',
                        style: AppTextStyles.sectionLabel.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                    ...orders
                        .where((o) => !o.isCompleted)
                        .take(3)
                        .map(
                          (order) => _OrderSidebarTile(
                            order: order,
                            isActive: GoRouterState.of(
                              context,
                            ).uri.toString().contains(order.id),
                          ),
                        ),
                  ],
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

/// A compact order tile shown
/// in the sidebar orders list.
class _OrderSidebarTile extends StatefulWidget {
  const _OrderSidebarTile({required this.order, required this.isActive});

  final OrderView order;
  final bool isActive;

  @override
  State<_OrderSidebarTile> createState() => _OrderSidebarTileState();
}

class _OrderSidebarTileState extends State<_OrderSidebarTile> {
  bool _hovered = false;

  static const _stageNames = [
    'Preferences',
    'Agent assignment',
    'Deposit & fee',
    'Vehicle search',
    'Balance',
    'Shipping',
    'Clearance',
    'Repairs',
    'Delivery',
  ];

  String get _displayName {
    final make = widget.order.make ?? '';
    final model = widget.order.model ?? '';
    final name = '$make $model'.trim();
    return name.isNotEmpty ? name : widget.order.orderRef;
  }

  String get _stageName {
    final i = widget.order.stageNumber - 1;
    if (i < 0 || i >= _stageNames.length) {
      return 'In progress';
    }
    return _stageNames[i];
  }

  double get _progress => (widget.order.stageNumber / 9).clamp(0.0, 1.0);

  Color get _bg => _hovered ? AppColors.hoverSurface : AppColors.surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                width: widget.isActive ? 3 : 0.5,
                color: widget.isActive
                    ? AppColors.secondary
                    : AppColors.borderSolid,
              ),
              top: BorderSide(color: AppColors.borderSolid, width: 0.5),
              right: BorderSide(color: AppColors.borderSolid, width: 0.5),
              bottom: BorderSide(color: AppColors.borderSolid, width: 0.5),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/order/${widget.order.id}'),
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _displayName,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.infoBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _stageName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.infoText,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.orderRef,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.borderSolid,
                        color: AppColors.secondary,
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
