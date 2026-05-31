import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../../data/models/order_timeline_model.dart';
import '../providers/order_providers.dart';
import '../providers/order_timeline_providers.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../utils/repair_timeline_resolver.dart';
import 'order_timeline_step_row.dart';

/// Firestore-driven order journey timeline with staggered entrance.
class OrderTimelineWidget extends ConsumerStatefulWidget {
  final String orderId;
  final OrderView order;
  final bool suppressStageCoachMarks;
  final VoidCallback? onChatTap;
  final void Function(String stageKey)? onStepTapped;

  const OrderTimelineWidget({
    super.key,
    required this.orderId,
    required this.order,
    this.suppressStageCoachMarks = false,
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
  String? _stageCoachGuideKey;
  bool _showStageCoach = false;
  int? _stageCoachCheckedForStage;

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
      _stageCoachCheckedForStage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideStageCoach();
      });
    }
    if (oldWidget.order.stageNumber != widget.order.stageNumber) {
      _stageCoachCheckedForStage = null;
      if (_showStageCoach) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _hideStageCoach();
        });
      }
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
    if (oldWidget.suppressStageCoachMarks != widget.suppressStageCoachMarks &&
        widget.suppressStageCoachMarks &&
        _showStageCoach) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideStageCoach();
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
    if (order.repairOptedIn) return raw;
    return raw.where((s) => s.stageKey != 'repair').toList();
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

  String? _guideKeyForStageNumber(int stageNumber) {
    switch (stageNumber) {
      case 4:
        return GuideKeys.stageSearching;
      case 5:
        return GuideKeys.stageBid;
      case 6:
        return GuideKeys.stageShipping;
      case 7:
        return GuideKeys.stageClearance;
      case 8:
        return GuideKeys.stageRepair;
      default:
        return null;
    }
  }

  Future<void> _checkStageCoach(String? guideKey) async {
    if (guideKey == null || widget.suppressStageCoachMarks || !mounted) {
      return;
    }
    final seen = await ref.read(hasSeenGuideProvider(guideKey).future);
    if (!seen && mounted) {
      setState(() {
        _stageCoachGuideKey = guideKey;
        _showStageCoach = true;
      });
    }
  }

  void _hideStageCoach() {
    if (mounted) {
      setState(() {
        _showStageCoach = false;
        _stageCoachGuideKey = null;
      });
    }
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

  void _scheduleStageCoachIfNeeded() {
    final sn = widget.order.stageNumber;
    if (_stageCoachCheckedForStage == sn) return;
    final key = _guideKeyForStageNumber(sn);
    if (key == null) {
      _stageCoachCheckedForStage = sn;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.suppressStageCoachMarks) return;
      if (_stageCoachCheckedForStage == sn) return;
      _stageCoachCheckedForStage = sn;
      await _checkStageCoach(key);
    });
  }

  Widget _buildStageCoachOverlay(String guideKey) {
    late final String title;
    late final String body;
    switch (guideKey) {
      case GuideKeys.stageSearching:
        title = 'Your agent is searching now';
        body =
            'Your agent is actively searching '
            'auctions for your vehicle. You\'ll '
            'get notified the moment options arrive.';
        break;
      case GuideKeys.stageBid:
        title = 'Vehicle secured';
        body =
            'Your agent secured your vehicle. '
            'Review the payment request to '
            'move to the next step.';
        break;
      case GuideKeys.stageShipping:
        title = 'Your car is on its way';
        body =
            'Your vehicle is being shipped to '
            'Ghana. Tap the shipping stage to '
            'track its journey.';
        break;
      case GuideKeys.stageClearance:
        title = 'Port clearance in progress';
        body =
            'Your agent is handling all GRA '
            'paperwork and duty on your behalf. '
            'We\'ll keep you updated at every step.';
        break;
      case GuideKeys.stageRepair:
        title = 'Review your repair quote';
        body =
            'When your agent sends a repair quote, '
            'review it here before approving. '
            'No work begins until you say yes.';
        break;
      default:
        title = '';
        body = '';
    }
    return CoachMarkOverlay(
      guideKey: guideKey,
      targetKey: _activeStageKey,
      title: title,
      body: body,
      spotlightShape: SpotlightShape.roundedRect,
      onDismiss: _hideStageCoach,
      onFaqTap: () {
        _hideStageCoach();
        GuideFaqSheet.show(context);
      },
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

        _scheduleStageCoachIfNeeded();

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

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
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
            ),
            if (_showStageCoach &&
                _stageCoachGuideKey != null &&
                !widget.suppressStageCoachMarks)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return OverflowBox(
                      minWidth: constraints.maxWidth,
                      maxWidth: constraints.maxWidth,
                      minHeight: MediaQuery.sizeOf(context).height,
                      maxHeight: MediaQuery.sizeOf(context).height,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: MediaQuery.sizeOf(context).height,
                        child: _buildStageCoachOverlay(_stageCoachGuideKey!),
                      ),
                    );
                  },
                ),
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
