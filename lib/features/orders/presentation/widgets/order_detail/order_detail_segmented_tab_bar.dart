import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/chat/presentation/providers/chat_providers.dart';

/// Premium pill-style segmented control for order detail tabs (pinned below AppBar).
class OrderDetailSegmentedTabBar extends ConsumerStatefulWidget {
  final TabController controller;
  final String orderId;

  const OrderDetailSegmentedTabBar({
    super.key,
    required this.controller,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailSegmentedTabBar> createState() =>
      _OrderDetailSegmentedTabBarState();
}

class _OrderDetailSegmentedTabBarState
    extends ConsumerState<OrderDetailSegmentedTabBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerTick);
    widget.controller.animation?.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(OrderDetailSegmentedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      oldWidget.controller.animation?.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
      widget.controller.animation?.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    widget.controller.animation?.removeListener(_onControllerTick);
    super.dispose();
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unreadAsync = ref.watch(unreadFromAgentCountProvider(widget.orderId));
    final unreadCount = unreadAsync.valueOrNull ?? 0;
    final controller = widget.controller;
    final tabCount = controller.length;
    final indexFloat =
        controller.animation?.value ?? controller.index.toDouble();
    final pillIndex = indexFloat.clamp(0.0, (tabCount - 1).toDouble());
    final activeLabelIndex = indexFloat.round().clamp(0, tabCount - 1);

    final tabs = [
      _TabItem(label: 'Overview', index: 0),
      _TabItem(label: 'Chat', index: 1, badgeCount: unreadCount),
      _TabItem(label: 'Documents', index: 2),
    ];

    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / tabs.length;
                  final pillLeft = pillIndex * tabWidth + 3;
                  return Stack(
                    children: [
                      Positioned(
                        left: pillLeft,
                        top: 3,
                        width: tabWidth - 6,
                        height: 38,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: tabs.map((tab) {
                          final isActive = tab.index == activeLabelIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.animateTo(tab.index);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: 44,
                                child: Center(
                                  child: _TabLabel(
                                    label: tab.label,
                                    isActive: isActive,
                                    badgeCount: tab.badgeCount,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(height: 0.5, color: AppColors.borderSolid),
        ],
      ),
    );
  }
}

class _TabItem {
  final String label;
  final int index;
  final int badgeCount;

  const _TabItem({
    required this.label,
    required this.index,
    this.badgeCount = 0,
  });
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final int badgeCount;

  const _TabLabel({
    required this.label,
    required this.isActive,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: isActive
              ? AppTextStyles.labelLarge.copyWith(fontSize: 13)
              : AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
          child: Text(label),
        ),
        if (badgeCount > 0) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeCount > 99 ? '99+' : '$badgeCount',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
