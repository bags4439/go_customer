import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One row in the full-width web buyer sidebar (hover, selection, badge).
class BuyerWebSidebarNavItem extends StatefulWidget {
  const BuyerWebSidebarNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<BuyerWebSidebarNavItem> createState() => _BuyerWebSidebarNavItemState();
}

class _BuyerWebSidebarNavItemState extends State<BuyerWebSidebarNavItem> {
  bool _hovered = false;

  Color get _bg {
    if (widget.isSelected) {
      return _hovered ? AppColors.hoverSelected : AppColors.infoBackground;
    }
    return _hovered ? AppColors.hoverSurface : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(9),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      widget.icon,
                      key: ValueKey(widget.isSelected),
                      size: 18,
                      color: widget.isSelected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: widget.isSelected
                            ? AppColors.infoText
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.badgeCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
