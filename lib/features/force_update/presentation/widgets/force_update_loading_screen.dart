import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'force_update_visual_widgets.dart';

/// Branded splash shown while force-update settings are loading.
class ForceUpdateLoadingScreen extends StatefulWidget {
  const ForceUpdateLoadingScreen({super.key});

  @override
  State<ForceUpdateLoadingScreen> createState() =>
      _ForceUpdateLoadingScreenState();
}

class _ForceUpdateLoadingScreenState extends State<ForceUpdateLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.98, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ForceUpdateAmbientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.contentMaxWidth(context),
              ),
              child: Padding(
                padding: ResponsiveLayout.contentPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        return ForceUpdateHeroBadge(scale: _pulse.value);
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Checking for updates',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Shimmer.fromColors(
                      baseColor: AppColors.surface,
                      highlightColor: AppColors.background,
                      child: Column(
                        children: [
                          Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
