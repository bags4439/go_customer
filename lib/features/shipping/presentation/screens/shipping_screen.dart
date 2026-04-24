import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/features/shipping/data/models/shipping_model.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../orders/core/constants/order_timeline_constants.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../domain/entities/shipping.dart';
import '../providers/shipping_providers.dart';

final _dateFmt = DateFormat('d MMM yyyy');

// ─── Screen ──────────────────────────

class ShippingScreen extends ConsumerWidget {
  final String orderId;

  const ShippingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shippingAsync = ref.watch(orderShippingProvider(orderId));
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shipping tracker',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                orderRef,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: shippingAsync.when(
        data: (shipping) {
          if (shipping == null) {
            return _NotArranged(orderId: orderId);
          }
          final state = ref.watch(shippingScreenStateProvider(orderId));
          final entity = shipping.toEntity();
          switch (state) {
            case ShippingScreenState.notArranged:
              return _NotArranged(orderId: orderId);
            case ShippingScreenState.booked:
              return _BookedState(orderId: orderId, shipping: entity);
            case ShippingScreenState.inTransit:
              return _InTransitState(orderId: orderId, shipping: entity);
            case ShippingScreenState.arrived:
              return _ArrivedState(orderId: orderId, shipping: entity);
            case ShippingScreenState.released:
              return _ReleasedState(orderId: orderId, shipping: entity);
          }
        },
        loading: () => const _ShippingLoadingState(),
        error: (e, _) => _ErrorState(orderId: orderId, message: e.toString()),
      ),
    );
  }
}

// ─── States ──────────────────────────

class _NotArranged extends StatelessWidget {
  final String orderId;

  const _NotArranged({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: ValueKey('not_arranged_$orderId'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              'Shipping not yet arranged',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your agent will update this screen once your vehicle has '
              'been booked for shipping.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                '← Back to order',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookedState extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _BookedState({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      key: ValueKey('booked_$orderId'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeroBanner(
            emoji: '🚢',
            title: 'Your car is being prepared for shipping',
            subtitle:
                'Your agent has booked ocean freight. Departure details will follow.',
            color: AppColors.secondary,
            bgColor: AppColors.infoBackground,
            textColor: AppColors.infoText,
          ),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          _ShippingTimeline(
            shipping: shipping,
            progress: 0,
            isArrived: false,
          ),
          if (shipping.agentNotes != null &&
              shipping.agentNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _AgentNoteCard(note: shipping.agentNotes!),
          ],
        ],
      ),
    );
  }
}

class _InTransitState extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _InTransitState({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(journeyProgressProvider(orderId));
    final eta = shipping.estimatedArrival;
    final daysLeft = eta != null
        ? eta.difference(DateTime.now()).inDays.clamp(0, 999)
        : 0;

    return SingleChildScrollView(
      key: ValueKey('intransit_$orderId'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBanner(
            emoji: '🚢',
            title: 'Your car is on its way',
            subtitle: eta != null
                ? 'ETA ${_dateFmt.format(eta)} · $daysLeft day'
                    '${daysLeft == 1 ? '' : 's'} remaining'
                : 'En route to Tema, Ghana',
            color: AppColors.secondary,
            bgColor: AppColors.infoBackground,
            textColor: AppColors.infoText,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ROUTE'),
          const SizedBox(height: 8),
          _RouteVisual(
            shipping: shipping,
            progress: progress,
            isArrived: false,
          ),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          _ShippingTimeline(
            shipping: shipping,
            progress: progress,
            isArrived: false,
          ),
          if (shipping.agentNotes != null &&
              shipping.agentNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _AgentNoteCard(note: shipping.agentNotes!),
          ],
        ],
      ),
    );
  }
}

class _ArrivedState extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _ArrivedState({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = shipping.actualArrival;
    final est = shipping.estimatedArrival;
    var scheduleText = '';
    if (actual != null && est != null) {
      final diff = est.difference(actual).inDays;
      if (diff > 0) {
        scheduleText = '$diff day${diff == 1 ? '' : 's'} ahead of schedule';
      } else if (diff < 0) {
        scheduleText = '${-diff} day${-diff == 1 ? '' : 's'} behind schedule';
      } else {
        scheduleText = 'Arrived on schedule';
      }
    }

    return SingleChildScrollView(
      key: ValueKey('arrived_$orderId'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBanner(
            emoji: '⚓',
            title: 'Your car has arrived at Tema port!',
            subtitle: actual != null
                ? 'Arrived ${_dateFmt.format(actual)}'
                    '${scheduleText.isNotEmpty ? ' · $scheduleText' : ''}'
                : 'Your vehicle is at Tema port.',
            color: AppColors.success,
            bgColor: AppColors.successMutedBackground,
            textColor: AppColors.successMutedForeground,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ROUTE — COMPLETED'),
          const SizedBox(height: 8),
          _RouteVisual(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          _ShippingTimeline(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          if (shipping.agentNotes != null &&
              shipping.agentNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _AgentNoteCard(note: shipping.agentNotes!),
          ],
        ],
      ),
    );
  }
}

class _ReleasedState extends ConsumerWidget {
  final String orderId;
  final Shipping shipping;

  const _ReleasedState({required this.orderId, required this.shipping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      key: ValueKey('released_$orderId'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeroBanner(
            emoji: '✅',
            title: 'Your car has been released from port',
            subtitle:
                'Port clearance is complete. Your agent is arranging final delivery.',
            color: AppColors.success,
            bgColor: AppColors.successMutedBackground,
            textColor: AppColors.successMutedForeground,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ROUTE — COMPLETED'),
          const SizedBox(height: 8),
          _RouteVisual(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          const SizedBox(height: 20),
          _VesselDetailsCard(shipping: shipping),
          const SizedBox(height: 16),
          _ShippingTimeline(
            shipping: shipping,
            progress: 100,
            isArrived: true,
          ),
          if (shipping.agentNotes != null &&
              shipping.agentNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _AgentNoteCard(note: shipping.agentNotes!),
          ],
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────

class _HeroBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final Color textColor;

  const _HeroBanner({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: textColor.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _VesselDetailsCard extends StatelessWidget {
  final Shipping shipping;

  const _VesselDetailsCard({required this.shipping});

  @override
  Widget build(BuildContext context) {
    final hasTracking = shipping.trackingUrl != null &&
        shipping.trackingUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Vessel details',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              if (hasTracking)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(shipping.trackingUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    'Track live →',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow('Vessel', shipping.vesselName ?? '—'),
          _DetailRow('Shipping line', shipping.shippingLine ?? '—'),
          _DetailRow('Container', shipping.containerNumber ?? '—'),
          _DetailRow('Bill of lading', shipping.blNumber ?? '—'),
          _DetailRow('Origin port', shipping.originPort ?? '—'),
          _DetailRow(
            'Destination',
            shipping.destinationPort ?? 'Tema, Ghana',
          ),
          if (shipping.estimatedDeparture != null)
            _DetailRow(
              'Est. departure',
              DateFormatter.formatDate(shipping.estimatedDeparture),
            ),
          _DetailRow(
            'Departed',
            DateFormatter.formatDate(shipping.actualDeparture),
          ),
          _DetailRow(
            'ETA Tema',
            DateFormatter.formatDate(shipping.estimatedArrival),
          ),
          if (shipping.actualArrival != null)
            _DetailRow(
              'Arrived',
              DateFormatter.formatDate(shipping.actualArrival),
            ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteVisual extends StatefulWidget {
  final Shipping shipping;
  final double progress;
  final bool isArrived;

  const _RouteVisual({
    required this.shipping,
    required this.progress,
    required this.isArrived,
  });

  @override
  State<_RouteVisual> createState() => _RouteVisualState();
}

class _RouteVisualState extends State<_RouteVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  double? _animTarget;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.shipping.originPort ?? 'Origin port';
    final dest = widget.shipping.destinationPort ?? 'Tema, Ghana';
    final departed = widget.shipping.actualDeparture;
    final eta = widget.shipping.estimatedArrival;
    final actual = widget.shipping.actualArrival;
    final pct = widget.progress.clamp(0.0, 100.0) / 100;
    _animTarget ??= pct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  origin,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  departed != null ? 'Dep. ${_dateFmt.format(departed)}' : '—',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.borderSolid,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        key: const ValueKey('route_progress'),
                        tween: Tween(begin: 0, end: _animTarget!),
                        duration: const Duration(milliseconds: 900),
                        builder: (ctx, val, _) => Container(
                          height: 3,
                          width: constraints.maxWidth * val,
                          decoration: BoxDecoration(
                            color: widget.isArrived
                                ? AppColors.success
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (!widget.isArrived &&
                          widget.progress > 0 &&
                          widget.progress < 100)
                        Positioned(
                          left: (constraints.maxWidth * pct)
                                  .clamp(0.0, constraints.maxWidth - 20) -
                              8,
                          top: -8,
                          child: const Text('🚢', style: TextStyle(fontSize: 16)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: widget.isArrived
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _pulse,
                          builder: (ctx, _) => Transform.scale(
                            scale: 1.0 + 0.35 * _pulse.value,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isArrived ? '$dest ✓' : dest,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isArrived && actual != null
                      ? 'Arr. ${_dateFmt.format(actual)}'
                      : eta != null
                          ? 'ETA ${_dateFmt.format(eta)}'
                          : '—',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingTimeline extends ConsumerWidget {
  final Shipping shipping;
  final double progress;
  final bool isArrived;

  const _ShippingTimeline({
    required this.shipping,
    required this.progress,
    required this.isArrived,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = shipping.status;
    final stage1Done = status != 'pending';
    final stage2Done = shipping.actualDeparture != null;
    final stage3Active = status == 'in_transit';
    final stage4Done = isArrived;
    final stage5Done = shipping.isReleased;
    final stage5Active = isArrived && !shipping.isReleased;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping stages',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _TimelineItem(
            label: 'Booked',
            detail: null,
            isDone: stage1Done,
            isActive: !stage1Done,
          ),
          _TimelineItem(
            label: 'Departed ${shipping.originPort ?? "port"}',
            detail: shipping.vesselName != null
                ? 'Loaded onto ${shipping.vesselName}'
                : null,
            isDone: stage2Done,
            isActive: stage1Done && !stage2Done,
          ),
          _TimelineItem(
            label: 'In transit',
            detail:
                '${progress.toStringAsFixed(0)}% of journey complete',
            isDone: isArrived,
            isActive: stage3Active,
          ),
          _TimelineItem(
            label: 'Arrived at Tema port',
            detail: shipping.estimatedArrival != null
                ? DateFormatter.formatDate(shipping.estimatedArrival)
                : null,
            isDone: stage4Done,
            isActive: false,
          ),
          _TimelineItem(
            label: 'Released from port',
            detail: stage5Active
                ? 'Your next step'
                : 'After duty & clearance',
            isDone: stage5Done,
            isActive: stage5Active,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final String label;
  final String? detail;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.label,
    this.detail,
    required this.isDone,
    required this.isActive,
    this.isLast = false,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              widget.isDone
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    )
                  : widget.isActive
                      ? AnimatedBuilder(
                          animation: _pulse,
                          builder: (ctx, _) => Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.borderSolid,
                            shape: BoxShape.circle,
                          ),
                        ),
              if (!widget.isLast)
                Container(
                  width: 1.5,
                  height: 20,
                  color: widget.isDone
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.borderSolid,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: widget.isDone
                          ? AppColors.textSecondary
                          : widget.isActive
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                    ),
                  ),
                  if (widget.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.detail!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentNoteCard extends StatelessWidget {
  final String note;

  const _AgentNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OrderTimelineConstants.agentNoteLabel,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingLoadingState extends StatelessWidget {
  const _ShippingLoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: AppColors.background,
              child: Container(
                height: i == 0 ? 100 : (i == 1 ? 180 : 220),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (i < 2) const SizedBox(height: 16),
          ],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load shipping details.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            if (kDebugMode && message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                '← Back to order',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
