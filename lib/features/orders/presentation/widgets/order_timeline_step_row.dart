import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../delivery/presentation/providers/delivery_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../payments/presentation/widgets/payment_request_card.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import '../../data/models/order_timeline_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../../../vehicle_options/core/constants/vehicle_option_constants.dart';
import '../../../vehicle_options/presentation/providers/vehicle_option_providers.dart';
import '../providers/order_providers.dart';
import '../utils/repair_timeline_resolver.dart';
import '../utils/timeline_payment_resolver.dart';
import 'order_detail/order_detail_web_navigation.dart';
import 'clearance_status_card.dart';
import 'repair_status_card.dart';
import 'shipping_status_card.dart';

const _kPrimary = 0xFF378ADD;
const _kSuccess = 0xFF1D9E75;
const _kTextSecondary = 0xFF666666;
const _kDeliveredGreen = 0xFF1A4731;
const _kDeliveredSub = 0xFF27500A;

bool _isPostVehicleBalancePaid(String status) {
  const s = {
    FirestoreEnumValues.orderStatusPaymentReceived,
    FirestoreEnumValues.orderStatusShipping,
    FirestoreEnumValues.orderStatusArrived,
    FirestoreEnumValues.orderStatusDutyPending,
    FirestoreEnumValues.orderStatusDutyPaid,
    FirestoreEnumValues.orderStatusClearanceInProgress,
    FirestoreEnumValues.orderStatusClearanceComplete,
    FirestoreEnumValues.orderStatusRepairPending,
    FirestoreEnumValues.orderStatusRepairInProgress,
    FirestoreEnumValues.orderStatusRepairComplete,
    FirestoreEnumValues.orderStatusDelivered,
  };
  return s.contains(status);
}

/// One row of the order journey timeline (Firestore-driven).
class OrderTimelineStepRow extends ConsumerWidget {
  final OrderTimelineModel stage;
  final String orderId;
  final OrderView order;
  final bool isLast;
  // ignore: unused_field
  final bool lineAfterIsComplete;
  final List<PaymentRequestModel> pendingPayments;
  final ShippingModel? shipping;
  final DutyClearanceModel? clearance;
  final RepairJobModel? repairJob;
  final VoidCallback? onChatTap;
  final void Function(String stageKey)? onStepTapped;

  const OrderTimelineStepRow({
    super.key,
    required this.stage,
    required this.orderId,
    required this.order,
    required this.isLast,
    required this.lineAfterIsComplete,
    required this.pendingPayments,
    this.shipping,
    this.clearance,
    this.repairJob,
    this.onChatTap,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageNumber = stage.stageNumber;
    final orderStageNumber = order.stageNumber;
    final isDeliveryStage = stage.stageKey == 'delivery';
    final deliveryComplete = isDeliveryStage &&
        (stage.completedAt != null ||
            order.status == AppConstants.statusDeliveryConfirmed ||
            order.status == AppConstants.statusDelivered);
    final isComplete =
        stageNumber < orderStageNumber || deliveryComplete;
    final isActive = stageNumber == orderStageNumber && !deliveryComplete;

    final lineColor = isComplete
        ? AppColors.success
        : isActive
        ? AppColors.secondary.withValues(alpha: 0.3)
        : AppColors.borderSolid;

    const dotTopOffset = 12.0;
    const dotSize = 22.0;
    const lineStart = dotTopOffset + dotSize + 3;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 21,
            top: lineStart,
            bottom: 0,
            child: Container(width: 1.5, color: lineColor),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: isComplete
                    ? const _CompletedDot()
                    : isActive
                    ? const _PulsingActiveDot()
                    : _UpcomingDot(number: stageNumber),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 8),
                child: isComplete
                    ? _CompletedRow(
                        stage: stage,
                        isLast: isLast,
                        orderId: orderId,
                        order: order,
                        repairJob: repairJob,
                      )
                    : isActive
                    ? _ActiveStageContent(
                        stage: stage,
                        orderId: orderId,
                        order: order,
                        isLast: isLast,
                        pendingPayments: pendingPayments,
                        shipping: shipping,
                        clearance: clearance,
                        repairJob: repairJob,
                        onChatTap: onChatTap,
                        onStepTapped: onStepTapped,
                      )
                    : _UpcomingRow(stage: stage, isLast: isLast),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletedDot extends StatelessWidget {
  const _CompletedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
      ),
    );
  }
}

class _PulsingActiveDot extends StatefulWidget {
  const _PulsingActiveDot();

  @override
  State<_PulsingActiveDot> createState() => _PulsingActiveDotState();
}

class _PulsingActiveDotState extends State<_PulsingActiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingDot extends StatelessWidget {
  // ignore: unused_field
  final int number;

  const _UpcomingDot({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSolid, width: 1.5),
      ),
    );
  }
}

class _CompletedRow extends ConsumerWidget {
  final OrderTimelineModel stage;
  final bool isLast;
  final String orderId;
  final OrderView order;
  final RepairJobModel? repairJob;

  const _CompletedRow({
    required this.stage,
    required this.isLast,
    required this.orderId,
    required this.order,
    this.repairJob,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = _formatDate(stage.completedAt);
    final isRepairComplete =
        stage.stageKey == 'repair' &&
        repairJob?.status == RepairStatus.completed;

    final isDeliveryPendingReview =
        stage.stageKey == 'delivery' &&
        order.status == AppConstants.statusDeliveryConfirmed;

    if (isDeliveryPendingReview) {
      final userId = ref.watch(authStateProvider).value;
      if (userId != null) {
        final reviewAsync = ref.watch(
          buyerReviewProvider((orderId: orderId, buyerId: userId)),
        );
        final review = reviewAsync.valueOrNull;
        if (review == null) {
          return Padding(
            padding: EdgeInsets.only(top: 8, bottom: isLast ? 4 : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => OrderDetailWebNavigation.openReview(
                  context,
                  ref,
                  orderId,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(_kSuccess).withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_outline_rounded,
                        size: 16,
                        color: Color(_kSuccess),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              OrderTimelineConstants.deliveryCompletedRowSub,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(dateStr, style: AppTextStyles.caption),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    if (isRepairComplete) {
      return Padding(
        padding: EdgeInsets.only(top: 8, bottom: isLast ? 4 : 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => OrderDetailWebNavigation.openRepair(
              context,
              ref,
              orderId,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successMutedBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.successMutedBorder,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          OrderTimelineConstants.repairCompletedRowSub,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(dateStr, style: AppTextStyles.caption),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: isLast ? 4 : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              stage.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (dateStr.isNotEmpty) Text(dateStr, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final OrderTimelineModel stage;
  final bool isLast;

  const _UpcomingRow({required this.stage, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: isLast ? 4 : 0),
      child: Text(
        stage.label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

class _ActiveStageContent extends StatelessWidget {
  final OrderTimelineModel stage;
  final String orderId;
  final OrderView order;
  // ignore: unused_field
  final bool isLast;
  final List<PaymentRequestModel> pendingPayments;
  final ShippingModel? shipping;
  final DutyClearanceModel? clearance;
  final RepairJobModel? repairJob;
  final VoidCallback? onChatTap;
  final void Function(String stageKey)? onStepTapped;

  const _ActiveStageContent({
    required this.stage,
    required this.orderId,
    required this.order,
    required this.isLast,
    required this.pendingPayments,
    this.shipping,
    this.clearance,
    this.repairJob,
    this.onChatTap,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final card = _buildActiveCard(context);
    if (AppBreakpoints.useWebShell(context) && onStepTapped != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onStepTapped!(stage.stageKey),
        child: card,
      );
    }
    return card;
  }

  Widget _buildActiveCard(BuildContext context) {
    final pendingRepairPay = RepairTimelineResolver.pendingRepairPayment(
      pendingPayments,
    );
    final isRepairStage = stage.stageKey == 'repair';
    final repairBadge = isRepairStage
        ? RepairTimelineResolver.activeBadge(
            repairJob,
            pendingPayment: pendingRepairPay,
          )
        : null;
    final repairDetail = isRepairStage
        ? RepairTimelineResolver.summaryDetail(
            repairJob,
            pendingPayment: pendingRepairPay,
          )
        : null;
    final badgeStyle = _repairBadgeStyle(repairBadge);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(stage.label, style: AppTextStyles.titleSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: repairBadge != null
                        ? badgeStyle.bg
                        : AppColors.infoBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    repairBadge ?? 'In progress',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: repairBadge != null
                          ? badgeStyle.fg
                          : AppColors.infoText,
                    ),
                  ),
                ),
                if (AppBreakpoints.useWebShell(context) && onStepTapped != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onStepTapped!(stage.stageKey),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Details →',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if ((repairDetail ?? stage.detail)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                repairDetail ?? stage.detail!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(top: 10),
            color: AppColors.borderSolid,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: OrderTimelineSubActionArea(
              stage: stage,
              orderId: orderId,
              order: order,
              pendingPayments: pendingPayments,
              shipping: shipping,
              clearance: clearance,
              repairJob: repairJob,
              onChatTap: onChatTap,
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg}) _repairBadgeStyle(String? badge) {
    if (badge == OrderTimelineConstants.repairBadgeNoRepairs) {
      return (bg: AppColors.surface, fg: AppColors.textSecondary);
    }
    if (badge == OrderTimelineConstants.repairBadgeComplete ||
        badge == OrderTimelineConstants.repairBadgeDepositPaid ||
        badge == OrderTimelineConstants.repairBadgeQuoteApproved) {
      return (
        bg: AppColors.success.withValues(alpha: 0.12),
        fg: AppColors.success,
      );
    }
    if (badge == OrderTimelineConstants.repairBadgeReviewQuote ||
        badge == OrderTimelineConstants.repairBadgeDepositDue ||
        badge == OrderTimelineConstants.repairBadgeBalanceDue ||
        badge == OrderTimelineConstants.repairBadgeAction) {
      return (bg: AppColors.amberBackground, fg: AppColors.amberText);
    }
    if (badge == OrderTimelineConstants.repairBadgeDeclined) {
      return (bg: AppColors.amberBackground, fg: AppColors.amberText);
    }
    return (bg: AppColors.infoBackground, fg: AppColors.infoText);
  }
}

/// Stage-specific sub-actions for the order timeline (payment, shipping,
/// clearance, repair, delivery, chat fallbacks). Used by the active row
/// and by the web order-detail right panel.
class OrderTimelineSubActionArea extends ConsumerWidget {
  final OrderTimelineModel stage;
  final String orderId;
  final OrderView order;
  final List<PaymentRequestModel> pendingPayments;
  final ShippingModel? shipping;
  final DutyClearanceModel? clearance;
  final RepairJobModel? repairJob;
  final VoidCallback? onChatTap;

  const OrderTimelineSubActionArea({
    super.key,
    required this.stage,
    required this.orderId,
    required this.order,
    required this.pendingPayments,
    this.shipping,
    this.clearance,
    this.repairJob,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stage.stageKey == 'preferences_submitted') {
      return const SizedBox.shrink();
    }

    if (stage.stageKey == 'agent_assigned') {
      return _AgentAssignedCard(order: order, onChatTap: onChatTap);
    }

    final pay = resolvePendingPaymentForStage(stage.stageKey, pendingPayments);
    if (pay != null) {
      final card = PaymentRequestCard(paymentRequest: pay, orderId: orderId);
      if (stage.stageKey == 'repair') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepairTimelinePaymentContext(payment: pay),
            card,
          ],
        );
      }
      return card;
    }

    switch (stage.stageKey) {
      case 'deposit_paid':
        if (order.firstPaymentMade) {
          return _PaidPill(
            label: OrderTimelineConstants.paidCheck,
            amountUsd: null,
          );
        }
        break;
      case 'vehicle_balance':
        if (_isPostVehicleBalancePaid(order.status)) {
          return const _PaidPill(
            label: 'Paid \u2714 \u2014 shipping being arranged',
          );
        }
        break;
      case 'shipping':
        final ship = shipping;
        if (ship != null) {
          return ShippingStatusCard(shipping: ship, orderId: orderId);
        }
        break;
      case 'clearance':
        final c = clearance;
        if (c != null) {
          return ClearanceStatusCard(
            clearance: c,
            orderId: orderId,
            onChatTap: onChatTap,
          );
        }
        return _chooseClearance(context, ref);
      case 'repair':
        return RepairStatusCard(
          orderId: orderId,
          repairJob: repairJob,
          pendingPayment: RepairTimelineResolver.pendingRepairPayment(
            pendingPayments,
          ),
        );
      case 'searching':
        if (!ref.watch(isOrderOnSearchingStepProvider(orderId))) {
          return _chatFallback(context, stage.stageKey);
        }
        final hasOptions = ref.watch(orderHasVehicleOptionsProvider(orderId));
        if (hasOptions) {
          return _ViewVehicleOptionsButton(orderId: orderId, order: order);
        }
        return _chatFallback(context, stage.stageKey);
      case 'delivery':
        if (order.status == FirestoreEnumValues.orderStatusDelivered) {
          return _DeliveredCard(orderId: orderId);
        }
        return _DeliveryActionCard(orderId: orderId);
    }

    return _chatFallback(context, stage.stageKey);
  }

  Widget _chooseClearance(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            OrderDetailWebNavigation.openClearance(context, ref, orderId),
        icon: const Icon(
          Icons.account_balance_outlined,
          size: 15,
          color: Color(_kPrimary),
        ),
        label: Text(
          OrderTimelineConstants.chooseClearance,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(_kPrimary),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(_kPrimary),
          side: const BorderSide(color: Color(_kPrimary), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(0, 44),
        ),
      ),
    );
  }

  Widget _chatFallback(BuildContext context, String stageKey) {
    String? sub;
    if (stageKey == 'searching') {
      sub = OrderTimelineConstants.searchingSubForOrder(
        purchaseOrigin: order.purchaseOrigin,
        isNewVehicle: order.isNewVehicle,
      );
    } else if (stageKey == 'delivery') {
      sub = OrderTimelineConstants.deliverySub;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sub != null) ...[
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(
              color: const Color(_kTextSecondary),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
        ],
        _buildChatButton(context, orderId, onChatTap),
      ],
    );
  }
}

class _ViewVehicleOptionsButton extends ConsumerWidget {
  const _ViewVehicleOptionsButton({
    required this.orderId,
    required this.order,
  });

  final String orderId;
  final OrderView order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options =
        ref.watch(orderVehicleOptionsProvider(orderId)).valueOrNull ?? const [];
    final pendingCount = ref.watch(pendingVehicleFeedbackCountProvider(orderId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          pendingCount > 0
              ? VehicleOptionConstants.homeStatusLine(pendingCount)
              : OrderTimelineConstants.searchingSubForOrder(
                  purchaseOrigin: order.purchaseOrigin,
                  isNewVehicle: order.isNewVehicle,
                ),
          style: AppTextStyles.caption.copyWith(
            color: pendingCount > 0
                ? AppColors.amberText
                : const Color(_kTextSecondary),
            height: 1.4,
            fontWeight:
                pendingCount > 0 ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => OrderDetailWebNavigation.openVehicleOptions(
              context,
              ref,
              orderId: orderId,
            ),
            icon: Icon(
              pendingCount > 0
                  ? Icons.notifications_active_outlined
                  : Icons.directions_car_outlined,
              size: 16,
            ),
            label: Text(
              VehicleOptionConstants.timelineButtonLabel(
                pendingCount,
                options.length,
              ),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(_kPrimary),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryActionCard extends ConsumerWidget {
  const _DeliveryActionCard({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(deliveryScreenStateProvider(orderId));
    final deliveryAsync = ref.watch(deliveryProvider(orderId));

    return deliveryAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (delivery) {
        switch (screenState) {
          // Should not appear on
          // timeline when not available
          case DeliveryScreenState.notAvailable:
            return const SizedBox.shrink();

          // Customer has not yet
          // chosen delivery method
          case DeliveryScreenState.choice:
            return _deliveryCard(
              context: context,
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.secondary,
              backgroundColor: AppColors.infoBackground,
              borderColor: AppColors.secondary.withValues(alpha: 0.3),
              message:
                  'Choose how you would '
                  'like to receive your '
                  'vehicle.',
              buttonLabel:
                  'Choose delivery '
                  'option →',
              buttonColor: AppColors.secondary,
              onTap: () =>
                  OrderDetailWebNavigation.openDelivery(context, ref, orderId),
            );

          // Waiting for payment
          // clearance from agent
          case DeliveryScreenState.awaitingPaymentClearance:
            final hasPending = delivery != null;
            return _deliveryCard(
              context: context,
              icon: Icons.hourglass_top_rounded,
              iconColor: AppColors.infoText,
              backgroundColor: AppColors.infoBackground,
              borderColor: AppColors.infoText.withValues(alpha: 0.3),
              message: hasPending
                  ? 'Complete your pending'
                        ' payments to proceed '
                        'with delivery.'
                  : 'Your agent is '
                        'reviewing your '
                        'payments. You will '
                        'be notified once '
                        'cleared.',
              buttonLabel: 'View payment details →',
              buttonColor: AppColors.secondary,
              onTap: () =>
                  OrderDetailWebNavigation.openDelivery(context, ref, orderId),
            );

          // Payments cleared — needs
          // delivery address
          case DeliveryScreenState.addressEntry:
            return _deliveryCard(
              context: context,
              icon: Icons.location_off_outlined,
              iconColor: AppColors.warning,
              backgroundColor: AppColors.amberBackground,
              borderColor: AppColors.warning.withValues(alpha: 0.4),
              message:
                  'Set your delivery '
                  'address so your agent '
                  'can arrange delivery.',
              buttonLabel: 'Set delivery address →',
              buttonColor: AppColors.secondary,
              onTap: () =>
                  OrderDetailWebNavigation.openDelivery(context, ref, orderId),
            );

          // Address set — waiting
          // for delivery
          case DeliveryScreenState.locationSet:
            final d = delivery;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successMutedBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.successMutedBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d?.locationLabel ??
                              d?.deliveryAddress ??
                              'Location saved',
                          style: AppTextStyles.cardLabel.copyWith(
                            color: AppColors.successMutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => OrderDetailWebNavigation.openDelivery(
                      context,
                      ref,
                      orderId,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Track delivery →',
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
              ],
            );

          // Self pickup — waiting
          // for collection details
          case DeliveryScreenState.selfPickup:
            final hasDetails = delivery?.hasCollectionDetails ?? false;
            return _deliveryCard(
              context: context,
              icon: hasDetails
                  ? Icons.location_on_rounded
                  : Icons.hourglass_top_rounded,
              iconColor: hasDetails
                  ? AppColors.secondary
                  : AppColors.textTertiary,
              backgroundColor: hasDetails
                  ? AppColors.infoBackground
                  : AppColors.surface,
              borderColor: hasDetails
                  ? AppColors.secondary.withValues(alpha: 0.3)
                  : AppColors.borderSolid,
              message: hasDetails
                  ? 'Collection point is '
                        'ready. Tap to get '
                        'directions.'
                  : 'Your agent is '
                        'preparing the '
                        'collection point '
                        'details.',
              buttonLabel: hasDetails
                  ? 'View collection '
                        'point →'
                  : 'View details →',
              buttonColor: AppColors.secondary,
              onTap: () =>
                  OrderDetailWebNavigation.openDelivery(context, ref, orderId),
            );

          // Delivery confirmed
          case DeliveryScreenState.confirmed:
            return _DeliveredCard(orderId: orderId);
        }
      },
    );
  }

  Widget _deliveryCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String message,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: borderColor, width: 3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.cardLabel.copyWith(
                    color: iconColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(buttonLabel, style: AppTextStyles.buttonMedium),
          ),
        ),
      ],
    );
  }
}

Widget _buildChatButton(
  BuildContext context,
  String orderId,
  VoidCallback? onChatTap,
) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onChatTap,
      icon: const Icon(
        Icons.chat_bubble_outline_rounded,
        size: 15,
        color: Color(_kPrimary),
      ),
      label: Text(
        OrderTimelineConstants.chatWithAgent,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(_kPrimary),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(_kPrimary),
        side: const BorderSide(color: Color(_kPrimary), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
      ),
    ),
  );
}

class _DeliveredCard extends ConsumerWidget {
  final String orderId;

  const _DeliveredCard({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(_kSuccess).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(_kSuccess),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrderTimelineConstants.deliveredTitle,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(_kDeliveredGreen),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      OrderTimelineConstants.deliveredThanks,
                      style: AppTextStyles.cardLabel.copyWith(
                        color: const Color(_kDeliveredSub),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Builder(
            builder: (ctx) {
              final userId = ref.watch(authStateProvider).value;
              if (userId == null) {
                return const SizedBox.shrink();
              }
              final reviewAsync = ref.watch(
                buyerReviewProvider((orderId: orderId, buyerId: userId)),
              );
              final review = reviewAsync.valueOrNull;

              if (review != null) {
                return _SubmittedReviewCard(review: review, orderId: orderId);
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      OrderDetailWebNavigation.openReview(context, ref, orderId),
                  icon: const Icon(
                    Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    OrderTimelineConstants.rateExperience,
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(_kSuccess),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubmittedReviewCard extends ConsumerWidget {
  final BuyerReviewModel review;
  final String orderId;

  const _SubmittedReviewCard({required this.review, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = review.overallRating.round().clamp(1, 5);

    return InkWell(
      onTap: () => OrderDetailWebNavigation.openReview(context, ref, orderId),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successMutedBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.successMutedBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You rated this experience',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.successMutedForeground,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: i < stars
                      ? const Color(0xFFFFB800)
                      : AppColors.borderSolid,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'View →',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentAssignedCard extends ConsumerWidget {
  final OrderView order;
  final VoidCallback? onChatTap;

  const _AgentAssignedCard({required this.order, this.onChatTap});

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) {
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentId = order.agentId;

    if (agentId == null) {
      return _AgentPendingCard(orderId: order.id);
    }

    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      loading: () => const _AgentCardShimmer(),
      error: (_, __) => _AgentPendingCard(orderId: order.id),
      data: (agent) {
        if (agent == null) {
          return _AgentPendingCard(orderId: order.id);
        }

        return _AgentDetailCard(
          agent: agent,
          onChatTap: onChatTap,
          onCallTap: agent.phone != null ? () => _call(agent.phone) : null,
        );
      },
    );
  }
}

class _AgentPendingCard extends StatelessWidget {
  final String orderId;

  const _AgentPendingCard({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finding your agent',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13.5,
                        color: AppColors.infoText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'This usually takes a few minutes.',
                      style: AppTextStyles.cardLabel.copyWith(
                        color: AppColors.infoText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => SupportBottomSheet.show(context),
              icon: const Icon(
                Icons.headset_mic_rounded,
                size: 15,
                color: AppColors.secondary,
              ),
              label: Text(
                'Contact support',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary, width: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentDetailCard extends StatelessWidget {
  final AgentDetailView agent;
  final VoidCallback? onChatTap;
  final VoidCallback? onCallTap;

  const _AgentDetailCard({required this.agent, this.onChatTap, this.onCallTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSolid, width: 0.5),
                ),
                child: ClipOval(
                  child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: agent.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              _AgentInitials(name: agent.fullName),
                          errorWidget: (_, __, ___) =>
                              _AgentInitials(name: agent.fullName),
                        )
                      : _AgentInitials(name: agent.fullName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.fullName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          agent.rating.toStringAsFixed(1),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${agent.totalOrdersCompleted} orders',
                          style: AppTextStyles.cardLabel.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (agent.introMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${agent.introMessage}"',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onChatTap,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Chat',
                      style: AppTextStyles.buttonLarge.copyWith(fontSize: 13.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              if (onCallTap != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onCallTap,
                      icon: const Icon(
                        Icons.call_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      label: Text(
                        'Call',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(
                          color: AppColors.secondary,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentInitials extends StatelessWidget {
  final String name;

  const _AgentInitials({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.infoBackground,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _AgentCardShimmer extends StatelessWidget {
  const _AgentCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Paid confirmation pill that shows the amount in the customer's
/// preferred currency when [amountUsd] is provided.
class _PaidPill extends ConsumerWidget {
  final String label;
  final double? amountUsd;

  const _PaidPill({required this.label, this.amountUsd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var displayText = label;

    if (amountUsd != null && amountUsd! > 0) {
      final currency = ref.watch(preferredCurrencyProvider);
      final display = CurrencyFormatter.formatForDisplay(
        usdAmount: amountUsd!,
        preferredCurrency: currency,
      );
      displayText = 'Paid ${display.primary} ✓';
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(_kSuccess).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: Color(_kSuccess),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              displayText,
              style: AppTextStyles.cardValue.copyWith(
                color: const Color(_kSuccess),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
