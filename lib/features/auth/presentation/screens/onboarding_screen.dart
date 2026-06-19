import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/acquisition_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/onboarding_slides.dart';
import '../providers/onboarding_seen_provider.dart';
import '../widgets/auth_visual_widgets.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  OnboardingSlide get _currentSlide => kOnboardingSlides[_index];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeen() async {
    final storage = await ref.read(onboardingSeenStorageProvider.future);
    await storage.markOnboardingSeen();
    ref.invalidate(onboardingSeenStorageProvider);
  }

  Future<void> _goLogin() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    context.goNamed(RouteConstants.login);
  }

  void _next() {
    if (_index == kOnboardingSlides.length - 1) {
      _goLogin();
      return;
    }
    if (!mounted) return;
    if (AcquisitionLayout.useWebLayout(context)) {
      setState(() => _index++);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previous() {
    if (_index == 0) return;
    if (!mounted) return;
    if (AcquisitionLayout.useWebLayout(context)) {
      setState(() => _index--);
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    if (AcquisitionLayout.useWebLayout(context)) {
      return _WebOnboardingLayout(
        index: _index,
        slide: _currentSlide,
        onNext: _next,
        onPrevious: _previous,
        onSkip: () => _goLogin(),
      );
    }
    return _MobileOnboardingLayout(
      controller: _controller,
      index: _index,
      bottomInset: bottomInset,
      onIndexChanged: (v) => setState(() => _index = v),
      onNext: _next,
      onPrevious: _previous,
      onSkip: () => _goLogin(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mobile — light base, premium bottom sheet
// ─────────────────────────────────────────────────────────────

class _MobileOnboardingLayout extends StatelessWidget {
  const _MobileOnboardingLayout({
    required this.controller,
    required this.index,
    required this.bottomInset,
    required this.onIndexChanged,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final PageController controller;
  final int index;
  final double bottomInset;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final slide = kOnboardingSlides[index];
    final portraitTablet = AcquisitionLayout.isPortraitTablet(context);

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onPrevious();
      },
      child: Scaffold(
        backgroundColor:
            portraitTablet ? AppColors.surface : AppColors.background,
        body: OnboardingSlideSemantics(
          slideIndex: index,
          totalSlides: kOnboardingSlides.length,
          slide: slide,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              PageView.builder(
                controller: controller,
                itemCount: kOnboardingSlides.length,
                onPageChanged: onIndexChanged,
                itemBuilder: (context, i) {
                  final slideData = kOnboardingSlides[i];

                  return OnboardingMobileHeroImage(
                    imagePath: slideData.imagePath,
                    pushFromBottom: slideData.mobileHeroPushFromBottom,
                  );
                },
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.55),
                        AppColors.background.withValues(alpha: 0.96),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.28, 0.52, 0.68, 1.0],
                    ),
                  ),
                ),
              ),
              if (index > 0)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 12,
                  child: _BackArrowButton(onTap: onPrevious),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: portraitTablet
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AcquisitionLayout.phoneColumnMaxWidth,
                            ),
                            child: _MobileBottomPanel(
                              slide: slide,
                              slideIndex: index,
                              bottomInset: bottomInset,
                              onNext: onNext,
                              onSkip: onSkip,
                              floatingCard: true,
                            ),
                          ),
                        ),
                      )
                    : _MobileBottomPanel(
                        slide: slide,
                        slideIndex: index,
                        bottomInset: bottomInset,
                        onNext: onNext,
                        onSkip: onSkip,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBottomPanel extends StatelessWidget {
  const _MobileBottomPanel({
    required this.slide,
    required this.slideIndex,
    required this.bottomInset,
    required this.onNext,
    required this.onSkip,
    this.floatingCard = false,
  });

  final OnboardingSlide slide;
  final int slideIndex;
  final double bottomInset;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool floatingCard;

  bool get _isLast => slideIndex == kOnboardingSlides.length - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: floatingCard
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: floatingCard ? 0.06 : 0.08),
            blurRadius: floatingCard ? 16 : 24,
            offset: Offset(0, floatingCard ? -2 : -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingSlideDots(
              currentIndex: slideIndex,
              totalSlides: kOnboardingSlides.length,
              accentColor: slide.accentColor,
              inactiveColor: AppColors.borderSolid,
            ),
            const SizedBox(height: 14),
            Text(
              slide.eyebrow,
              style: AppTextStyles.sectionLabel.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              slide.title,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.15,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              slide.subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            OnboardingFeatureTiles(tiles: slide.tiles, compact: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onNext,
                style: AppButtonStyles.accentFill(
                  slide.accentColor,
                  minimumHeight: 52,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slide.buttonLabel,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                child: Text(
                  _isLast
                      ? 'Already have an account? Sign in'
                      : 'Skip for now',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Web — split panel, scrollable centred content
// ─────────────────────────────────────────────────────────────

class _WebOnboardingLayout extends StatelessWidget {
  const _WebOnboardingLayout({
    required this.index,
    required this.slide,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final int index;
  final OnboardingSlide slide;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: _WebPhotoPanel(
                      slide: slide,
                      slideIndex: index,
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: _WebActionPanel(
                      slide: slide,
                      slideIndex: index,
                      onNext: onNext,
                      onPrevious: onPrevious,
                      onSkip: onSkip,
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

class _WebPhotoPanel extends StatelessWidget {
  const _WebPhotoPanel({
    required this.slide,
    required this.slideIndex,
  });

  final OnboardingSlide slide;
  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            child: OnboardingAssetImage(
              key: ValueKey(slide.imagePath),
              imagePath: slide.imagePath,
              alignment: Alignment.topCenter,
              expand: true,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.4, 0.6, 0.78, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: slide.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Slide ${slideIndex + 1} of ${kOnboardingSlides.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (slide.quote != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: OnboardingQuoteCard(
              quote: slide.quote!,
              onDark: true,
              compact: true,
            ),
          ),
      ],
    );
  }
}

class _WebActionPanel extends StatelessWidget {
  const _WebActionPanel({
    required this.slide,
    required this.slideIndex,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final int slideIndex;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  bool get _isLast => slideIndex == kOnboardingSlides.length - 1;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlideSemantics(
      slideIndex: slideIndex,
      totalSlides: kOnboardingSlides.length,
      slide: slide,
      child: Container(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const AuthAppLogo(fontSize: 16),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(
                        color: AppColors.borderSolid,
                        width: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Sign in',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (slideIndex > 0)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: onPrevious,
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                ),
                              ),
                            ),
                          OnboardingSlideDots(
                            currentIndex: slideIndex,
                            totalSlides: kOnboardingSlides.length,
                            accentColor: slide.accentColor,
                            activeWidth: 18,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide.eyebrow,
                            style: AppTextStyles.sectionLabel.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide.title,
                            style: AppTextStyles.displaySmall.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OnboardingFeatureTiles(
                            tiles: slide.tiles,
                            compact: true,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: onNext,
                              style: AppButtonStyles.accentFill(slide.accentColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slide.buttonLabel,
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton(
                              onPressed: onSkip,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                              child: Text(
                                _isLast
                                    ? 'Already have an account? Sign in'
                                    : 'Skip for now',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderSolid, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have an account? ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Sign in',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackArrowButton extends StatelessWidget {
  const _BackArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 16,
          ),
        ),
      ),
    );
  }
}
