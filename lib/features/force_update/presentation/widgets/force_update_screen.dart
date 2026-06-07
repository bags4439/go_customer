import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../support/presentation/widgets/support_contact_section.dart';
import '../../domain/entities/force_update_requirement.dart';
import 'force_update_visual_widgets.dart';

/// Fullscreen, non-dismissable update prompt for outdated native builds.
class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({super.key, required this.requirement});

  final ForceUpdateRequirement requirement;

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _heroScale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _contentOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 1, curve: Curves.easeOutCubic),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 1, curve: Curves.easeOutCubic),
      ),
    );
    _heroScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _openStore() async {
    final url = widget.requirement.storeUrl?.trim();
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.hasScheme && (uri.isScheme('https') || uri.isScheme('http')))) {
      if (mounted) {
        showErrorSnackBar(context, 'Store link is not available.');
      }
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        showErrorSnackBar(
          context,
          'Could not open the store. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Could not open the store. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requirement = widget.requirement;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final storeLabel = requirement.isIos ? 'App Store' : 'Google Play';
    final buttonLabel = requirement.isIos
        ? 'Update on the App Store'
        : 'Update on Google Play';
    final buttonIcon = requirement.isIos
        ? Icons.apple_rounded
        : Icons.android_rounded;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 16,
                          bottom: bottomInset + 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: AnimatedBuilder(
                                animation: _heroScale,
                                builder: (context, child) {
                                  return ForceUpdateHeroBadge(
                                    scale: _heroScale.value,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Center(child: ForceUpdateStatusChip()),
                            const SizedBox(height: 14),
                            Text(
                              'Update required',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                height: 1.12,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Please install the latest version of '
                              '${AppConstants.appName} from the $storeLabel '
                              'to keep using the app.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            ForceUpdateVersionCard(requirement: requirement),
                            const SizedBox(height: 28),
                            ForceUpdatePrimaryButton(
                              label: buttonLabel,
                              icon: buttonIcon,
                              onPressed:
                                  requirement.hasStoreUrl ? _openStore : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'After updating, reopen the app to continue.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!requirement.hasStoreUrl) ...[
                              const SizedBox(height: 20),
                              const ForceUpdateUnavailableBanner(),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.borderSolid,
                                  ),
                                ),
                                child: const SupportContactSection(
                                  compact: true,
                                  heading: 'Need help updating?',
                                  subheading:
                                      'Our team can point you to the correct '
                                      'store listing.',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
