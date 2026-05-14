part of 'package:go_customer/features/orders/presentation/screens/order_detail_screen.dart';

/// Full web layout for order detail.
/// Left = tab content. Right = contextual (equal width).
class _WebOrderDetailLayout extends ConsumerWidget {
  const _WebOrderDetailLayout({
    required this.orderId,
    required this.tabController,
    required this.onTabChanged,
    required this.buildBody,
  });

  final String orderId;
  final TabController tabController;
  final void Function(int) onTabChanged;
  final Widget Function(BuildContext context, bool showSegmentedTabBar)
  buildBody;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final order = orderAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _WebOrderHeader(
            orderId: orderId,
            order: order,
            tabController: tabController,
            onTabChanged: onTabChanged,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: buildBody(context, false)),
                const PanelDivider(),
                Expanded(
                  child: _WebRightPanel(
                    orderId: orderId,
                    order: order,
                    currentTab: tabController.index,
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

/// 56px header bar for web order detail.
class _WebOrderHeader extends StatelessWidget {
  const _WebOrderHeader({
    required this.orderId,
    required this.order,
    required this.tabController,
    required this.onTabChanged,
  });

  final String orderId;
  final OrderView? order;
  final TabController tabController;
  final void Function(int) onTabChanged;

  @override
  Widget build(BuildContext context) {
    final carName = '${order?.make ?? ''} ${order?.model ?? ''}'.trim();

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: CardContainer(
              paddingType: CardContainerPaddingType.large,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      order?.orderRef ?? '—',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (order?.needsPayment == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amberBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Payment due',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.amberText,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (carName.isNotEmpty)
                  Text(
                    carName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _WebTabSwitcher(
            tabController: tabController,
            orderId: orderId,
            onTabChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}

/// Pill tab switcher matching SegmentedTabBar style.
class _WebTabSwitcher extends ConsumerWidget {
  const _WebTabSwitcher({
    required this.tabController,
    required this.orderId,
    required this.onTabChanged,
  });

  final TabController tabController;
  final String orderId;
  final void Function(int) onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(unreadFromAgentCountProvider(orderId)).valueOrNull ?? 0;

    final labels = [
      'Overview',
      unread > 0 ? 'Chat ($unread)' : 'Chat',
      'Documents',
    ];

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final active = tabController.index;
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(labels.length, (i) {
              final isActive = i == active;
              return GestureDetector(
                onTap: () => onTabChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.background : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isActive
                        ? [
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
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: isActive
                        ? AppTextStyles.labelLarge.copyWith(fontSize: 12)
                        : AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
