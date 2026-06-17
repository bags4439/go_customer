import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/router/app_router_refresh.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../force_update/presentation/providers/force_update_providers.dart';
import '../../domain/launch_destination.dart';
import '../../domain/launch_timing.dart';
import '../providers/onboarding_seen_provider.dart';
import '../widgets/auth_visual_widgets.dart';
import '../widgets/launch_brand_logo.dart';

/// Single launch experience: native splash handoff, force-update check, auth
/// routing, and profile readiness — then one navigation to the right screen.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final AnimationController _exitController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _exitOpacity;

  bool _navigated = false;
  bool _isDeparting = false;
  bool? _hasSeenOnboarding;
  DateTime? _firstPaintAt;
  String? _departureRoute;
  bool _departureDelayScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appRouterRefresh.addListener(_scheduleNavigation);

    _entranceController = AnimationController(
      vsync: this,
      duration: LaunchTiming.entrance,
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _entranceController.forward();
    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scheduleNavigation();
      }
    });

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: LaunchTiming.exitFade,
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _loadOnboardingSeen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstPaintAt ??= DateTime.now();
      _scheduleNavigation();
    });
  }

  Future<void> _loadOnboardingSeen() async {
    final storage = await ref.read(onboardingSeenStorageProvider.future);
    if (!mounted) return;
    setState(() => _hasSeenOnboarding = storage.hasSeenOnboarding);
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryNavigate();
    });
  }

  Duration get _elapsedSinceFirstPaint {
    final started = _firstPaintAt;
    if (started == null) return Duration.zero;
    return DateTime.now().difference(started);
  }

  Future<void> _tryNavigate() async {
    if (_navigated || _isDeparting || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final refresh = appRouterRefresh;

    bool forceUpdateCheckPending = false;
    bool forceUpdateRequired = false;

    if (!kIsWeb) {
      final requirementAsync = ref.read(forceUpdateRequirementProvider);
      forceUpdateCheckPending = requirementAsync.isLoading;
      forceUpdateRequired =
          requirementAsync.asData?.value.isRequired ?? false;
      if (forceUpdateRequired) return;
    }

    if (_hasSeenOnboarding == null && user == null) return;

    final destination = resolveLaunchDestination(
      hasAuthUser: user != null,
      profileKnown: refresh.profileKnown,
      registrationComplete: refresh.registrationComplete,
      hasSeenOnboarding: _hasSeenOnboarding ?? false,
      forceUpdateCheckPending: forceUpdateCheckPending,
      forceUpdateRequired: forceUpdateRequired,
    );

    final route = launchRouteForDestination(destination);
    if (route == null) return;

    _departureRoute = route;

    final entranceComplete =
        _entranceController.status == AnimationStatus.completed;
    final delay = LaunchTiming.departureDelay(
      elapsedSinceFirstPaint: _elapsedSinceFirstPaint,
      entranceComplete: entranceComplete,
      entranceProgress: _entranceController.value,
    );

    if (delay > Duration.zero) {
      if (!_departureDelayScheduled) {
        _departureDelayScheduled = true;
        Future<void>.delayed(delay, () {
          _departureDelayScheduled = false;
          if (mounted) _depart();
        });
      }
      return;
    }

    await _depart();
  }

  Future<void> _depart() async {
    if (_navigated || _isDeparting || !mounted) return;

    final route = _departureRoute;
    if (route == null) return;

    final entranceComplete =
        _entranceController.status == AnimationStatus.completed;
    final delay = LaunchTiming.departureDelay(
      elapsedSinceFirstPaint: _elapsedSinceFirstPaint,
      entranceComplete: entranceComplete,
      entranceProgress: _entranceController.value,
    );

    if (delay > Duration.zero) {
      if (!_departureDelayScheduled) {
        _departureDelayScheduled = true;
        Future<void>.delayed(delay, () {
          _departureDelayScheduled = false;
          if (mounted) _depart();
        });
      }
      return;
    }

    _isDeparting = true;
    _shimmerController.stop();

    await _exitController.forward();
    if (!mounted) return;

    _navigated = true;
    context.go(route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouterRefresh.removeListener(_scheduleNavigation);
    _entranceController.dispose();
    _shimmerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  String _statusLine() {
    final user = FirebaseAuth.instance.currentUser;
    final refresh = appRouterRefresh;

    if (!kIsWeb) {
      final requirementAsync = ref.watch(forceUpdateRequirementProvider);
      if (requirementAsync.isLoading) {
        return 'Getting things ready…';
      }
    }

    if (user != null) {
      if (!refresh.profileKnown) return 'Getting things ready…';
      return 'Welcome back';
    }

    if (_hasSeenOnboarding == true) {
      return 'Sign in to continue';
    }

    return 'Import your dream car from anywhere in the world.';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(forceUpdateRequirementProvider, (_, __) {
      _scheduleNavigation();
    });
    ref.watch(forceUpdateRequirementProvider);

    final statusLine = _statusLine();
    final mobileLaunch = _MobileLaunchContent(
      logoOpacity: _logoOpacity,
      logoScale: _logoScale,
      taglineOpacity: _taglineOpacity,
      shimmerController: _shimmerController,
      statusLine: statusLine,
      onBrandBackground: true,
    );

    if (AppBreakpoints.isWeb(context)) {
      return FadeTransition(
        opacity: _exitOpacity,
        child: _WebLaunchScaffold(
          logoOpacity: _logoOpacity,
          logoScale: _logoScale,
          taglineOpacity: _taglineOpacity,
          shimmerController: _shimmerController,
          statusLine: statusLine,
        ),
      );
    }

    return FadeTransition(
      opacity: _exitOpacity,
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        body: AppBreakpoints.isMobile(context)
            ? mobileLaunch
            : _TabletLaunchContent(
                logoOpacity: _logoOpacity,
                logoScale: _logoScale,
                taglineOpacity: _taglineOpacity,
                shimmerController: _shimmerController,
                statusLine: statusLine,
              ),
      ),
    );
  }
}

class _MobileLaunchContent extends StatelessWidget {
  const _MobileLaunchContent({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
    required this.statusLine,
    required this.onBrandBackground,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;
  final String statusLine;
  final bool onBrandBackground;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: logoOpacity,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: logoOpacity,
                      child: ScaleTransition(scale: logoScale, child: child),
                    );
                  },
                  child: onBrandBackground
                      ? const LaunchBrandLogo()
                      : const AuthAppLogo(fontSize: 28),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: taglineOpacity,
                  child: Text(
                    statusLine,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: onBrandBackground
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 48 + bottomInset,
          child: Center(
            child: _LaunchShimmerBar(
              controller: shimmerController,
              color: onBrandBackground ? Colors.white : AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabletLaunchContent extends StatelessWidget {
  const _TabletLaunchContent({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
    required this.statusLine,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;
  final String statusLine;

  @override
  Widget build(BuildContext context) {
    return _MobileLaunchContent(
      logoOpacity: logoOpacity,
      logoScale: logoScale,
      taglineOpacity: taglineOpacity,
      shimmerController: shimmerController,
      statusLine: statusLine,
      onBrandBackground: true,
    );
  }
}

class _LaunchShimmerBar extends StatelessWidget {
  const _LaunchShimmerBar({
    required this.controller,
    required this.color,
  });

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(1),
          child: SizedBox(
            width: 48,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + 2 * t, 0),
                  end: Alignment(1.0 + 2 * t, 0),
                  colors: [
                    Colors.transparent,
                    color.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebLaunchScaffold extends StatelessWidget {
  const _WebLaunchScaffold({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
    required this.statusLine,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;
  final String statusLine;

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
              borderRadius: BorderRadius.circular(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(flex: 6, child: _WebLaunchPhotoPanel()),
                  SizedBox(
                    width: 400,
                    child: _WebLaunchActionPanel(
                      logoOpacity: logoOpacity,
                      logoScale: logoScale,
                      taglineOpacity: taglineOpacity,
                      shimmerController: shimmerController,
                      statusLine: statusLine,
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

class _WebLaunchPhotoPanel extends StatelessWidget {
  const _WebLaunchPhotoPanel();

  static const String _photo = 'assets/onboarding_preference.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Image.asset(
          _photo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WebLaunchActionPanel extends StatelessWidget {
  const _WebLaunchActionPanel({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
    required this.statusLine,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;
  final String statusLine;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: AuthAppLogo(fontSize: 16),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: logoOpacity,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car_filled,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: logoOpacity,
                      child: Text(
                        AppBrandingDefaults.displayName,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: taglineOpacity,
                      child: Text(
                        statusLine,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _LaunchShimmerBar(
                      controller: shimmerController,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
