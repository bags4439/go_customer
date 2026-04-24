import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
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
import '../providers/order_providers.dart';
import '../utils/timeline_payment_resolver.dart';
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageNumber = stage.stageNumber;
    final orderStageNumber = order.stageNumber;
    final isComplete = stageNumber < orderStageNumber;
    final isActive = stageNumber == orderStageNumber;

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
            child: Container(
              width: 1.5,
              color: lineColor,
            ),
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
                padding: const EdgeInsets.only(
                  right: 16,
                  bottom: 8,
                ),
                child: isComplete
                    ? _CompletedRow(
                        stage: stage,
                        isLast: isLast,
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
                          )
                        : _UpcomingRow(
                            stage: stage,
                            isLast: isLast,
                          ),
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
        child: Icon(
          Icons.check_rounded,
          size: 12,
          color: Colors.white,
        ),
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
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
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
        border: Border.all(
          color: AppColors.borderSolid,
          width: 1.5,
        ),
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  final OrderTimelineModel stage;
  final bool isLast;

  const _CompletedRow({
    required this.stage,
    required this.isLast,
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
  Widget build(BuildContext context) {
    final dateStr = _formatDate(stage.completedAt);

    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: isLast ? 4 : 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              stage.label,
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (dateStr.isNotEmpty)
            Text(
              dateStr,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final OrderTimelineModel stage;
  final bool isLast;

  const _UpcomingRow({
    required this.stage,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: isLast ? 4 : 0,
      ),
      child: Text(
        stage.label,
        style: GoogleFonts.dmSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        bottom: 12,
      ),
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
                  child: Text(
                    stage.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
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
                    'In progress',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.infoText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (stage.detail != null && stage.detail!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                stage.detail!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
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
            child: _SubActionArea(
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
}

class _SubActionArea extends StatelessWidget {
  final OrderTimelineModel stage;
  final String orderId;
  final OrderView order;
  final List<PaymentRequestModel> pendingPayments;
  final ShippingModel? shipping;
  final DutyClearanceModel? clearance;
  final RepairJobModel? repairJob;
  final VoidCallback? onChatTap;

  const _SubActionArea({
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
  Widget build(BuildContext context) {
    if (stage.stageKey == 'preferences_submitted') {
      return const SizedBox.shrink();
    }

    if (stage.stageKey == 'agent_assigned') {
      return _AgentAssignedCard(
        order: order,
        onChatTap: onChatTap,
      );
    }

    final pay = resolvePendingPaymentForStage(stage.stageKey, pendingPayments);
    if (pay != null) {
      return PaymentRequestCard(paymentRequest: pay, orderId: orderId);
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
        return _chooseClearance(context);
      case 'repair':
        final job = repairJob;
        return RepairStatusCard(orderId: orderId, repairJob: job);
      case 'delivery':
        if (order.status == FirestoreEnumValues.orderStatusDelivered) {
          return _DeliveredCard(orderId: orderId);
        }
        return _DeliveryActionCard(orderId: orderId);
    }

    return _chatFallback(context, stage.stageKey);
  }

  Widget _chooseClearance(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push('/order/$orderId/clearance'),
        icon: const Icon(
          Icons.account_balance_outlined,
          size: 15,
          color: Color(_kPrimary),
        ),
        label: Text(
          OrderTimelineConstants.chooseClearance,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(_kPrimary),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(_kPrimary),
          side: const BorderSide(color: Color(_kPrimary), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            style: GoogleFonts.dmSans(
              fontSize: 11,
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

class _DeliveryActionCard extends ConsumerWidget {
  const _DeliveryActionCard({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        if (delivery?.isConfirmed == true) {
          return _DeliveredCard(orderId: orderId);
        }

        if (delivery?.hasLocation == true) {
          final d = delivery!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successMutedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.locationLabel ??
                            d.deliveryAddress ??
                            'Location saved',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF1A4731),
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
                  onPressed: () => context.push('/order/$orderId/delivery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirm vehicle receipt →',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amberBackground,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: AppColors.warning, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 18,
                    color: AppColors.amberText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your agent needs your delivery location to proceed.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.amberText,
                        height: 1.35,
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
                onPressed: () => context.push('/order/$orderId/delivery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Set delivery location →',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(_kPrimary),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(_kPrimary),
        side: const BorderSide(color: Color(_kPrimary), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class _DeliveredCard extends ConsumerWidget {
  final String orderId;

  const _DeliveredCard({required this.orderId});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
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
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(_kDeliveredGreen),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      OrderTimelineConstants.deliveredThanks,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
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
                buyerReviewProvider((
                  orderId: orderId,
                  buyerId: userId,
                )),
              );
              final review = reviewAsync.valueOrNull;

              if (review != null) {
                return _SubmittedReviewCard(
                  review: review,
                  orderId: orderId,
                );
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/order/$orderId/review'),
                  icon: const Icon(
                    Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    OrderTimelineConstants.rateExperience,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(_kSuccess),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

class _SubmittedReviewCard extends StatelessWidget {
  final BuyerReviewModel review;
  final String orderId;

  const _SubmittedReviewCard({
    required this.review,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final stars =
        review.overallRating.round().clamp(1, 5);

    return InkWell(
      onTap: () => context.push('/order/$orderId/review'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
              Icons.check_circle_rounded,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You rated this experience',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
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
                  i < stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
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
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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

  const _AgentAssignedCard({
    required this.order,
    this.onChatTap,
  });

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
      return _AgentPendingCard(
        orderId: order.id,
      );
    }

    final agentAsync = ref.watch(
      agentDetailProvider(agentId),
    );

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
          onCallTap: agent.phone != null
              ? () => _call(agent.phone)
              : null,
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
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.infoText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'This usually takes a few minutes.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
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
                style: GoogleFonts.dmSans(
                  fontSize: 13,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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

  const _AgentDetailCard({
    required this.agent,
    this.onChatTap,
    this.onCallTap,
  });

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
                  border: Border.all(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                child: ClipOval(
                  child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: agent.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _AgentInitials(
                            name: agent.fullName,
                          ),
                          errorWidget: (_, __, ___) => _AgentInitials(
                            name: agent.fullName,
                          ),
                        )
                      : _AgentInitials(
                          name: agent.fullName,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.fullName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
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
                style: GoogleFonts.dmSans(
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
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                        style: GoogleFonts.dmSans(
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.infoBackground,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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

  const _PaidPill({
    required this.label,
    this.amountUsd,
  });

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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
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
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(_kSuccess),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
