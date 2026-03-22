import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _StepDot(stage: stage),
                if (!isLast)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: 2,
                      color: lineAfterIsComplete
                          ? const Color(_kSuccess)
                          : const Color(_kBorder),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12, bottom: isLast ? 0 : 32),
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
                            fontSize: stage.isActive ? 14 : 13,
                            fontWeight: stage.isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: stage.isActive
                                ? Colors.black87
                                : const Color(_kTextSecondary),
                          ),
                        ),
                      ),
                      if (stage.completedAt != null)
                        Text(
                          DateFormatter.formatRelative(stage.completedAt!),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(_kTextTertiary),
                          ),
                        ),
                    ],
                  ),
                  if (stage.detail != null &&
                      stage.detail!.isNotEmpty &&
                      stage.isActive) ...[
                    const SizedBox(height: 3),
                    Text(
                      stage.detail!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(_kTextSecondary),
                      ),
                    ),
                  ],
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: stage.isActive
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
  }
}

class _StepDot extends StatelessWidget {
  final OrderTimelineModel stage;

  const _StepDot({required this.stage});

  @override
  Widget build(BuildContext context) {
    if (stage.isBlocked) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(_kSurface),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(_kBorder)),
        ),
        child: const Icon(Icons.lock_outline, size: 10, color: Color(_kTextTertiary)),
      );
    }
    if (stage.isComplete) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(_kSuccess),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x301D9E75),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }
    if (stage.isActive) {
      return _PulsingActiveDot(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(_kPrimary),
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(_kBorder)),
      ),
      alignment: Alignment.center,
      child: Text(
        '${stage.stageNumber}',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
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

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.4).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: widget.child,
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

  const _SubActionArea({
    required this.stage,
    required this.orderId,
    required this.order,
    required this.pendingPayments,
    this.shipping,
    this.clearance,
    this.repairJob,
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
          return ShippingStatusCard(shipping: ship);
        }
        break;
      case 'clearance':
        final c = clearance;
        if (c != null) {
          return ClearanceStatusCard(
            clearance: c,
            orderId: orderId,
          );
        }
        return _chooseClearance(context);
      case 'repair':
        final job = repairJob;
        if (job != null) {
          return RepairStatusCard(repairJob: job);
        }
        break;
      case 'delivery':
        if (order.status == FirestoreEnumValues.orderStatusDelivered) {
          return _DeliveredCard(orderId: orderId);
        }
        break;
    }

    return _chatFallback(context, stage.stageKey);
  }

  Widget _paidPill(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(_kSuccess),
        ),
      ),
    );
  }

  Widget _chooseClearance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        onPressed: () => context.push('/order/$orderId/clearance'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(_kPrimary),
          side: const BorderSide(color: Color(_kPrimary), width: 0.5),
          minimumSize: const Size(0, 48),
        ),
        child: Text(
          OrderTimelineConstants.chooseClearance,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _chatFallback(BuildContext context, String stageKey) {
    String? sub;
    if (stageKey == 'searching') {
      sub = OrderTimelineConstants.searchingSub;
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
        _buildChatButton(context, orderId),
      ],
    );
  }
}

Widget _buildChatButton(BuildContext context, String orderId) {
  return OutlinedButton.icon(
    onPressed: () => context.push('/order/$orderId?tab=chat'),
    icon: const Icon(Icons.chat_bubble_outline,
        size: 14, color: Color(_kPrimary)),
    label: Text(
      OrderTimelineConstants.chatWithAgent,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(_kPrimary),
      ),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(_kPrimary), width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(0, 48),
    ),
  );
}

class _DeliveredCard extends StatelessWidget {
  final String orderId;

  const _DeliveredCard({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(_kSuccess), width: 3),
        ),
      ),
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
          const SizedBox(height: 4),
          Text(
            OrderTimelineConstants.deliveredThanks,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(_kDeliveredSub),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/order/$orderId/review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(_kSuccess),
                side: const BorderSide(color: Color(_kSuccess)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                OrderTimelineConstants.rateExperience,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
