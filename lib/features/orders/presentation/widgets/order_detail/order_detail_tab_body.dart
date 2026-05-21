import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/features/chat/presentation/screens/order_chat_tab.dart';
import 'package:go_customer/features/documents/presentation/screens/order_documents_tab.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'order_detail_guide_overlays.dart';
import 'order_detail_overview_tab.dart';
import 'order_detail_segmented_tab_bar.dart';

/// Tab column (segmented bar + TabBarView) with optional web width constraint and guides.
class OrderDetailTabBody extends ConsumerWidget {
  const OrderDetailTabBody({
    super.key,
    required this.orderId,
    required this.tabController,
    required this.showSegmentedTabBar,
    required this.timelineKey,
    required this.paymentCardKey,
    required this.chatTabKey,
    required this.docsTabKey,
    required this.showPaymentCoach,
    required this.guideStep,
    required this.suppressTimelineStageCoaches,
    required this.onPaymentCoachDismissed,
    required this.onGuideStepChanged,
    required this.onSwitchToChat,
  });

  final String orderId;
  final TabController tabController;
  final bool showSegmentedTabBar;
  final GlobalKey timelineKey;
  final GlobalKey paymentCardKey;
  final GlobalKey chatTabKey;
  final GlobalKey docsTabKey;
  final bool showPaymentCoach;
  final int guideStep;
  final bool suppressTimelineStageCoaches;
  final VoidCallback onPaymentCoachDismissed;
  final ValueChanged<int> onGuideStepChanged;
  final VoidCallback onSwitchToChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref
        .watch(activePaymentRequestProvider(orderId))
        .valueOrNull;

    final tabColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSegmentedTabBar)
          OrderDetailSegmentedTabBar(
            controller: tabController,
            orderId: orderId,
            chatTabKey: chatTabKey,
            documentsTabKey: docsTabKey,
          ),
        Expanded(
          child: TabBarView(
            physics: AppBreakpoints.isWeb(context)
                ? const NeverScrollableScrollPhysics()
                : null,
            controller: tabController,
            children: [
              OrderDetailOverviewTab(
                orderId: orderId,
                timelineKey: timelineKey,
                paymentCardKey: paymentCardKey,
                suppressTimelineStageCoaches: suppressTimelineStageCoaches,
                onChatTap: onSwitchToChat,
              ),
              OrderChatTab(orderId: orderId),
              OrderDocumentsTab(orderId: orderId),
            ],
          ),
        ),
      ],
    );

    final content = AppBreakpoints.isWeb(context)
        ? LayoutBuilder(
            builder: (context, constraints) {
              final maxW = AppBreakpoints.contentMaxWidth(constraints.maxWidth);
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: tabColumn,
                ),
              );
            },
          )
        : tabColumn;

    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        OrderDetailGuideOverlays(
          paymentCardKey: paymentCardKey,
          timelineKey: timelineKey,
          chatTabKey: chatTabKey,
          docsTabKey: docsTabKey,
          showPaymentCoach: showPaymentCoach,
          guideStep: guideStep,
          hasPendingPayment: payment != null,
          onPaymentDismissed: onPaymentCoachDismissed,
          onGuideStepChanged: onGuideStepChanged,
          onAnimateToChatTab: () => tabController.animateTo(1),
          onAnimateToDocumentsTab: () => tabController.animateTo(2),
        ),
      ],
    );
  }
}
