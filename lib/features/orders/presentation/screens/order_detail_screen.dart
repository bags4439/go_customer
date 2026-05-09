import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/panel_divider.dart';
import '../../../../core/layout/web_app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../providers/order_providers.dart';
import '../widgets/order_detail_car_card.dart';
import '../widgets/segmented_tab_bar.dart';
import '../widgets/order_detail_edit_cancel.dart';
import '../widgets/order_detail_payment_card.dart';
import '../widgets/order_timeline_widget.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../chat/presentation/screens/order_chat_tab.dart';
import '../../../documents/presentation/screens/order_documents_tab.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/coach_mark_card.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';

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
    final payment = ref
        .read(activePaymentRequestProvider(widget.orderId))
        .valueOrNull;
    if (payment != null) {
      final paymentSeen = await ref.read(
        hasSeenGuideProvider(GuideKeys.orderPaymentRequest).future,
      );
      if (!mounted) return;
      if (!paymentSeen) {
        setState(() => _showPaymentCoach = true);
        return;
      }
    }
    final timelineSeen = await ref.read(
      hasSeenGuideProvider(GuideKeys.orderTimeline).future,
    );
    if (!mounted) return;
    if (!timelineSeen) {
      setState(() => _guideStep = 1);
    }
  }

  Future<void> _maybeStartChainAfterPaymentCoach() async {
    if (!mounted) return;
    final timelineSeen = await ref.read(
      hasSeenGuideProvider(GuideKeys.orderTimeline).future,
    );
    if (!mounted) return;
    if (!timelineSeen) {
      setState(() => _guideStep = 1);
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
    // Only fire when the tab animation
    // is fully settled — not on every
    // frame during a swipe. This prevents
    // setState being called mid-rebuild
    // which breaks context.pop() in the
    // AppBar back button.
    if (_tabController.indexIsChanging) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isChatTabActive = _tabController.index == 1;
    });
    if (_tabController.index == 1) {
      markChatAsRead(ref, widget.orderId);
    } else {
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus.hasFocus) {
        focus.unfocus();
      }
    }
  }

  void _onSwitchToChat() {
    _tabController.animateTo(1);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final tw = AppBreakpoints.timelinePanelWidth(totalWidth);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: tw,
                        child: _OrderTimelinePanel(
                          orderId: widget.orderId,
                          currentTab: _tabController.index,
                          onTabSelected: (i) {
                            _tabController.animateTo(i);
                            setState(() {
                              _isChatTabActive = i == 1;
                            });
                          },
                        ),
                      ),
                      const PanelDivider(),
                      Expanded(
                        child: Scaffold(
                          backgroundColor: AppColors.background,
                          appBar: _buildWebDetailAppBar(context),
                          body: _buildBody(context, showSegmentedTabBar: false),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(context),
              body: _buildBody(context, showSegmentedTabBar: true),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.go('/home'),
      ),
      titleSpacing: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: _isChatTabActive
            ? _AgentAppBarTitle(
                key: const ValueKey('agent'),
                orderId: widget.orderId,
              )
            : Padding(
                key: const ValueKey('order'),
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  ref
                          .watch(orderProvider(widget.orderId))
                          .valueOrNull
                          ?.orderRef ??
                      '--',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFF1A1A18),
                  ),
                ),
              ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: const Color(0xFFE0DFD8)),
      ),
    );
  }

  PreferredSizeWidget _buildWebDetailAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 52,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isChatTabActive
            ? _AgentAppBarTitle(
                key: const ValueKey('agent'),
                orderId: widget.orderId,
              )
            : Text(
                ref
                        .watch(orderProvider(widget.orderId))
                        .valueOrNull
                        ?.orderRef ??
                    '--',
                key: const ValueKey('order'),
                style: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF1A1A18),
                ),
              ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: () {
              _tabController.animateTo(1);
              setState(() {
                _isChatTabActive = true;
              });
            },
            icon: const Icon(Icons.chat_rounded, size: 16),
            label: const Text('Chat with agent'),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.borderSolid),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required bool showSegmentedTabBar}) {
    return Builder(
      builder: (context) {
        final payment = ref
            .watch(activePaymentRequestProvider(widget.orderId))
            .valueOrNull;
        final tabColumn = Column(
          children: [
            if (showSegmentedTabBar)
              SegmentedTabBar(
                controller: _tabController,
                orderId: widget.orderId,
                chatTabKey: _chatTabKey,
                documentsTabKey: _docsTabKey,
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OrderOverviewTab(
                    orderId: widget.orderId,
                    timelineKey: _timelineKey,
                    paymentCardKey: _paymentCardKey,
                    suppressTimelineStageCoaches:
                        _showPaymentCoach || _guideStep != 0,
                    onChatTap: _onSwitchToChat,
                  ),
                  OrderChatTab(orderId: widget.orderId),
                  OrderDocumentsTab(orderId: widget.orderId),
                ],
              ),
            ),
          ],
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            if (AppBreakpoints.isWeb(context))
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = AppBreakpoints.contentMaxWidth(
                    constraints.maxWidth,
                  );
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: tabColumn,
                    ),
                  );
                },
              )
            else
              tabColumn,
            if (_showPaymentCoach && payment != null && _guideStep == 0)
              CoachMarkOverlay(
                guideKey: GuideKeys.orderPaymentRequest,
                targetKey: _paymentCardKey,
                title: 'Payment request from your agent',
                body:
                    'Your agent sent a payment request. '
                    'Review the details carefully — '
                    'no money leaves your account until '
                    'you approve it here.',
                spotlightShape: SpotlightShape.roundedRect,
                cardPosition: CardPosition.below,
                onDismiss: () {
                  setState(() => _showPaymentCoach = false);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _maybeStartChainAfterPaymentCoach(),
                  );
                },
                onFaqTap: () {
                  setState(() => _showPaymentCoach = false);
                  GuideFaqSheet.show(context);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _maybeStartChainAfterPaymentCoach(),
                  );
                },
              ),
            if (_guideStep == 1 && !_showPaymentCoach)
              CoachMarkOverlay(
                guideKey: GuideKeys.orderTimeline,
                targetKey: _timelineKey,
                title: 'Your import journey',
                body:
                    'This timeline tracks every stage '
                    'from search to delivery. Tap any '
                    'stage to see more details.',
                spotlightShape: SpotlightShape.roundedRect,
                onDismiss: () => setState(() => _guideStep = 0),
                onNext: () {
                  setState(() {
                    _guideStep = 2;
                  });
                  _tabController.animateTo(1);
                },
                onFaqTap: () {
                  setState(() => _guideStep = 0);
                  GuideFaqSheet.show(context);
                },
              ),
            if (_guideStep == 2 && !_showPaymentCoach)
              CoachMarkOverlay(
                guideKey: GuideKeys.chat,
                targetKey: _chatTabKey,
                title: 'Chat with your agent',
                body:
                    'Your dedicated agent is always '
                    'available here. Ask anything — '
                    'they handle everything for you.',
                spotlightShape: SpotlightShape.roundedRect,
                onDismiss: () => setState(() => _guideStep = 0),
                onNext: () {
                  setState(() {
                    _guideStep = 3;
                  });
                  _tabController.animateTo(2);
                },
                onFaqTap: () {
                  setState(() => _guideStep = 0);
                  GuideFaqSheet.show(context);
                },
              ),
            if (_guideStep == 3 && !_showPaymentCoach)
              CoachMarkOverlay(
                guideKey: GuideKeys.documents,
                targetKey: _docsTabKey,
                title: 'Your documents',
                body:
                    'All your import papers live here '
                    '— receipts, vehicle title, clearance '
                    'docs and more. Always accessible.',
                spotlightShape: SpotlightShape.roundedRect,
                onDismiss: () => setState(() => _guideStep = 0),
                onFaqTap: () {
                  setState(() => _guideStep = 0);
                  GuideFaqSheet.show(context);
                },
              ),
          ],
        );
      },
    );
  }
}

/// Step labels aligned with [OrderTimelineConstants.journeyTitle] stages
/// and the 9-step journey used on home order cards.
const List<String> _kOrderTimelineStepNames = [
  'Preferences submission',
  'Agent assignment',
  'Deposit & service fee',
  'Vehicle search',
  'Vehicle balance',
  'Shipping',
  'Duty & clearance',
  'Repairs',
  'Delivery',
];

String _orderVehicleHeadline(OrderView? order) {
  if (order == null) return '--';
  final name = '${order.make ?? ''} ${order.model ?? ''}'.trim();
  return name.isNotEmpty ? name : order.orderRef;
}

String _orderCurrentStageHeadline(OrderView? order) {
  if (order == null) return '--';
  final sn = order.stageNumber.clamp(1, _kOrderTimelineStepNames.length);
  return _kOrderTimelineStepNames[sn - 1];
}

class _OrderTimelinePanel extends ConsumerWidget {
  const _OrderTimelinePanel({
    required this.orderId,
    required this.currentTab,
    required this.onTabSelected,
  });

  final String orderId;
  final int currentTab;
  final void Function(int) onTabSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final order = orderAsync.valueOrNull;

    return Container(
      color: AppColors.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _orderVehicleHeadline(order),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      order?.orderRef ?? '--',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (order != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.infoBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${order.stageNumber} of 9',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.infoText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A5FA5), Color(0xFF378ADD)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Import progress',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (ctx, constraints) {
                                final sw = MediaQuery.sizeOf(ctx).width;
                                return Text(
                                  order == null
                                      ? '--'
                                      : '${((order.stageNumber / 9) * 100).round()}%',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: AppBreakpoints.scaledFontSize(
                                      16,
                                      sw,
                                    ),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _orderCurrentStageHeadline(order),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: order == null
                                ? 0
                                : (order.stageNumber.clamp(1, 9) / 9),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'JOURNEY',
                    style: AppTextStyles.sectionLabel.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order != null) _TimelineStepsList(order: order),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Row(
              children: [
                _TimelinePanelTab(
                  label: 'Overview',
                  isSelected: currentTab == 0,
                  onTap: () => onTabSelected(0),
                ),
                _TimelinePanelTab(
                  label: 'Chat',
                  isSelected: currentTab == 1,
                  onTap: () => onTabSelected(1),
                ),
                _TimelinePanelTab(
                  label: 'Documents',
                  isSelected: currentTab == 2,
                  onTap: () => onTabSelected(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanelTab extends StatelessWidget {
  const _TimelinePanelTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineStepsList extends StatelessWidget {
  const _TimelineStepsList({required this.order});

  final OrderView order;

  @override
  Widget build(BuildContext context) {
    final currentStage = order.stageNumber;

    return Column(
      children: List.generate(_kOrderTimelineStepNames.length, (i) {
        final stepNumber = i + 1;
        final isDone = stepNumber < currentStage;
        final isActive = stepNumber == currentStage;
        final isPending = stepNumber > currentStage;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              _StepIndicator(isDone: isDone, isActive: isActive),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _kOrderTimelineStepNames[i],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: isPending
                        ? AppColors.textTertiary
                        : isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.isDone, required this.isActive});

  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 8, color: Colors.white),
      );
    }
    if (isActive) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondary, width: 2),
          color: AppColors.infoBackground,
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSolid, width: 1.5),
      ),
    );
  }
}

class _OrderOverviewTab extends ConsumerWidget {
  final String orderId;
  final GlobalKey timelineKey;
  final GlobalKey paymentCardKey;
  final bool suppressTimelineStageCoaches;
  final VoidCallback? onChatTap;

  const _OrderOverviewTab({
    required this.orderId,
    required this.timelineKey,
    required this.paymentCardKey,
    this.suppressTimelineStageCoaches = false,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final paymentAsync = ref.watch(activePaymentRequestProvider(orderId));
    final router = GoRouter.of(context);

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return Center(
            child: Text(
              'Order not found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            paymentAsync.when(
              data: (p) {
                if (p == null) return const SizedBox.shrink();
                final typeLabel =
                    FirestoreEnumValues.paymentRequestTypeLabels[p.type
                            is PaymentRequestType
                        ? (p.type as PaymentRequestType).firestoreValue
                        : p.type.toString()] ??
                    p.type.toString();
                final deadlineStr = p.deadlineAt != null
                    ? formatOrderDetailDeadline(p.deadlineAt!)
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KeyedSubtree(
                      key: paymentCardKey,
                      child: OrderDetailPaymentCard(
                        payment: p,
                        typeLabel: typeLabel,
                        deadlineText: deadlineStr,
                        onPayPressed: () => router.go(
                          '/order/${order.id}/payment-request/${p.id}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            OrderDetailCarCard(order: order),
            const SizedBox(height: 14),
            Text(
              OrderTimelineConstants.journeyTitle,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: timelineKey,
              child: OrderTimelineWidget(
                orderId: orderId,
                order: order,
                suppressStageCoachMarks: suppressTimelineStageCoaches,
                onChatTap: onChatTap,
              ),
            ),
            if (ref.watch(canEditOrderProvider(order.id))) ...[
              const SizedBox(height: 20),
              OrderDetailEditCancelSection(orderId: order.id),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      error: (_, __) => Center(
        child: Text(
          'Unable to load order',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AgentAppBarTitle extends ConsumerWidget {
  final String orderId;

  const _AgentAppBarTitle({super.key, required this.orderId});

  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final agentId = orderAsync.valueOrNull?.agentId;

    if (agentId == null) {
      return const SizedBox.shrink();
    }

    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      data: (agent) {
        if (agent == null) {
          return const SizedBox.shrink();
        }
        return Row(
          children: [
            GestureDetector(
              onTap: (agent.photoUrl != null && agent.photoUrl!.isNotEmpty)
                  ? () => Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        opaque: false,
                        barrierColor: Colors.black87,
                        transitionDuration: const Duration(milliseconds: 250),
                        pageBuilder: (_, __, ___) => _AgentPhotoViewer(
                          photoUrl: agent.photoUrl!,
                          agentName: agent.fullName,
                        ),
                      ),
                    )
                  : null,
              child: Hero(
                tag: 'agent_photo_${agent.photoUrl ?? ''}',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0DFD8),
                      width: 0.5,
                    ),
                  ),
                  child: ClipOval(
                    child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: agent.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFFE6F1FB),
                              child: const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Color(0xFF378ADD),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFE6F1FB),
                              child: const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Color(0xFF378ADD),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFE6F1FB),
                            child: Center(
                              child: Text(
                                agent.fullName.isNotEmpty
                                    ? agent.fullName[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: const Color(0xFF378ADD),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    agent.fullName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: const Color(0xFF1A1A18),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${agent.totalOrdersCompleted} orders · '
                    '${agent.rating.toStringAsFixed(1)} ★',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            if (agent.phone != null && agent.phone!.isNotEmpty)
              GestureDetector(
                onTap: () => _launchCall(agent.phone),
                child: Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F1FB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    size: 17,
                    color: Color(0xFF378ADD),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EFE9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 120,
            height: 13,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFE9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AgentPhotoViewer extends StatelessWidget {
  final String photoUrl;
  final String agentName;

  const _AgentPhotoViewer({required this.photoUrl, required this.agentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'agent_photo_$photoUrl',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A18),
                    child: const Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                MediaQuery.of(context).padding.top + 8,
                8,
                16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      agentName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
