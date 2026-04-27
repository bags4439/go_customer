import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/order_providers.dart';
import '../widgets/agent_connection_assigned_view.dart';
import '../widgets/agent_connection_error_view.dart';
import '../widgets/agent_connection_not_found_view.dart';
import '../widgets/agent_connection_searching_view.dart';

class AgentConnectionScreen extends ConsumerStatefulWidget {
  final String orderId;

  const AgentConnectionScreen({
    super.key,
    required this.orderId,
  });

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

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final orderAsync = ref.watch(orderProvider(orderId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => _goHome(context),
          ),
          title: Text(
            'Finding your agent',
            style: AppTextStyles.appBarTitle
                .copyWith(color: AppColors.textPrimary, height: 1.0),
          ),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              height: 0.5,
              color: AppColors.borderSolid,
            ),
          ),
        ),
        body: orderAsync.when(
          data: (order) {
            if (order == null) {
              return const AgentConnectionNotFoundView();
            }
            final createdAt = order.createdAt;
            final olderThanTen = createdAt != null &&
                DateTime.now().difference(createdAt) >
                    const Duration(minutes: 10);
            final showTakingLonger = _takingLonger || olderThanTen;

            if (order.agentId == null) {
              return AgentConnectionSearchingView(
                order: order,
                pulseController: _pulseController,
                showTakingLonger: showTakingLonger,
              );
            }
            return _AssignedBody(
              orderId: orderId,
              agentId: order.agentId!,
              order: order,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
            ),
          ),
          error: (_, __) => AgentConnectionErrorView(
            onRetry: () => ref.invalidate(orderProvider(orderId)),
          ),
        ),
      ),
    );
  }
}

class _AssignedBody extends ConsumerWidget {
  const _AssignedBody({
    required this.orderId,
    required this.agentId,
    required this.order,
  });

  final String orderId;
  final String agentId;
  final OrderView order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));
    return agentAsync.when(
      data: (agent) {
        if (agent == null) {
          return AgentConnectionErrorView(
            message: 'Agent details are temporarily unavailable.',
            onRetry: () => ref.invalidate(agentDetailProvider(agentId)),
          );
        }
        return AgentConnectionAssignedView(
          orderId: orderId,
          order: order,
          agent: agent,
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
        ),
      ),
      error: (_, __) => AgentConnectionErrorView(
        onRetry: () => ref.invalidate(agentDetailProvider(agentId)),
      ),
    );
  }
}
