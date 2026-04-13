import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../delivery/presentation/providers/delivery_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../payments/presentation/widgets/payment_request_card.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../data/models/order_timeline_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../providers/order_providers.dart';
import '../utils/timeline_payment_resolver.dart';
import 'clearance_status_card.dart';
import 'repair_status_card.dart';
import 'shipping_status_card.dart';

const _kSurface = 0xFFF5F4F0;
const _kBorder = 0xFFE0DFD8;
const _kPrimary = 0xFF378ADD;
const _kSuccess = 0xFF1D9E75;
const _kTextTertiary = 0xFFAAAAAA;
const _kTextSecondary = 0xFF666666;
const _kTextPrimary = 0xFF1A1A18;
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
class OrderTimelineStepRow extends StatelessWidget {
  final OrderTimelineModel stage;
  final String orderId;
  final OrderView order;
  final bool isLast;
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
  Widget build(BuildContext context) {
    final isStageComplete = stage.stageNumber < order.stageNumber;
    final isStageActive = stage.stageNumber == order.stageNumber;

    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                _StepDot(stage: stage, orderStageNumber: order.stageNumber),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: 2,
                        decoration: BoxDecoration(
                          color: lineAfterIsComplete
                              ? const Color(_kSuccess)
                              : const Color(_kBorder),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 14,
                bottom: isStageActive ? 0 : (isLast ? 0 : 36),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          stage.label,
                          style: GoogleFonts.dmSans(
                            fontSize: isStageActive ? 15 : 13,
                            fontWeight: isStageActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isStageActive
                                ? const Color(_kTextPrimary)
                                : const Color(_kTextSecondary),
                          ),
                        ),
                      ),
                      if (isStageComplete && stage.completedAt != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 10,
                              color: Color(_kSuccess),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              DateFormatter.formatRelative(stage.completedAt!),
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: const Color(_kSuccess),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (stage.detail != null &&
                      stage.detail!.isNotEmpty &&
                      isStageActive) ...[
                    const SizedBox(height: 3),
                    Text(
                      stage.detail!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(_kTextSecondary),
                        height: 1.5,
                      ),
                    ),
                  ],
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: isStageActive
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
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
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isStageActive) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF4FD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(_kPrimary).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: row,
      );
    }

    return row;
  }
}

class _StepDot extends StatelessWidget {
  final OrderTimelineModel stage;
  final int orderStageNumber;

  const _StepDot({required this.stage, required this.orderStageNumber});

  @override
  Widget build(BuildContext context) {
    final isComplete = stage.stageNumber < orderStageNumber;
    final isActive = stage.stageNumber == orderStageNumber;
    final isLocked = stage.stageNumber > orderStageNumber;

    if (isLocked) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(_kSurface),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(_kBorder), width: 1.5),
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: Color(_kTextTertiary),
        ),
      );
    }
    if (isComplete) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(_kSuccess),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(_kSuccess).withValues(alpha: 0.30),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      );
    }
    if (isActive) {
      return const _PulsingActiveDot(child: SizedBox.shrink());
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(_kBorder), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '${stage.stageNumber}',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(_kTextTertiary),
        ),
      ),
    );
  }
}

class _PulsingActiveDot extends StatefulWidget {
  final Widget child;

  const _PulsingActiveDot({required this.child});

  @override
  State<_PulsingActiveDot> createState() => _PulsingActiveDotState();
}

class _PulsingActiveDotState extends State<_PulsingActiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _ring;
  late Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _ring = Tween<double>(
      begin: 0.6,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.scale(
              scale: _ring.value,
              child: Opacity(
                opacity: _ringOpacity.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(_kPrimary), width: 2),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(_kPrimary),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radio_button_checked_rounded,
              size: 14,
              color: Colors.white,
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

    final pay = resolvePendingPaymentForStage(stage.stageKey, pendingPayments);
    if (pay != null) {
      return PaymentRequestCard(paymentRequest: pay, orderId: orderId);
    }

    switch (stage.stageKey) {
      case 'deposit_paid':
        if (order.firstPaymentMade) {
          return _paidPill(OrderTimelineConstants.paidCheck);
        }
        break;
      case 'vehicle_balance':
        if (_isPostVehicleBalancePaid(order.status)) {
          return _paidPill(OrderTimelineConstants.paidShippingArranged);
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

  Widget _paidPill(String text) {
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
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(_kSuccess),
            ),
          ),
        ],
      ),
    );
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
