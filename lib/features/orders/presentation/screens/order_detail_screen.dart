import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
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
                        widget.orderId,
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A18),
                    ),
                  ),
                ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE0DFD8)),
        ),
      ),
      body: Builder(
        builder: (context) {
          final payment = ref
              .watch(activePaymentRequestProvider(widget.orderId))
              .valueOrNull;
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
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
                        ),
                        OrderChatTab(orderId: widget.orderId),
                        OrderDocumentsTab(orderId: widget.orderId),
                      ],
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}

class _OrderOverviewTab extends ConsumerWidget {
  final String orderId;
  final GlobalKey timelineKey;
  final GlobalKey paymentCardKey;
  final bool suppressTimelineStageCoaches;

  const _OrderOverviewTab({
    required this.orderId,
    required this.timelineKey,
    required this.paymentCardKey,
    this.suppressTimelineStageCoaches = false,
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
              style: GoogleFonts.dmSans(
                fontSize: 14,
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
                    AppConstants.paymentRequestTypeLabels[p.type
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
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  OrderTimelineConstants.journeyTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.selectionTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Step ${order.stageNumber} of 9',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.infoText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: timelineKey,
              child: OrderTimelineWidget(
                orderId: orderId,
                order: order,
                suppressStageCoachMarks: suppressTimelineStageCoaches,
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
          style: GoogleFonts.dmSans(
            fontSize: 14,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0DFD8), width: 0.5),
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
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF378ADD),
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
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A18),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${agent.totalOrdersCompleted} orders · '
                    '${agent.rating.toStringAsFixed(1)} ★',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
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
