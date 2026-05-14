part of 'package:go_customer/features/orders/presentation/screens/order_detail_screen.dart';

/// Step labels aligned with [OrderTimelineConstants.journeyTitle] stages
/// and the 9-step journey used on home order cards.
const List<String> _kOrderTimelineStepNames = [
  'Preferences submission',
  'Agent assignment',
  'Deposit & service fee',
  'Vehicle search',
  'Vehicle balance',
  'Shipping',
  'Duty & clearance',
  'Repairs',
  'Delivery',
];

String _orderVehicleHeadline(OrderView? order) {
  if (order == null) return '--';
  final name = '${order.make ?? ''} ${order.model ?? ''}'.trim();
  return name.isNotEmpty ? name : order.orderRef;
}

String _orderCurrentStageHeadline(OrderView? order) {
  if (order == null) return '--';
  final sn = order.stageNumber.clamp(1, _kOrderTimelineStepNames.length);
  return _kOrderTimelineStepNames[sn - 1];
}

// ignore: unused_element — reserved for non-web timeline rail layouts.
class _OrderTimelinePanel extends ConsumerWidget {
  const _OrderTimelinePanel({
    required this.orderId,
    required this.currentTab,
    required this.onTabSelected,
  });

  final String orderId;
  final int currentTab;
  final void Function(int) onTabSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final order = orderAsync.valueOrNull;

    return Container(
      color: AppColors.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _orderVehicleHeadline(order),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order?.orderRef ?? '--',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (order != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.infoBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${order.stageNumber} of 9',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.infoText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A5FA5), Color(0xFF378ADD)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Import progress',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (ctx, constraints) {
                                final sw = MediaQuery.sizeOf(ctx).width;
                                return Text(
                                  order == null
                                      ? '--'
                                      : '${((order.stageNumber / 9) * 100).round()}%',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: AppBreakpoints.scaledFontSize(
                                      16,
                                      sw,
                                    ),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _orderCurrentStageHeadline(order),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: order == null
                                ? 0
                                : (order.stageNumber.clamp(1, 9) / 9),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'JOURNEY',
                    style: AppTextStyles.sectionLabel.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order != null) _TimelineStepsList(order: order),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Row(
              children: [
                _TimelinePanelTab(
                  label: 'Overview',
                  isSelected: currentTab == 0,
                  onTap: () => onTabSelected(0),
                ),
                _TimelinePanelTab(
                  label: 'Chat',
                  isSelected: currentTab == 1,
                  onTap: () => onTabSelected(1),
                ),
                _TimelinePanelTab(
                  label: 'Documents',
                  isSelected: currentTab == 2,
                  onTap: () => onTabSelected(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanelTab extends StatelessWidget {
  const _TimelinePanelTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineStepsList extends StatelessWidget {
  const _TimelineStepsList({required this.order});

  final OrderView order;

  @override
  Widget build(BuildContext context) {
    final currentStage = order.stageNumber;

    return Column(
      children: List.generate(_kOrderTimelineStepNames.length, (i) {
        final stepNumber = i + 1;
        final isDone = stepNumber < currentStage;
        final isActive = stepNumber == currentStage;
        final isPending = stepNumber > currentStage;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              _StepIndicator(isDone: isDone, isActive: isActive),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _kOrderTimelineStepNames[i],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: isPending
                        ? AppColors.textTertiary
                        : isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.isDone, required this.isActive});

  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 8, color: Colors.white),
      );
    }
    if (isActive) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondary, width: 2),
          color: AppColors.infoBackground,
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSolid, width: 1.5),
      ),
    );
  }
}
