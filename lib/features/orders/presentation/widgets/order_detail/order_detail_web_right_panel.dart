import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/models/web_order_panel_task.dart';
import 'package:go_customer/features/orders/presentation/providers/order_detail_providers.dart';
import 'order_detail_web_navigation.dart';
import 'order_detail_web_agent_card.dart';
import 'order_detail_web_doc_panel.dart';
import 'order_detail_web_order_summary.dart';
import 'order_detail_web_panel_content.dart';
import 'order_detail_web_quick_actions.dart';

/// Right contextual column on web order detail (default cards or embedded task).
class OrderDetailWebRightPanel extends ConsumerWidget {
  const OrderDetailWebRightPanel({
    super.key,
    required this.orderId,
    required this.order,
    required this.currentTab,
  });

  final String orderId;
  final OrderView? order;
  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(webOrderPanelTaskProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: switch (currentTab) {
        0 => _OverviewColumn(
          orderId: orderId,
          order: order,
          task: task,
        ),
        1 => _ChatColumn(orderId: orderId, order: order),
        2 => _DocumentsColumn(orderId: orderId, order: order),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _OverviewColumn extends ConsumerWidget {
  const _OverviewColumn({
    required this.orderId,
    required this.order,
    required this.task,
  });

  final String orderId;
  final OrderView? order;
  final WebOrderPanelTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task is! WebOrderPanelDefault) {
      return OrderDetailWebPanelContent(
        orderId: orderId,
        order: order,
        task: task,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          CardContainer(
            child: OrderDetailWebAgentCard(
              orderId: orderId,
              order: order,
              showChatButton: true,
            ),
          ),
          const SizedBox(height: 16),
          CardContainer(child: OrderDetailWebOrderSummaryCard(order: order)),
          OrderDetailWebQuickActionsCard(
            orderId: orderId,
            onPaymentTap: (requestId) {
              if (requestId != null) {
                OrderDetailWebNavigation.openPaymentRequest(
                  context,
                  ref,
                  orderId: orderId,
                  requestId: requestId,
                );
              } else {
                OrderDetailWebNavigation.openTimelineStep(ref, 'deposit_paid');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ChatColumn extends StatelessWidget {
  const _ChatColumn({required this.orderId, required this.order});

  final String orderId;
  final OrderView? order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          CardContainer(
            child: OrderDetailWebAgentCard(
              orderId: orderId,
              order: order,
              showChatButton: false,
              expandedAvatar: true,
            ),
          ),
          const SizedBox(height: 16),
          CardContainer(child: OrderDetailWebOrderContextCard(order: order)),
        ],
      ),
    );
  }
}

class _DocumentsColumn extends StatelessWidget {
  const _DocumentsColumn({required this.orderId, required this.order});

  final String orderId;
  final OrderView? order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          CardContainer(child: OrderDetailWebDocProgressCard(orderId: orderId)),
          const SizedBox(height: 16),
          CardContainer(
            child: OrderDetailWebAgentCard(
              orderId: orderId,
              order: order,
              showChatButton: true,
            ),
          ),
          const SizedBox(height: 16),
          CardContainer(child: OrderDetailWebDocHelpCard(orderId: orderId)),
        ],
      ),
    );
  }
}
