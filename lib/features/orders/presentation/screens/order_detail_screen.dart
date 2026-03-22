import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../core/constants/order_edit_constants.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../providers/order_providers.dart';
import '../widgets/order_timeline_widget.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../chat/presentation/screens/order_chat_tab.dart';
import '../../../documents/presentation/screens/order_documents_tab.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String initialTab;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialTab = 'overview',
  });

  int get _initialIndex {
    switch (initialTab) {
      case 'chat':
        return 1;
      case 'documents':
        return 2;
      default:
        return 0;
    }
  }

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget._initialIndex,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      markChatAsRead(ref, widget.orderId);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final unreadAsync = ref.watch(unreadFromAgentCountProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: orderAsync.maybeWhen(
          data: (order) {
            if (order == null) return Text('Order ${widget.orderId}');
            final title =
                '${order.orderRef} · ${order.make ?? ''} ${order.model ?? ''}';
            return Text(title.trim());
          },
          orElse: () => Text('Order ${widget.orderId}'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Overview'),
            Tab(
              child: unreadAsync.when(
                data: (count) {
                  if (count <= 0) {
                    return const Text('Chat');
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Chat'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE24B4A),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Text('Chat'),
                error: (_, __) => const Text('Chat'),
              ),
            ),
            const Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderOverviewTab(orderId: widget.orderId),
          OrderChatTab(orderId: widget.orderId),
          OrderDocumentsTab(orderId: widget.orderId),
        ],
      ),
    );
  }
}

String _formatGhs(double value) {
  return 'GHS ${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';
}

String? _formatDeadline(DateTime deadlineAt) {
  final now = DateTime.now();
  final diff = deadlineAt.difference(now);
  final days = diff.inDays;
  if (days <= 0) return 'Pay today · avoid storage charges';
  if (days == 1) return 'Pay within 1 day · avoid storage charges';
  return 'Pay within $days days · avoid storage charges';
}

class _OrderOverviewTab extends ConsumerWidget {
  final String orderId;

  const _OrderOverviewTab({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final paymentAsync = ref.watch(activePaymentRequestProvider(orderId));
    final router = GoRouter.of(context);

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Payment CTA
            paymentAsync.when(
              data: (p) {
                if (p == null) return const SizedBox.shrink();
                final typeLabel = AppConstants.paymentRequestTypeLabels[p.type] ?? p.type;
                final deadlineStr = p.deadlineAt != null
                    ? _formatDeadline(p.deadlineAt!)
                    : null;
                return Card(
                  color: const Color(0xFF378ADD),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PAYMENT REQUIRED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatGhs(p.totalGhs),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          typeLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (deadlineStr != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            deadlineStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => router
                                .go('/order/${order.id}/payment-request/${p.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF378ADD),
                            ),
                            child: const Text('Pay now →'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            // Car summary
            Card(
              child: ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car_filled),
                ),
                title: Text(
                  '${order.make ?? 'Vehicle'} ${order.model ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(order.orderRef),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              OrderTimelineConstants.journeyTitle,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            OrderTimelineWidget(orderId: orderId, order: order),
            if (ref.watch(canEditOrderProvider(order.id))) ...[
              const SizedBox(height: 16),
              _AnimatedEditCancelSection(orderId: order.id),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Unable to load order')),
    );
  }
}

class _AnimatedEditCancelSection extends StatefulWidget {
  final String orderId;

  const _AnimatedEditCancelSection({required this.orderId});

  @override
  State<_AnimatedEditCancelSection> createState() =>
      _AnimatedEditCancelSectionState();
}

class _AnimatedEditCancelSectionState extends State<_AnimatedEditCancelSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => context
                          .push('/order/${widget.orderId}/preferences/edit'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF378ADD)),
                        foregroundColor: const Color(0xFF378ADD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(OrderEditConstants.editButtonLabel),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/order/${widget.orderId}/cancel'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE24B4A)),
                        foregroundColor: const Color(0xFFE24B4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(OrderEditConstants.cancelButtonLabel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                border: const Border(
                    left: BorderSide(color: Color(0xFFBA7517), width: 3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFBA7517)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      OrderEditConstants.afterFirstPaymentNote,
                      style: TextStyle(fontSize: 11, color: Color(0xFF633806)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


