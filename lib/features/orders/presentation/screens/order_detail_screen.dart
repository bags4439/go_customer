import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../../../guide/presentation/widgets/guide_help_button.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget._initialIndex,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapGuides());
  }

  Future<void> _bootstrapGuides() async {
    if (!mounted) return;
    final payment =
        ref.read(activePaymentRequestProvider(widget.orderId)).valueOrNull;
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
    if (_tabController.index == 1) {
      markChatAsRead(ref, widget.orderId);
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
    final orderAsync = ref.watch(orderProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: orderAsync.maybeWhen(
          data: (order) {
            if (order == null) {
              return Text(
                'Order',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              );
            }
            final vehicleTitle = '${order.make ?? ''} ${order.model ?? ''}'
                .trim();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vehicleTitle.isEmpty ? 'Vehicle' : vehicleTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.orderRef,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            );
          },
          orElse: () => Text(
            'Order',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
        actions: [
          GuideHelpButton(
            onShowGuide: () => setState(() {
              _showPaymentCoach = false;
              _guideStep = 1;
            }),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final payment =
              ref.watch(activePaymentRequestProvider(widget.orderId)).valueOrNull;
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
              if (_showPaymentCoach &&
                  payment != null &&
                  _guideStep == 0)
                CoachMarkOverlay(
                  guideKey: GuideKeys.orderPaymentRequest,
                  targetKey: _paymentCardKey,
                  title: 'Payment request from your agent',
                  body: 'Your agent sent a payment request. '
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
                  body: 'This timeline tracks every stage '
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
                  body: 'Your dedicated agent is always '
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
                  body: 'All your import papers live here '
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
