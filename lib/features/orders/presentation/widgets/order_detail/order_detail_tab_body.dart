import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/features/chat/presentation/screens/order_chat_tab.dart';
import 'package:go_customer/features/documents/presentation/screens/order_documents_tab.dart';
import 'order_detail_overview_tab.dart';
import 'order_detail_segmented_tab_bar.dart';

/// Tab column (segmented bar + TabBarView) with optional web width constraint.
class OrderDetailTabBody extends ConsumerWidget {
  const OrderDetailTabBody({
    super.key,
    required this.orderId,
    required this.tabController,
    required this.showSegmentedTabBar,
    required this.onSwitchToChat,
  });

  final String orderId;
  final TabController tabController;
  final bool showSegmentedTabBar;
  final VoidCallback onSwitchToChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSegmentedTabBar)
          OrderDetailSegmentedTabBar(
            controller: tabController,
            orderId: orderId,
          ),
        Expanded(
          child: TabBarView(
            physics: AppBreakpoints.useWebShell(context)
                ? const NeverScrollableScrollPhysics()
                : null,
            controller: tabController,
            children: [
              OrderDetailOverviewTab(
                orderId: orderId,
                onChatTap: onSwitchToChat,
              ),
              OrderChatTab(orderId: orderId),
              OrderDocumentsTab(orderId: orderId),
            ],
          ),
        ),
      ],
    );

    if (AppBreakpoints.useWebShell(context)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxW = AppBreakpoints.contentMaxWidth(constraints.maxWidth);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: tabColumn,
            ),
          );
        },
      );
    }

    return tabColumn;
  }
}
