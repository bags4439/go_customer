import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../referral/presentation/widgets/referral_promo_card.dart';
import '../providers/order_providers.dart';

// ─────────────────────────────────────────────
// COLOUR CONSTANTS
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF378ADD);
  static const success = Color(0xFF1D9E75);
  static const danger = Color(0xFFE24B4A);
  static const warning = Color(0xFFBA7517);
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF5F4F0);
  static const bgTertiary = Color(0xFFF0EFE8);
  static const border = Color(0xFFE0DFD8);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFFAAAAAA);
  static const infoBg = Color(0xFFE6F1FB);
  static const infoText = Color(0xFF185FA5);
  static const successBg = Color(0xFFEAF3DE);
  static const dangerBg = Color(0xFFFCEBEB);
  static const warningBg = Color(0xFFFAEEDA);
}

// ─────────────────────────────────────────────
// TEXT STYLE HELPERS
// ─────────────────────────────────────────────
TextStyle _ts({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = _C.textPrimary,
  double height = 1.4,
}) => GoogleFonts.dmSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingPayments = ref.watch(pendingPaymentCountProvider);

    ordersAsync.whenOrNull(
      error: (error, stack) {
        showFailureSnackBar(
          context,
          UnexpectedFailure(
            message: 'Could not load your orders.',
            cause: error,
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: _C.bgPrimary,
      appBar: _buildAppBar(currentUserAsync),
      body: ordersAsync.when(
        data: (orders) => _AnimatedBody(
          child: orders.isEmpty
              ? const _EmptyHome()
              : _MultiOrderHome(
                  orders: orders,
                  pendingPayments: pendingPayments,
                  currentUserName: currentUserAsync.value?.fullName,
                ),
        ),
        loading: () => const _HomeShimmer(),
        error: (_, __) =>
            _ErrorHome(onRetry: () => ref.invalidate(buyerOrdersProvider)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AsyncValue<dynamic> userAsync) {
    return AppBar(
      backgroundColor: _C.bgPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: _C.border),
      ),
      title: userAsync.maybeWhen(
        data: (user) => Text(
          user != null
              ? 'Hi ${user.fullName.split(' ').first} 👋'
              : 'Your orders',
          style: _ts(size: 17, weight: FontWeight.w600),
        ),
        orElse: () =>
            Text('Your orders', style: _ts(size: 17, weight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED BODY WRAPPER
// ─────────────────────────────────────────────
class _AnimatedBody extends StatefulWidget {
  final Widget child;

  const _AnimatedBody({required this.child});

  @override
  State<_AnimatedBody> createState() => _AnimatedBodyState();
}

class _AnimatedBodyState extends State<_AnimatedBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyHome extends StatefulWidget {
  const _EmptyHome();

  @override
  State<_EmptyHome> createState() => _EmptyHomeState();
}

class _EmptyHomeState extends State<_EmptyHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _float = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.04),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _float,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _C.bgSecondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.directions_car_outlined,
                              size: 40,
                              color: _C.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No orders yet',
                          style: _ts(size: 18, weight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by telling us what car you want to import.',
                          style: _ts(size: 13, color: _C.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () =>
                                GoRouter.of(context).push('/preferences/new'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Text(
                              'Import my first car',
                              style: _ts(
                                size: 14,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 64,),
                  const ReferralPromoCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MULTI ORDER HOME
// ─────────────────────────────────────────────
class _MultiOrderHome extends ConsumerStatefulWidget {
  final List<OrderView> orders;
  final int pendingPayments;
  final String? currentUserName;

  const _MultiOrderHome({
    required this.orders,
    required this.pendingPayments,
    required this.currentUserName,
  });

  @override
  ConsumerState<_MultiOrderHome> createState() => _MultiOrderHomeState();
}

class _MultiOrderHomeState extends ConsumerState<_MultiOrderHome> {
  @override
  Widget build(BuildContext context) {
    final active = widget.orders.where((o) => !o.isCompleted).length;
    final completed = widget.orders.where((o) => o.isCompleted).length;
    final needsAction =
        widget.orders.where((o) => o.needsPayment).length +
        widget.pendingPayments;

    // Sort: payment due first, then by urgency
    final sorted = [...widget.orders]
      ..sort((a, b) {
        if (a.needsPayment && !b.needsPayment) return -1;
        if (!a.needsPayment && b.needsPayment) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        return b.stageNumber.compareTo(a.stageNumber);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Greeting
        Text(
          'Hi ${widget.currentUserName?.split(' ').first ?? ''} 👋',
          style: _ts(size: 22, weight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '$active active ${active == 1 ? 'order' : 'orders'}'
          '${needsAction > 0 ? ' · $needsAction need${needsAction == 1 ? 's' : ''} action' : ''}',
          style: _ts(size: 13, color: _C.textSecondary),
        ),
        const SizedBox(height: 16),

        // Metric cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Active',
                value: '$active',
                valueColor: _C.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: 'Action needed',
                value: '$needsAction',
                valueColor: needsAction > 0 ? _C.danger : _C.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                label: 'Completed',
                value: '$completed',
                valueColor: _C.success,
              ),
            ),
          ],
        ),
        // Section label
        Text(
          'YOUR ORDERS',
          style: _ts(size: 10, weight: FontWeight.w500, color: _C.textTertiary),
        ),
        const SizedBox(height: 8),

        // Order cards with stagger
        ...sorted.asMap().entries.map(
          (entry) => _StaggeredItem(
            index: entry.key,
            child: _OrderCard(order: entry.value),
          ),
        ),

        const SizedBox(height: 8),

        // Import another
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => GoRouter.of(context).go('/preferences/new'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.primary,
              side: const BorderSide(color: _C.primary, width: 1),
            ),
            child: Text(
              '+ Import another car',
              style: _ts(size: 13, weight: FontWeight.w500, color: _C.primary),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const ReferralPromoCard(),

      ],
    );
  }
}

// ─────────────────────────────────────────────
// STAGGERED LIST ITEM
// ─────────────────────────────────────────────
class _StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredItem({required this.index, required this.child});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─────────────────────────────────────────────
// METRIC CARD
// ─────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.bgSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: _ts(size: 22, weight: FontWeight.w600, color: valueColor),
          ),
          const SizedBox(height: 3),
          Text(label, style: _ts(size: 11, color: _C.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────
class _OrderCard extends ConsumerWidget {
  final OrderView order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final paymentAsync = ref.watch(activePaymentRequestProvider(order.id));

    Color accentColor;
    if (order.needsPayment) {
      accentColor = _C.danger;
    } else if (order.isCompleted) {
      accentColor = _C.success;
    } else {
      accentColor = _C.primary;
    }

    final progress = (order.stageNumber.clamp(1, 9)) / 9.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => router.go('/order/${order.id}'),
          borderRadius: BorderRadius.circular(12),
          splashColor: _C.infoBg,
          highlightColor: _C.bgSecondary,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _C.border, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accent left bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 4,
                      color: accentColor,
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: car info + badge
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _C.bgSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_outlined,
                                    size: 20,
                                    color: _C.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${order.make ?? 'Vehicle'} ${order.model ?? ''}'
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _ts(
                                          size: 13,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.orderRef,
                                        style: _ts(
                                          size: 11,
                                          color: _C.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusBadge(order: order),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Payment inline CTA or status text
                            paymentAsync.when(
                              data: (p) {
                                if (p == null) {
                                  return Text(
                                    _statusDescription(order),
                                    style: _ts(
                                      size: 12,
                                      color: _C.textSecondary,
                                    ),
                                  );
                                }
                                return _PaymentInlineCta(
                                  payment: p,
                                  orderId: order.id,
                                );
                              },
                              loading: () => const SizedBox(height: 14),
                              error: (_, __) => Text(
                                _statusDescription(order),
                                style: _ts(size: 12, color: _C.textSecondary),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Progress bar
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor: _C.border,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Step ${order.stageNumber} of 9',
                                  style: _ts(size: 10, color: _C.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusDescription(OrderView order) {
    if (order.needsPayment) return 'Payment required to continue';
    if (order.isCompleted) return 'Delivered · order complete';
    if (order.isCancelled) return 'This order was cancelled';
    switch (order.status) {
      case FirestoreEnumValues.orderStatusOpen:
        return 'Order created · we\'ll match you with an agent';
      case FirestoreEnumValues.orderStatusAgentAssigned:
        return 'Your agent is on it';
      case FirestoreEnumValues.orderStatusSearching:
        return 'Searching for your vehicle';
      case FirestoreEnumValues.orderStatusBidPlaced:
        return 'A bid is live on your chosen vehicle';
      case FirestoreEnumValues.orderStatusBidWon:
        return 'Vehicle secured · next steps in chat';
      case FirestoreEnumValues.orderStatusBidLost:
        return 'Could not secure vehicle · your agent will suggest next options';
      case FirestoreEnumValues.orderStatusPaymentReceived:
        return 'Payment received · moving to shipping';
      case FirestoreEnumValues.orderStatusShipping:
        return '🚢 Your car is in transit';
      case FirestoreEnumValues.orderStatusArrived:
        return 'Vehicle arrived · customs & clearance next';
      case FirestoreEnumValues.orderStatusDutyPending:
        return 'Import duty assessment in progress';
      case FirestoreEnumValues.orderStatusDutyPaid:
        return 'Duty paid · clearance in progress';
      case FirestoreEnumValues.orderStatusClearanceInProgress:
        return 'Port clearance in progress';
      case FirestoreEnumValues.orderStatusClearanceComplete:
        return 'Clearance complete';
      case FirestoreEnumValues.orderStatusRepairPending:
        return 'Repairs pending confirmation';
      case FirestoreEnumValues.orderStatusRepairInProgress:
        return 'Repairs in progress';
      case FirestoreEnumValues.orderStatusRepairComplete:
        return 'Repairs complete · delivery next';
      case FirestoreEnumValues.orderStatusDormant:
      default:
        return 'No recent activity · open chat if you need help';
    }
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderView order;

  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color text;

    if (order.needsPayment) {
      label = 'Pay now';
      bg = _C.dangerBg;
      text = _C.danger;
    } else if (order.isCompleted) {
      label = 'Delivered';
      bg = _C.successBg;
      text = _C.success;
    } else {
      switch (order.status) {
        case FirestoreEnumValues.orderStatusOpen:
          label = 'Submitted';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
          break;
        case FirestoreEnumValues.orderStatusAgentAssigned:
          label = 'Agent assigned';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusSearching:
          label = 'Searching';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusBidPlaced:
          label = 'Bid placed';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusBidWon:
          label = 'Won auction';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusBidLost:
          label = 'Bid lost';
          bg = _C.dangerBg;
          text = _C.danger;
          break;
        case FirestoreEnumValues.orderStatusPaymentReceived:
          label = 'Paid';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusShipping:
          label = 'Shipping';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusArrived:
          label = 'Arrived';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusDutyPending:
          label = 'Duty pending';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusDutyPaid:
          label = 'Duty paid';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceInProgress:
          label = 'Clearance';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceComplete:
          label = 'Cleared';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusRepairPending:
          label = 'Repairs';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairInProgress:
          label = 'In repair';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairComplete:
          label = 'Repairs done';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusCancelled:
          label = 'Cancelled';
          bg = _C.dangerBg;
          text = _C.danger;
          break;
        case FirestoreEnumValues.orderStatusDormant:
          label = 'On hold';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
          break;
        default:
          label = 'In progress';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: _ts(size: 10, weight: FontWeight.w500, color: text),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAYMENT INLINE CTA
// ─────────────────────────────────────────────
class _PaymentInlineCta extends StatelessWidget {
  final dynamic payment; // your PaymentRequestView type
  final String orderId;

  const _PaymentInlineCta({required this.payment, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.formatGhs(payment.totalGhs),
                  style: _ts(
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.paymentRequestTypeLabels[payment.type] ??
                      payment.type,
                  style: _ts(size: 11, color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => GoRouter.of(
              context,
            ).go('/order/$orderId/payment-request/${payment.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pay now',
                style: _ts(
                  size: 12,
                  weight: FontWeight.w600,
                  color: _C.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHIMMER LOADING
// ─────────────────────────────────────────────
class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _C.bgSecondary,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting shimmer
            _ShimmerBox(width: 180, height: 24, radius: 6),
            const SizedBox(height: 8),
            _ShimmerBox(width: 240, height: 14, radius: 4),
            const SizedBox(height: 16),
            // Metric cards
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
              ],
            ),
            const SizedBox(height: 20),
            _ShimmerBox(width: 80, height: 12, radius: 4),
            const SizedBox(height: 10),
            // Order card shimmers
            for (int i = 0; i < 3; i++) ...[
              _ShimmerBox(height: 96, radius: 12),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _C.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────
class _ErrorHome extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorHome({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                size: 32,
                color: _C.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load orders',
              style: _ts(size: 16, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: _ts(size: 13, color: _C.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 44,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _C.border),
                ),
                child: Text(
                  'Retry',
                  style: _ts(
                    size: 13,
                    weight: FontWeight.w500,
                    color: _C.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NOTE: _SingleOrderHome has been removed.
// Single orders now navigate directly to
// /order/:orderId via the _OrderCard tap.
// The order detail screen handles Overview /
// Chat / Documents tabs per-order.
// ─────────────────────────────────────────────
