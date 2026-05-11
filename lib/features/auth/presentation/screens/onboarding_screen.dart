import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/onboarding_web_content.dart';
import '../widgets/auth_visual_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _SlideData(
      imagePath: 'assets/onboarding_preference.jpg',
      accentColor: Color(0xFF234A83),
      title: 'Tell us what\nyou want.',
      subtitle:
          'Point us to your dream car'
          ' — make, model, budget.'
          ' We take it from there.',
      buttonLabel: 'Get started',
    ),
    _SlideData(
      imagePath: 'assets/onboarding_agent.jpg',
      accentColor: Color(0xFF0F6A25),
      title: 'Your personal\nagent.',
      subtitle:
          'A dedicated human agent'
          ' searches, negotiates, and'
          ' keeps you updated every'
          ' step of the way.',
      buttonLabel: 'Continue',
    ),
    _SlideData(
      imagePath: 'assets/onboarding_journey.jpg',
      accentColor: Color(0xFF8C6B00),
      title: 'We handle\nthe journey.',
      subtitle:
          'Shipping, port clearance,'
          ' duty, repairs — tracked'
          ' end to end. You watch,'
          ' we handle it.',
      buttonLabel: 'Continue',
    ),
    _SlideData(
      imagePath: 'assets/onboarding_ready.jpg',
      accentColor: Color(0xFF378ADD),
      title: 'Road ready.\nDelivered.',
      subtitle:
          'Your car arrives road-ready'
          ' at your door. Keys in hand'
          ' — just the way you'
          ' imagined it.',
      buttonLabel: 'Create account',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      context.goNamed(RouteConstants.register);
      return;
    }
    if (!mounted) return;
    if (AppBreakpoints.isWeb(context)) {
      setState(() => _index++);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _previous() {
    if (_index == 0) return;
    if (!mounted) return;
    if (AppBreakpoints.isWeb(context)) {
      setState(() => _index--);
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isWeb = AppBreakpoints.isWeb(context);
    final isTablet = AppBreakpoints.isTablet(context);

    final controls = _OnboardingControls(
      currentIndex: _index,
      totalSlides: _slides.length,
      primaryButtonLabel: _slides[_index].buttonLabel,
      onNext: _next,
      onSkip: () => context.goNamed(RouteConstants.login),
      bottomInset: bottomInset,
    );

    if (isWeb) {
      final slide = kOnboardingWebSlides[_index];
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _WebPhotoPanel(
                        slide: slide,
                        slideIndex: _index,
                        totalSlides: _slides.length,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: _WebActionPanel(
                        slide: slide,
                        slideIndex: _index,
                        totalSlides: _slides.length,
                        onNext: _next,
                        onPrevious: _previous,
                        onSkip: () =>
                            context.goNamed(RouteConstants.login),
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

    if (isTablet) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: const Color(0xFFE0DFD8).withValues(alpha: 0.3),
                  spacing: 24,
                  dotRadius: 1.5,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AuthAppLogo(fontSize: 20),
                        TextButton(
                          onPressed: () =>
                              context.goNamed(RouteConstants.login),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign in',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF378ADD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _slides.length,
                          onPageChanged: (v) => setState(() => _index = v),
                          itemBuilder: (context, index) {
                            return _OnboardingSlideContent(
                              slide: _slides[index],
                              index: index,
                              totalSlides: _slides.length,
                              currentIndex: _index,
                              onNext: _next,
                              onSkip: () =>
                                  context.goNamed(RouteConstants.login),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Center(child: controls),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile — full bleed immersive
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previous();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (v) => setState(() => _index = v),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Image.asset(
                    slide.imagePath,
                    key: ValueKey<String>(slide.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
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
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x55000000),
                      Color(0xCC000000),
                      Color(0xEE000000),
                    ],
                    stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            if (_index > 0)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 16,
                child: _BackArrowButton(onTap: _previous),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _MobileSlideContent(
                slide: _slides[_index],
                currentIndex: _index,
                totalSlides: _slides.length,
                bottomInset: bottomInset,
                onNext: _next,
                onSkip: () => context.goNamed(RouteConstants.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideContent extends StatelessWidget {
  const _OnboardingSlideContent({
    required this.slide,
    required this.index,
    required this.totalSlides,
    required this.currentIndex,
    required this.onNext,
    required this.onSkip,
  });

  final _SlideData slide;
  final int index;
  final int totalSlides;
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OnboardingSlideImageEntrance(
            key: ValueKey<int>(index),
            imagePath: slide.imagePath,
            accentColor: slide.accentColor,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displaySmall.copyWith(
                color: const Color(0xFF1A1A18),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingControls extends StatelessWidget {
  const _OnboardingControls({
    required this.currentIndex,
    required this.totalSlides,
    required this.primaryButtonLabel,
    required this.onNext,
    required this.onSkip,
    required this.bottomInset,
  });

  final int currentIndex;
  final int totalSlides;
  final String primaryButtonLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final double bottomInset;

  bool get _isLast => currentIndex == totalSlides - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSlides, (index) {
              final active = currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: active ? 24 : 6,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF378ADD)
                      : const Color(0xFFE0DFD8),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF378ADD),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                primaryButtonLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isLast ? 'Already have an account? Sign in' : 'Skip for now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed mobile slide content overlay. Sits at the bottom of the screen
/// over the dark gradient.
class _MobileSlideContent extends StatelessWidget {
  const _MobileSlideContent({
    required this.slide,
    required this.currentIndex,
    required this.totalSlides,
    required this.bottomInset,
    required this.onNext,
    required this.onSkip,
  });

  final _SlideData slide;
  final int currentIndex;
  final int totalSlides;
  final double bottomInset;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  bool get _isLast => currentIndex == totalSlides - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(totalSlides, (i) {
              final active = currentIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 5),
                height: 6,
                width: active ? 22 : 6,
                decoration: BoxDecoration(
                  color: active
                      ? slide.accentColor
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              slide.title,
              key: ValueKey<String>(slide.title),
              style: AppTextStyles.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.15,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              slide.subtitle,
              key: ValueKey<String>(slide.subtitle),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: onNext,
                borderRadius: BorderRadius.circular(50),
                splashColor: Colors.black.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: slide.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          slide.buttonLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: const Color(0xFF1A1A18),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0x661A1A18),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: onSkip,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  _isLast ? 'Already have an account? Sign in' : 'Skip for now',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideImageEntrance extends StatefulWidget {
  final String imagePath;
  final Color accentColor;

  const _OnboardingSlideImageEntrance({
    super.key,
    required this.imagePath,
    required this.accentColor,
  });

  @override
  State<_OnboardingSlideImageEntrance> createState() =>
      _OnboardingSlideImageEntranceState();
}

class _OnboardingSlideImageEntranceState
    extends State<_OnboardingSlideImageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _t.value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: widget.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
            width: 88,
            height: 88,
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final String imagePath;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _SlideData({
    required this.imagePath,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}

/// Frosted glass back arrow button shown on slides 2, 3 and 4 of the mobile
/// onboarding flow. Hidden on slide 1.
class _BackArrowButton extends StatelessWidget {
  const _BackArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: .5,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

/// Left panel — full bleed photo
/// with dark gradient overlay,
/// slide counter pill and optional
/// agent quote tile.
class _WebPhotoPanel extends StatelessWidget {
  const _WebPhotoPanel({
    required this.slide,
    required this.slideIndex,
    required this.totalSlides,
  });

  final OnboardingWebSlide slide;
  final int slideIndex;
  final int totalSlides;

  static const _images = [
    'assets/onboarding_preference.jpg',
    'assets/onboarding_agent.jpg',
    'assets/onboarding_journey.jpg',
    'assets/onboarding_ready.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            _images[slideIndex],
            key: ValueKey<int>(slideIndex),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x44000000),
                  Color(0xBB000000),
                  Color(0xEE000000),
                ],
                stops: [
                  0.0,
                  0.35,
                  0.55,
                  0.75,
                  1.0,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
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
                  'Slide ${slideIndex + 1} of $totalSlides',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
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
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        slide.quote!.initials,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.quote!.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          slide.quote!.text,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Right panel — off-white
/// background with logo, dots,
/// title, subtitle, white card
/// feature tiles and CTA button.
class _WebActionPanel extends StatelessWidget {
  const _WebActionPanel({
    required this.slide,
    required this.slideIndex,
    required this.totalSlides,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final OnboardingWebSlide slide;
  final int slideIndex;
  final int totalSlides;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  bool get _isLast => slideIndex == totalSlides - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onPressed: () =>
                      context.goNamed(RouteConstants.login),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(
                      color: AppColors.borderSolid,
                      width: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (slideIndex > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: onPrevious,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: List.generate(
                      totalSlides,
                      (i) {
                        final active = i == slideIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 5),
                          width: active ? 18 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: active
                                ? slide.accentColor
                                : AppColors.borderSolid,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
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
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...slide.tiles.map(
                    (tile) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: tile.iconBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                tile.icon,
                                size: 16,
                                color: tile.iconColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tile.label,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slide.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.buttonLabel,
                            style: AppTextStyles.buttonMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderSolid,
                  width: 0.5,
                ),
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
                GestureDetector(
                  onTap: () =>
                      context.goNamed(RouteConstants.login),
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
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
