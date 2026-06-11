import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../../data/models/order_timeline_model.dart';
import '../providers/order_providers.dart';
import '../providers/order_timeline_providers.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../utils/active_order_stage.dart';
import '../utils/repair_timeline_resolver.dart';
import 'order_timeline_step_row.dart';

/// Firestore-driven order journey timeline with staggered entrance.
class OrderTimelineWidget extends ConsumerStatefulWidget {
  final String orderId;
  final OrderView order;
  final VoidCallback? onChatTap;
  final void Function(String stageKey)? onStepTapped;

  const OrderTimelineWidget({
    super.key,
    required this.orderId,
    required this.order,
    this.onChatTap,
    this.onStepTapped,
  });

  @override
  ConsumerState<OrderTimelineWidget> createState() =>
      _OrderTimelineWidgetState();
}

class _OrderTimelineWidgetState extends ConsumerState<OrderTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entrance;
  bool _entranceStarted = false;
  final GlobalKey _activeStageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(OrderTimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _entranceStarted = false;
      _entrance.reset();
    }
    if (oldWidget.order.stageNumber != widget.order.stageNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _scrollToActiveStage();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<OrderTimelineModel> _visibleStages(
    List<OrderTimelineModel> raw,
    OrderView order,
    RepairJobModel? repairJob,
  ) {
    return visibleTimelineStages(raw, order, repairJob);
  }

  void _ensureEntranceStarted(int count) {
    if (count == 0 || _entranceStarted) return;
    _entranceStarted = true;
    _entrance.duration = Duration(milliseconds: 40 * (count - 1) + 200);
    _entrance.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _scrollToActiveStage();
    });
  }

  void _scrollToActiveStage() {
    final ctx = _activeStageKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  String _resolveStatusLine({
    required OrderTimelineModel activeStage,
    required RepairJobModel? repairJob,
    required List<PaymentRequestModel> pending,
    required int stageNumber,
    required int totalStages,
  }) {
    if (activeStage.stageKey == 'repair') {
      return RepairTimelineResolver.summaryDetail(
        repairJob,
        pendingPayment: RepairTimelineResolver.pendingRepairPayment(pending),
      );
    }
    if (activeStage.detail?.isNotEmpty == true) {
      return activeStage.detail!;
    }
    return 'Step $stageNumber of $totalStages';
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(orderTimelineProvider(widget.orderId));
    final pendingAsync = ref.watch(
      pendingPaymentRequestsProvider(widget.orderId),
    );
    final shippingAsync = ref.watch(orderShippingProvider(widget.orderId));
    final clearanceAsync = ref.watch(orderClearanceProvider(widget.orderId));
    final repairAsync = ref.watch(orderRepairJobProvider(widget.orderId));

    return timelineAsync.when(
      data: (stages) {
        final repairJob = repairAsync.valueOrNull;
        final visible = _visibleStages(stages, widget.order, repairJob);

        if (pendingAsync.isLoading ||
            shippingAsync.isLoading ||
            clearanceAsync.isLoading) {
          return _TimelineShimmer();
        }

        final pending = pendingAsync.valueOrNull ?? [];
        final shipping = shippingAsync.valueOrNull;
        final clearance = clearanceAsync.valueOrNull;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ensureEntranceStarted(visible.length);
        });

        final activeStage = visible.isEmpty
            ? null
            : visible.firstWhere(
                (s) => s.stageNumber == widget.order.stageNumber,
                orElse: () => visible.last,
              );

        final stageName = activeStage?.label ?? '';

        final statusLine = activeStage == null
            ? ''
            : _resolveStatusLine(
                activeStage: activeStage,
                repairJob: repairJob,
                pending: pending,
                stageNumber: widget.order.stageNumber,
                totalStages: visible.length,
              );

        Widget rowContent(OrderTimelineModel s, bool isLast) {
          final deliveryComplete = s.stageKey == 'delivery' &&
              (s.completedAt != null ||
                  widget.order.status ==
                      AppConstants.statusDeliveryConfirmed ||
                  widget.order.status == AppConstants.statusDelivered);
          final stageComplete =
              s.stageNumber < widget.order.stageNumber || deliveryComplete;

          final row = OrderTimelineStepRow(
            stage: s,
            orderId: widget.orderId,
            order: widget.order,
            isLast: isLast,
            lineAfterIsComplete: stageComplete,
            pendingPayments: pending,
            shipping: shipping,
            clearance: clearance,
            repairJob: repairJob,
            onChatTap: widget.onChatTap,
            onStepTapped: widget.onStepTapped,
          );
          final isActive = s.stageNumber == widget.order.stageNumber;
          if (isActive) {
            return KeyedSubtree(key: _activeStageKey, child: row);
          }
          return row;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                if (visible.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SummaryCard(
                    stageNumber: widget.order.stageNumber,
                    totalStages: visible.length,
                    stageName: stageName,
                    statusLine: statusLine,
                    isComplete:
                        (activeStage?.stageNumber ?? 0) ==
                        widget.order.stageNumber,
                  ),
                  const SizedBox(height: 12),
                ],
                AnimatedBuilder(
                  animation: _entrance,
                  builder: (context, _) {
                    final totalMs = (40 * (visible.length - 1) + 200).clamp(
                      200,
                      10000,
                    );
                    final tGlobal = _entrance.value;

                    return Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(visible.length, (i) {
                          final s = visible[i];
                          final start = (i * 40.0) / totalMs;
                          final end = (i * 40.0 + 200) / totalMs;
                          double local;
                          if (end <= start) {
                            local = tGlobal >= 1 ? 1 : 0;
                          } else {
                            local = ((tGlobal - start) / (end - start)).clamp(
                              0.0,
                              1.0,
                            );
                          }
                          local = Curves.easeOut.transform(local);
                          final isLast = i == visible.length - 1;

                          return Opacity(
                            opacity: local,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - local)),
                              child: rowContent(s, isLast),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
          ],
        );
      },
      loading: () => _TimelineShimmer(),
      error: (_, __) => _TimelineError(
        onRetry: () {
          ref.invalidate(orderTimelineProvider(widget.orderId));
          ref.invalidate(orderProvider(widget.orderId));
          ref.invalidate(pendingPaymentRequestsProvider(widget.orderId));
          ref.invalidate(orderShippingProvider(widget.orderId));
          ref.invalidate(orderClearanceProvider(widget.orderId));
          ref.invalidate(orderRepairJobProvider(widget.orderId));
        },
      ),
    );
  }
}

class _TimelineShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          ...List.generate(5, (i) {
            final isActive = i == 1;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isActive)
                        Container(
                          width: 1.5,
                          height: 32,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 13,
                            width: isActive ? 160 : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineError extends StatelessWidget {
  final VoidCallback onRetry;

  const _TimelineError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF5F4F0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              OrderTimelineConstants.loadError,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                OrderTimelineConstants.retry,
                style: AppTextStyles.labelLarge.copyWith(
                  color: const Color(0xFF378ADD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top summary card — ring + stage name + status + segmented bar.
class _SummaryCard extends StatelessWidget {
  final int stageNumber;
  final int totalStages;
  final String stageName;
  final String statusLine;
  final bool isComplete;

  const _SummaryCard({
    required this.stageNumber,
    required this.totalStages,
    required this.stageName,
    required this.statusLine,
    this.isComplete = false,
  });

  double get _pct {
    if (totalStages <= 1) return 1.0;
    return ((stageNumber - 1) / (totalStages - 1)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final pctLabel = '${(_pct * 100).round()}%';
    const size = 68.0;
    const stroke = 5.0;
    const radius = (size / 2) - stroke;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: _pct,
                    radius: radius,
                    stroke: stroke,
                    isComplete: isComplete,
                  ),
                  child: Center(
                    child: Text(pctLabel, style: AppTextStyles.labelLarge),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Import progress', style: AppTextStyles.caption),
                    const SizedBox(height: 3),
                    Text(
                      stageName,
                      style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusLine,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(totalStages, (i) {
              final n = i + 1;
              Color fill;
              if (n < stageNumber || (n == stageNumber && isComplete)) {
                fill = AppColors.success;
              } else if (n == stageNumber) {
                fill = AppColors.secondary;
              } else {
                fill = AppColors.borderSolid;
              }
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < totalStages - 1 ? 2 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double stroke;
  final bool isComplete;

  const _RingPainter({
    required this.progress,
    required this.radius,
    required this.stroke,
    this.isComplete = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = AppColors.borderSolid
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = isComplete ? AppColors.success : AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isComplete != isComplete;
}
