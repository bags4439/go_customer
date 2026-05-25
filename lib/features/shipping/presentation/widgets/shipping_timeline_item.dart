import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ShippingTimelineItem extends StatefulWidget {
  const ShippingTimelineItem({
    super.key,
    required this.label,
    this.detail,
    required this.isDone,
    required this.isActive,
    this.isLast = false,
  });

  final String label;
  final String? detail;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  @override
  State<ShippingTimelineItem> createState() => _ShippingTimelineItemState();
}

class _ShippingTimelineItemState extends State<ShippingTimelineItem>
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
                    style: AppTextStyles.bodySmall.copyWith(
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
                    Text(widget.detail!, style: AppTextStyles.caption),
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
