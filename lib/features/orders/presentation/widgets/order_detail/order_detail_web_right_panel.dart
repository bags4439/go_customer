import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/providers/order_detail_providers.dart';
import 'order_detail_web_agent_card.dart';
import 'order_detail_web_doc_panel.dart';
import 'order_detail_web_order_summary.dart';
import 'order_detail_web_quick_actions.dart';
import 'order_detail_web_step_detail.dart';

class OrderDetailWebRightPanel extends ConsumerWidget {
  const OrderDetailWebRightPanel({
    required this.orderId,
    required this.order,
    required this.currentTab,
  });

  final String orderId;
  final OrderView? order;
  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStep = ref.watch(webSelectedStepProvider);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 34),
      child: SingleChildScrollView(
        child: currentTab == 0
            ? _buildOverviewRight(context, ref, selectedStep)
            : currentTab == 1
            ? _buildChatRight()
            : _buildDocumentsRight(context),
      ),
    );
  }

  Widget _buildOverviewRight(
    BuildContext context,
    WidgetRef ref,
    String? selectedStep,
  ) {
    if (selectedStep != null) {
      return OrderDetailWebStepDetail(
        orderId: orderId,
        order: order,
        stageKey: selectedStep,
        onBack: () => ref.read(webSelectedStepProvider.notifier).state = null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(
          child: OrderDetailWebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: OrderDetailWebOrderSummaryCard(order: order)),
        OrderDetailWebQuickActionsCard(
          orderId: orderId,
          onPaymentTap: () =>
              ref.read(webSelectedStepProvider.notifier).state = 'deposit_paid',
        ),
      ],
    );
  }

  Widget _buildChatRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(
          child: OrderDetailWebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: false,
            expandedAvatar: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: OrderDetailWebOrderContextCard(order: order)),
      ],
    );
  }

  Widget _buildDocumentsRight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(child: OrderDetailWebDocProgressCard(orderId: orderId)),
        SizedBox(height: 16),
        CardContainer(
          child: OrderDetailWebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: OrderDetailWebDocHelpCard(orderId: orderId)),
      ],
    );
  }
}
