import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/layout/dashboard_layout.dart';
import 'package:go_customer/core/layout/web_app_shell.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/chat/presentation/providers/chat_providers.dart';
import 'package:go_customer/features/orders/presentation/models/web_order_panel_task.dart';
import 'package:go_customer/features/orders/presentation/providers/order_detail_providers.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_mobile_app_bar.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_tab_body.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_web_layout.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialTab = 'overview',
    this.initialPaymentRequestId,
    this.initialReviewPanel,
  });

  final String orderId;
  final String initialTab;

  /// Web: `?paymentRequest=` opens checkout in the right panel.
  final String? initialPaymentRequestId;

  /// Web: `?review=1` opens buyer review in the right panel.
  final String? initialReviewPanel;

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
  bool _isChatTabActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget._initialIndex,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _isChatTabActive = widget._initialIndex == 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPaymentDeepLinkIfNeeded();
      _applyReviewDeepLinkIfNeeded();
    });
  }

  /// Web deep link from home/notifications: open payment panel, strip query.
  void _applyPaymentDeepLinkIfNeeded() {
    final requestId = widget.initialPaymentRequestId;
    if (requestId == null || requestId.isEmpty) return;
    if (!AppBreakpoints.useWebShell(context)) return;

    ref.read(webOrderPanelTaskProvider.notifier).state =
        WebOrderPanelPaymentRequest(
      orderId: widget.orderId,
      requestId: requestId,
    );
    _tabController.index = 0;
    _isChatTabActive = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/order/${widget.orderId}');
    });
  }

  /// Web deep link from home: open review panel, strip query.
  void _applyReviewDeepLinkIfNeeded() {
    if (widget.initialReviewPanel != '1') return;
    if (!AppBreakpoints.useWebShell(context)) return;

    ref.read(webOrderPanelTaskProvider.notifier).state =
        WebOrderPanelReview(orderId: widget.orderId);
    _tabController.index = 0;
    _isChatTabActive = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/order/${widget.orderId}');
    });
  }

  @override
  void didUpdateWidget(OrderDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget._initialIndex);
    }
    if (oldWidget.initialPaymentRequestId != widget.initialPaymentRequestId &&
        widget.initialPaymentRequestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyPaymentDeepLinkIfNeeded();
      });
    }
    if (oldWidget.initialReviewPanel != widget.initialReviewPanel &&
        widget.initialReviewPanel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyReviewDeepLinkIfNeeded();
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    setState(() => _isChatTabActive = _tabController.index == 1);
    if (_tabController.index == 1) {
      markChatAsRead(ref, widget.orderId);
    } else {
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus.hasFocus) {
        focus.unfocus();
      }
    }
  }

  void _onWebTabChanged(int index) {
    _tabController.animateTo(index);
    setState(() => _isChatTabActive = index == 1);
    resetWebOrderPanelTask(ref);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.useWebShell(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: isWeb
          ? WebAppShell(
              activeRoute: '/home',
              child: OrderDetailWebLayout(
                orderId: widget.orderId,
                tabController: _tabController,
                onTabChanged: _onWebTabChanged,
                buildBody: (ctx, showSegBar) => OrderDetailTabBody(
                  orderId: widget.orderId,
                  tabController: _tabController,
                  showSegmentedTabBar: showSegBar,
                  onSwitchToChat: () => _tabController.animateTo(1),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: AppColors.surface,
              appBar: OrderDetailMobileAppBar(
                orderId: widget.orderId,
                isChatTabActive: _isChatTabActive,
              ),
              body: DashboardPortraitFrame(
                child: OrderDetailTabBody(
                  orderId: widget.orderId,
                  tabController: _tabController,
                  showSegmentedTabBar: true,
                  onSwitchToChat: () => _tabController.animateTo(1),
                ),
              ),
            ),
    );
  }
}
