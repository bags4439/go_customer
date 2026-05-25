import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import 'repair_formatters.dart';

class RepairCompleteHero extends StatefulWidget {
  const RepairCompleteHero({
    super.key,
    required this.actualCompletion,
    required this.makeModel,
  });

  final DateTime? actualCompletion;
  final String makeModel;

  @override
  State<RepairCompleteHero> createState() => _RepairCompleteHeroState();
}

class _RepairCompleteHeroState extends State<RepairCompleteHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _checkController,
              curve: Curves.easeOutBack,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            RepairConstants.state4HeroTitle,
            style: AppTextStyles.amountMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            RepairConstants.state4HeroSubtitle(widget.makeModel),
            style: AppTextStyles.cardLabel.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (widget.actualCompletion != null) ...[
            const SizedBox(height: 4),
            Text(
              repairDisplayDateFormat.format(widget.actualCompletion!),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
