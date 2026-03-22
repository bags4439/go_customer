import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../providers/order_providers.dart';

class AgentConnectionScreen extends ConsumerStatefulWidget {
  final String orderId;

  const AgentConnectionScreen({super.key, required this.orderId});

  @override
  ConsumerState<AgentConnectionScreen> createState() =>
      _AgentConnectionScreenState();
}

class _AgentConnectionScreenState extends ConsumerState<AgentConnectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _takingLonger = false;
  Timer? _longWaitTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _longWaitTimer = Timer(const Duration(minutes: 10), () {
      if (mounted) setState(() => _takingLonger = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _longWaitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Agent connection')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          final createdAt = order.createdAt;
          final olderThanTen = createdAt != null &&
              DateTime.now().difference(createdAt) > const Duration(minutes: 10);
          final showTakingLonger = _takingLonger || olderThanTen;

          if (order.agentId == null) {
            return _SearchingView(
              pulseController: _pulseController,
              showTakingLonger: showTakingLonger,
            );
          }
          return _AssignedView(orderId: widget.orderId, agentId: order.agentId!, order: order);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _SearchingView extends StatelessWidget {
  final AnimationController pulseController;
  final bool showTakingLonger;

  const _SearchingView({
    required this.pulseController,
    required this.showTakingLonger,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 18),
          ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.08).animate(
              CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF378ADD), width: 3),
                color: const Color(0xFFEAF3FF),
              ),
              child: const Icon(Icons.search, size: 48, color: Color(0xFF378ADD)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Finding your agent',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your preferences have been submitted. We are assigning a dedicated agent to your order now.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          const _AssignStepRow(
            done: true,
            active: false,
            text: 'Preferences submitted',
          ),
          const _AssignStepRow(
            done: false,
            active: true,
            text: 'Assigning your agent',
          ),
          const _AssignStepRow(
            done: false,
            active: false,
            text: 'Agent starts searching',
          ),
          const _AssignStepRow(
            done: false,
            active: false,
            text: 'Options sent to you',
          ),
          const SizedBox(height: 16),
          Text(
            showTakingLonger
                ? "Taking longer than expected. We'll notify you."
                : 'Usually takes a few minutes',
            style: const TextStyle(color: Color(0xFF7F7F7F)),
          ),
        ],
      ),
    );
  }
}

class _AssignStepRow extends StatelessWidget {
  final bool done;
  final bool active;
  final String text;
  const _AssignStepRow({
    required this.done,
    required this.active,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = done
        ? const Color(0xFF1D9E75)
        : active
            ? const Color(0xFF378ADD)
            : const Color(0xFFB0B0B0);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : active
                ? const Icon(Icons.circle, size: 9, color: Colors.white)
                : const Icon(Icons.circle, size: 9, color: Colors.white70),
      ),
      title: Text(text),
    );
  }
}

class _AssignedView extends ConsumerWidget {
  final String orderId;
  final String agentId;
  final OrderView order;
  const _AssignedView({
    required this.orderId,
    required this.agentId,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));
    return agentAsync.when(
      data: (agent) {
        if (agent == null) return const Center(child: Text('Agent details unavailable'));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('✓ Agent assigned'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF234A83),
                          child: Text(
                            agent.initials,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent.fullName,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w700)),
                              const Text('Senior Import Agent'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stat('${agent.successRate.toStringAsFixed(0)}%', 'Success rate'),
                        _stat(agent.rating.toStringAsFixed(1), 'Rating'),
                        _stat('${agent.totalOrdersCompleted}', 'Orders done'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F4F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${agent.introMessage}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('What happens next',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('1. Agent searches US auctions for your request'),
                    SizedBox(height: 6),
                    Text('2. You receive options with full cost breakdowns'),
                    SizedBox(height: 6),
                    Text('3. You pick one and confirm a max bid'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  RouteConstants.orderDetail,
                  pathParameters: {'orderId': orderId},
                  queryParameters: {'tab': 'chat'},
                );
              },
              child: Text('Open chat with ${agent.fullName.split(' ').first} →'),
            ),
            const SizedBox(height: 8),
            Text(
              'Push notification body: ${agent.fullName} has been assigned and is already searching for your ${order.make ?? ''} ${order.model ?? ''}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        Text(label),
      ],
    );
  }
}

