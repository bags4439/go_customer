import 'package:flutter/material.dart';
import 'package:go_customer/core/widgets/card_container.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/shipping.dart';
import 'shipping_formatters.dart';

class ShippingRouteVisual extends StatefulWidget {
  const ShippingRouteVisual({
    super.key,
    required this.shipping,
    required this.progress,
    required this.isArrived,
  });

  final Shipping shipping;
  final double progress;
  final bool isArrived;

  @override
  State<ShippingRouteVisual> createState() => _ShippingRouteVisualState();
}

class _ShippingRouteVisualState extends State<ShippingRouteVisual>
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

    return CardContainer(
        paddingType: CardContainerPaddingType.xlarge,
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
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                departed != null
                    ? 'Dep. ${shippingDisplayDateFormat.format(departed)}'
                    : '—',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
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
                style: AppTextStyles.labelSmall.copyWith(
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
                    ? 'Arr. ${shippingDisplayDateFormat.format(actual)}'
                    : eta != null
                    ? 'ETA ${shippingDisplayDateFormat.format(eta)}'
                    : '—',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
