import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../domain/entities/shipping.dart';
import '../providers/shipping_providers.dart';

// Date format: "28 Mar 2026"
final _dateFormat = DateFormat('d MMM yyyy');

class ShippingScreen extends ConsumerWidget {
  final String orderId;

  const ShippingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shippingAsync = ref.watch(shippingProvider(orderId));
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shipping tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                orderRef,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: shippingAsync.when(
        data: (shipping) {
          if (shipping == null) {
            return _State3NotArranged(orderId: orderId);
          }
          final state = ref.watch(shippingScreenStateProvider(orderId));
          switch (state) {
            case ShippingScreenState.notArranged:
              return _State3NotArranged(orderId: orderId);
            case ShippingScreenState.booked:
              return _State0Booked(orderId: orderId, shipping: shipping);
            case ShippingScreenState.inTransit:
              return _State1InTransit(orderId: orderId, shipping: shipping);
            case ShippingScreenState.arrived:
              return _State2Arrived(orderId: orderId, shipping: shipping);
          }
        },
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(orderId: orderId, message: e.toString()),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String orderId;
  final String message;

  const _ErrorState({required this.orderId, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Could not load shipping details. Tap to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.go('/order/$orderId'),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _State3NotArranged extends StatelessWidget {
  final String orderId;

  const _State3NotArranged({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_boat_outlined, size: 80, color: Colors.grey.shade600),
            const SizedBox(height: 24),
            Text(
              'Shipping not yet arranged',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your agent will update this screen once your vehicle has been booked for shipping.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => context.go('/order/$orderId'),
              child: const Text('Back to order', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}

class _State0Booked extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _State0Booked({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your car is being prepared for shipping', style: TextStyle(color: Color(0xFF185FA5), fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping, orderId: orderId),
          const SizedBox(height: 24),
          _ShippingTimeline(orderId: orderId, shipping: shipping, isArrived: false, progress: 0),
        ],
      ),
    );
  }
}

class _State1InTransit extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _State1InTransit({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(journeyProgressProvider(orderId));
    final eta = shipping.estimatedArrival;
    final daysRemaining = eta != null ? eta.difference(DateTime.now()).inDays.clamp(0, 999) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🚢', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                const Text('Your car is on its way', style: TextStyle(color: Color(0xFF185FA5), fontSize: 17, fontWeight: FontWeight.w600)),
                if (eta != null) ...[
                  const SizedBox(height: 4),
                  Text('Estimated arrival: ${_dateFormat.format(eta)}', style: const TextStyle(color: Color(0xFF185FA5), fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('$daysRemaining days remaining', style: const TextStyle(color: Color(0xFF185FA5), fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('ROUTE', style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          _RouteVisual(shipping: shipping, progress: progress, isArrived: false),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping, orderId: orderId),
          const SizedBox(height: 24),
          _ShippingTimeline(orderId: orderId, shipping: shipping, isArrived: false, progress: progress),
        ],
      ),
    );
  }
}

class _State2Arrived extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _State2Arrived({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actualArrival = shipping.actualArrival;
    final estimatedArrival = shipping.estimatedArrival;
    String scheduleText = '';
    if (actualArrival != null && estimatedArrival != null) {
      final diff = estimatedArrival.difference(actualArrival).inDays;
      if (diff > 0) scheduleText = '$diff day(s) ahead of schedule';
      else if (diff < 0) scheduleText = '${-diff} day(s) behind schedule';
      else scheduleText = 'Arrived on schedule';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚓', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                const Text('Your car has arrived at Tema!', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                if (actualArrival != null) ...[
                  const SizedBox(height: 4),
                  Text('Arrived ${_dateFormat.format(actualArrival)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  if (scheduleText.isNotEmpty)
                    Text(scheduleText, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('ROUTE — COMPLETED', style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          _RouteVisual(shipping: shipping, progress: 100, isArrived: true),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              border: Border.all(color: const Color(0xFFF0C070)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ACTION REQUIRED', style: TextStyle(color: Color(0xFFBA7517), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  'Your car is at Tema port. Import duty must be paid and port clearance completed before it can be released.',
                  style: TextStyle(color: Color(0xFF633806), fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => context.push('/order/$orderId/clearance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA7517),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Proceed to duty & clearance →'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ShippingTimeline(orderId: orderId, shipping: shipping, isArrived: true, progress: 100),
        ],
      ),
    );
  }
}

class _RouteVisual extends StatefulWidget {
  final Shipping shipping;
  final double progress;
  final bool isArrived;

  const _RouteVisual({required this.shipping, required this.progress, required this.isArrived});

  @override
  State<_RouteVisual> createState() => _RouteVisualState();
}

class _RouteVisualState extends State<_RouteVisual> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double? _initialProgressTarget;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftPort = widget.shipping.originPort ?? 'Origin';
    final rightPort = widget.shipping.destinationPort ?? 'Tema, Ghana';
    final departed = widget.shipping.actualDeparture;
    final eta = widget.shipping.estimatedArrival;
    final actualArrival = widget.shipping.actualArrival;
    final progressPct = widget.progress.clamp(0.0, 100.0) / 100;
    _initialProgressTarget ??= progressPct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(height: 4),
                Text(leftPort, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                Text('Departed ${departed != null ? _dateFormat.format(departed) : "—"}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackHeight = 3.0;
                    final animatedEnd = _initialProgressTarget!;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          key: const ValueKey('route_progress_once'),
                          tween: Tween(begin: 0, end: animatedEnd),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, _) {
                            final w = constraints.maxWidth * value;
                            return Container(
                              height: trackHeight,
                              width: w,
                              decoration: BoxDecoration(
                                color: widget.isArrived ? AppColors.success : AppColors.secondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                        if (!widget.isArrived && widget.progress > 0 && widget.progress < 100)
                          Positioned(
                            left: (constraints.maxWidth * progressPct).clamp(0.0, constraints.maxWidth - 24) - 8,
                            top: -6,
                            child: const Text('🚢', style: TextStyle(fontSize: 16)),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Column(
              children: [
                if (widget.isArrived)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  )
                else
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + 0.4 * _pulseController.value;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 4),
                Text(
                  widget.isArrived ? '$rightPort ✓' : rightPort,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.isArrived && actualArrival != null
                      ? 'Arrived ${_dateFormat.format(actualArrival)} ✓'
                      : 'ETA ${eta != null ? _dateFormat.format(eta) : "—"}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _VesselDetailsCard extends StatelessWidget {
  final Shipping shipping;
  final String orderId;

  const _VesselDetailsCard({required this.shipping, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final hasTracking = shipping.trackingUrl != null && shipping.trackingUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vessel details', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
              if (hasTracking)
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(shipping.trackingUrl!), mode: LaunchMode.externalApplication),
                  child: const Text('Track live →', style: TextStyle(color: Color(0xFF185FA5), fontSize: 11, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow('Vessel', shipping.vesselName ?? '—'),
          _DetailRow('Shipping line', shipping.shippingLine ?? '—'),
          _DetailRow('Container', shipping.containerNumber ?? '—'),
          _DetailRow('Bill of lading', shipping.blNumber ?? '—'),
          _DetailRow('Departed', shipping.actualDeparture != null ? _dateFormat.format(shipping.actualDeparture!) : '—'),
          _DetailRow('ETA Tema', shipping.estimatedArrival != null ? _dateFormat.format(shipping.estimatedArrival!) : '—'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ShippingTimeline extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;
  final bool isArrived;
  final double progress;

  const _ShippingTimeline({required this.orderId, required this.shipping, required this.isArrived, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = shipping.status;
    final stage1Done = status != 'pending';
    final stage2Done = shipping.actualDeparture != null;
    final stage3Active = status == 'in_transit';
    final stage4Done = isArrived;
    final stage5Done = shipping.isReleased;
    final stage5Active = isArrived && !shipping.isReleased;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping stages', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
        const SizedBox(height: 12),
        _TimelineStage(
          label: 'Booked',
          detail: null,
          isDone: stage1Done,
          isActive: !stage1Done,
        ),
        _TimelineStage(
          label: 'Departed ${shipping.originPort ?? "port"}',
          detail: shipping.vesselName != null ? 'Loaded onto ${shipping.vesselName}' : null,
          isDone: stage2Done,
          isActive: stage1Done && !stage2Done,
        ),
        _TimelineStage(
          label: 'In transit',
          detail: '${progress.toStringAsFixed(0)}% of journey complete',
          date: 'Now',
          isDone: isArrived,
          isActive: stage3Active,
        ),
        _TimelineStage(
          label: 'Arrival at Tema port',
          detail: shipping.estimatedArrival != null ? _dateFormat.format(shipping.estimatedArrival!) : null,
          isDone: stage4Done,
          isActive: false,
        ),
        _TimelineStage(
          label: 'Released from port',
          detail: stage5Active ? 'Your next step' : 'After duty & clearance',
          isDone: stage5Done,
          isActive: stage5Active,
        ),
      ],
    );
  }
}

class _TimelineStage extends StatefulWidget {
  final String label;
  final String? detail;
  final String? date;
  final bool isDone;
  final bool isActive;

  const _TimelineStage({
    required this.label,
    this.detail,
    this.date,
    required this.isDone,
    required this.isActive,
  });

  @override
  State<_TimelineStage> createState() => _TimelineStageState();
}

class _TimelineStageState extends State<_TimelineStage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isDone)
            const Icon(Icons.check_circle, color: AppColors.success, size: 20)
          else if (widget.isActive)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) => Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('', style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isActive ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (widget.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(widget.detail!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
                if (widget.date != null)
                  Text(widget.date!, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
