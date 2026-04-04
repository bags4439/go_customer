import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../../data/models/order_timeline_model.dart';
import '../providers/order_providers.dart';
import '../providers/order_timeline_providers.dart';
import 'order_timeline_step_row.dart';

/// Firestore-driven order journey timeline with staggered entrance.
class OrderTimelineWidget extends ConsumerStatefulWidget {
  final String orderId;
  final OrderView order;

  const OrderTimelineWidget({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  ConsumerState<OrderTimelineWidget> createState() =>
      _OrderTimelineWidgetState();
}

class _OrderTimelineWidgetState extends ConsumerState<OrderTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entrance;
  bool _entranceStarted = false;

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

        return AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) {
            final totalMs = (40 * (visible.length - 1) + 200).clamp(200, 10000);
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
                  local = ((tGlobal - start) / (end - start)).clamp(0.0, 1.0);
                }
                local = Curves.easeOut.transform(local);
                final isLast = i == visible.length - 1;

                return Opacity(
                  opacity: local,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - local)),
                    child: OrderTimelineStepRow(
                      stage: s,
                      orderId: widget.orderId,
                      order: widget.order,
                      isLast: isLast,
                      lineAfterIsComplete:
                          s.stageNumber < widget.order.stageNumber,
                      pendingPayments: pending,
                      shipping: shipping,
                      clearance: clearance,
                      repairJob: repairJob,
                    ),
                  ),
                );
              }),
            );
          },
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
