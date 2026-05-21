import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/layout/web_app_shell.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/chat/presentation/providers/chat_providers.dart';
import 'package:go_customer/features/orders/presentation/providers/order_detail_providers.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_guide.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_mobile_app_bar.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_tab_body.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_detail/order_detail_web_layout.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialTab = 'overview',
  });

  final String orderId;
  final String initialTab;

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

  final _timelineKey = GlobalKey();
  final _chatTabKey = GlobalKey();
  final _docsTabKey = GlobalKey();
  final _paymentCardKey = GlobalKey();

  int _guideStep = 0;
  bool _showPaymentCoach = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapGuides());
  }

  Future<void> _bootstrapGuides() async {
    if (!mounted) return;
    if (await OrderDetailGuideBootstrap.shouldShowPaymentCoach(
      ref,
      widget.orderId,
    )) {
      if (!mounted) return;
      setState(() => _showPaymentCoach = true);
      return;
    }
    final step = await OrderDetailGuideBootstrap.timelineStepIfNeeded(ref);
    if (!mounted) return;
    if (step != null) {
      setState(() => _guideStep = step);
    }
  }

  Future<void> _chainGuideAfterPaymentCoach() async {
    setState(() => _showPaymentCoach = false);
    final step = await OrderDetailGuideBootstrap.timelineStepIfNeeded(ref);
    if (!mounted) return;
    if (step != null) {
      setState(() => _guideStep = step);
    }
  }

  @override
  void didUpdateWidget(OrderDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget._initialIndex);
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
    if (index != 0) {
      resetWebOrderPanelTask(ref);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Widget _tabBody({required bool showSegmentedTabBar}) {
    return OrderDetailTabBody(
      orderId: widget.orderId,
      tabController: _tabController,
      showSegmentedTabBar: showSegmentedTabBar,
      timelineKey: _timelineKey,
      paymentCardKey: _paymentCardKey,
      chatTabKey: _chatTabKey,
      docsTabKey: _docsTabKey,
      showPaymentCoach: _showPaymentCoach,
      guideStep: _guideStep,
      suppressTimelineStageCoaches: _showPaymentCoach || _guideStep != 0,
      onPaymentCoachDismissed: () {
        setState(() => _showPaymentCoach = false);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _chainGuideAfterPaymentCoach(),
        );
      },
      onGuideStepChanged: (step) => setState(() => _guideStep = step),
      onSwitchToChat: () => _tabController.animateTo(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);

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
                buildBody: (ctx, showSegBar) =>
                    _tabBody(showSegmentedTabBar: showSegBar),
              ),
            )
          : Scaffold(
              backgroundColor: AppColors.background,
              appBar: OrderDetailMobileAppBar(
                orderId: widget.orderId,
                isChatTabActive: _isChatTabActive,
              ),
              body: _tabBody(showSegmentedTabBar: true),
            ),
    );
  }
}
