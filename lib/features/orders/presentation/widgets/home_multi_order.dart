part of '../screens/home_screen.dart';

class _MultiOrderHome extends ConsumerStatefulWidget {
  final List<OrderView> orders;
  final int pendingPayments;
  final String? currentUserName;

  const _MultiOrderHome({
    required this.orders,
    required this.pendingPayments,
    required this.currentUserName,
  });

  @override
  ConsumerState<_MultiOrderHome> createState() => _MultiOrderHomeState();
}

class _MultiOrderHomeState extends ConsumerState<_MultiOrderHome>
    with CoachMarkMixin<_MultiOrderHome> {
  final _firstOrderCardKey = GlobalKey();

  @override
  String get coachMarkKey => GuideKeys.homeOrders;

  String _subtitleText(int active, int needsAction) {
    if (needsAction > 0) {
      return '$active active ${active == 1 ? 'order' : 'orders'} · '
          '$needsAction ${needsAction == 1 ? 'needs' : 'need'} '
          'your attention';
    }
    return '$active active ${active == 1 ? 'order' : 'orders'}';
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.orders.where((o) => !o.isCompleted).length;
    final completed = widget.orders.where((o) => o.isCompleted).length;
    final needsAction =
        widget.orders.where((o) => o.needsPayment).length +
            widget.pendingPayments;

    final sorted = [...widget.orders]
      ..sort((a, b) {
        if (a.needsPayment && !b.needsPayment) return -1;
        if (!a.needsPayment && b.needsPayment) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        return b.stageNumber.compareTo(a.stageNumber);
      });

    final listChildren = <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${widget.currentUserName?.split(' ').first ?? ''} 👋',
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitleText(active, needsAction),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _C.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Active',
                value: '$active',
                valueColor: _C.primary,
                icon: Icons.directions_car_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Action needed',
                value: '$needsAction',
                valueColor: needsAction > 0 ? _C.danger : _C.textTertiary,
                icon: Icons.notifications_outlined,
                pulse: needsAction > 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Completed',
                value: '$completed',
                valueColor: _C.success,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'YOUR ORDERS',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _C.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ...sorted.asMap().entries.map(
              (entry) => _StaggeredItem(
                index: entry.key,
                child: entry.key == 0
                    ? KeyedSubtree(
                        key: _firstOrderCardKey,
                        child: _OrderCard(order: entry.value),
                      )
                    : _OrderCard(order: entry.value),
              ),
            ),
        const SizedBox(height: 8),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => GoRouter.of(context).push('/preferences/new'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.bgPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _C.primary.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _C.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: _C.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import another car',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Start a new import order',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: _C.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const ReferralPromoCard(),
    ];

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: listChildren,
        ),
        if (showCoachMark && sorted.isNotEmpty)
          CoachMarkOverlay(
            guideKey: GuideKeys.homeOrders,
            targetKey: _firstOrderCardKey,
            title: 'Your order at a glance',
            body: 'This card shows your import progress. '
                'Tap it to see every detail of your '
                'journey from search to delivery.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: hideCoachMark,
            onFaqTap: () {
              hideCoachMark();
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );
  }
}
