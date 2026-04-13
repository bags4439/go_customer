import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
import 'order_timeline_step_row.dart';

/// Firestore-driven order journey timeline with staggered entrance.
class OrderTimelineWidget extends ConsumerStatefulWidget {
  final String orderId;
  final OrderView order;
  final bool suppressStageCoachMarks;
  final VoidCallback? onChatTap;

  const OrderTimelineWidget({
    super.key,
    required this.orderId,
    required this.order,
    this.suppressStageCoachMarks = false,
    this.onChatTap,
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
    bool repairOptedIn,
  ) {
    return raw.where((s) {
      if (s.stageKey == 'repair') {
        return repairOptedIn;
      }
      return true;
    }).toList();
  }

  void _ensureEntranceStarted(int count) {
    if (count == 0 || _entranceStarted) return;
    _entranceStarted = true;
    _entrance.duration = Duration(milliseconds: 40 * (count - 1) + 200);
    _entrance.forward(from: 0);
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
      default:
        return null;
    }
  }

  Future<void> _checkStageCoach(String? guideKey) async {
    if (guideKey == null ||
        widget.suppressStageCoachMarks ||
        !mounted) {
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
        body = 'Your agent is actively searching '
            'auctions for your vehicle. You\'ll '
            'get notified the moment options arrive.';
        break;
      case GuideKeys.stageBid:
        title = 'Vehicle secured';
        body = 'Your agent secured your vehicle. '
            'Review the payment request to '
            'move to the next step.';
        break;
      case GuideKeys.stageShipping:
        title = 'Your car is on its way';
        body = 'Your vehicle is being shipped to '
            'Ghana. Tap the shipping stage to '
            'track its journey.';
        break;
      case GuideKeys.stageClearance:
        title = 'Port clearance in progress';
        body = 'Your agent is handling all GRA '
            'paperwork and duty on your behalf. '
            'We\'ll keep you updated at every step.';
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
        final repairOptedIn = widget.order.repairOptedIn;
        final visible = _visibleStages(stages, repairOptedIn);

        if (pendingAsync.isLoading ||
            shippingAsync.isLoading ||
            clearanceAsync.isLoading ||
            repairAsync.isLoading) {
          return _TimelineShimmer();
        }

        final pending = pendingAsync.valueOrNull ?? [];
        final shipping = shippingAsync.valueOrNull;
        final clearance = clearanceAsync.valueOrNull;
        final repairJob = repairAsync.valueOrNull;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ensureEntranceStarted(visible.length);
        });

        _scheduleStageCoachIfNeeded();

        Widget rowContent(OrderTimelineModel s, bool isLast) {
          final row = OrderTimelineStepRow(
            stage: s,
            orderId: widget.orderId,
            order: widget.order,
            isLast: isLast,
            lineAfterIsComplete: s.stageNumber < widget.order.stageNumber,
            pendingPayments: pending,
            shipping: shipping,
            clearance: clearance,
            repairJob: repairJob,
            onChatTap: widget.onChatTap,
          );
          final isActive = s.stageNumber == widget.order.stageNumber;
          if (isActive) {
            return KeyedSubtree(
              key: _activeStageKey,
              child: row,
            );
          }
          return row;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _entrance,
              builder: (context, _) {
                final totalMs =
                    (40 * (visible.length - 1) + 200).clamp(200, 10000);
                final tGlobal = _entrance.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(visible.length, (i) {
                    final s = visible[i];
                    final start = (i * 40.0) / totalMs;
                    final end = (i * 40.0 + 200) / totalMs;
                    double local;
                    if (end <= start) {
                      local = tGlobal >= 1 ? 1 : 0;
                    } else {
                      local = ((tGlobal - start) / (end - start))
                          .clamp(0.0, 1.0);
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
                );
              },
            ),
            if (_showStageCoach &&
                _stageCoachGuideKey != null &&
                !widget.suppressStageCoachMarks)
              _buildStageCoachOverlay(_stageCoachGuideKey!),
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
        children: List.generate(6, (i) {
          final isActive = i == 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
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
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
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
              style: GoogleFonts.dmSans(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                OrderTimelineConstants.retry,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
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
