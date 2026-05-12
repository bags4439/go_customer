import 'dart:math' show pi, sin;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/auth_split_layout.dart';
import '../../../../core/layout/dark_split_panel.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../data/login_web_content.dart';
import '../widgets/auth_visual_widgets.dart';
import '../../domain/entities/country.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/login_state.dart';
import '../providers/countries_providers.dart';
import '../providers/login_providers.dart';
import '../widgets/country_picker_sheet.dart';

// ─────────────────────────────────────────────────────────────
// LoginScreen
// ─────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
      if (next.nav == LoginNav.goHome && prev?.nav != LoginNav.goHome) {
        context.go('/home');
      }
    });

    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    final isWeb = ResponsiveLayout.isWeb(context);

    if (isWeb) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: false,
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
                      child: _LoginWebPhotoPanel(step: state.step),
                    ),
                    SizedBox(
                      width: 400,
                      child: _LoginWebActionPanel(
                        state: state,
                        notifier: notifier,
                        stepWidget: _stepWidget(state, notifier),
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

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: AuthSplitLayout(
        form: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(state.step),
                child: _stepWidget(state, notifier),
              ),
            ),
          ),
        ),
        panel: _panelForStep(state.step),
      ),
    );
  }

  /// Right-hand dark panel copy for tablet / web; mobile omits via
  /// [AuthSplitLayout].
  DarkSplitPanel _panelForStep(LoginStep step) {
    switch (step) {
      case LoginStep.phone:
      case LoginStep.otp:
        return const DarkSplitPanel(
          eyebrow: 'TRUSTED BY BUYERS ACROSS GHANA',
          heading: 'Your car, sourced globally.\nDelivered to your door.',
          subheading:
              'From US auctions to Dubai dealers — your dedicated agent '
              'manages everything so you don\'t have to.',
          stats: [
            DarkPanelStat(value: '48+', label: 'Vehicles imported'),
            DarkPanelStat(value: '100%', label: 'Transparent pricing'),
            DarkPanelStat(value: '4.9★', label: 'Customer rating'),
          ],
        );
      case LoginStep.name:
        return const DarkSplitPanel(
          heading: 'It all starts\nwith a name.',
          subheading:
              'Your agent is a real person who will be in touch personally '
              'throughout the import journey.',
          quote: DarkPanelQuote(
            initials: 'E',
            name: 'Ernest, your agent',
            text: '"I\'ll be handling your import personally."',
          ),
        );
      case LoginStep.referral:
        return const DarkSplitPanel(
          heading: 'Share the journey.',
          subheading:
              'Have a friend\'s referral code? Enter it to reward them for '
              'introducing you to AutoImport GH.',
          stats: [
            DarkPanelStat(value: 'GHS 500', label: 'Reward per referral'),
            DarkPanelStat(value: 'Instant', label: 'Credit on completion'),
          ],
        );
      case LoginStep.contactChannels:
        return const DarkSplitPanel(
          heading: 'Never miss\na moment.',
          subheading:
              'We\'ll notify you when things happen with your order via the '
              'channels you choose.',
          accentItems: [
            DarkPanelAccentItem(
              color: Color(0xFF378ADD),
              title: 'SMS',
              subtitle:
                  'Instant alerts for payment requests and key milestones.',
            ),
            DarkPanelAccentItem(
              color: Color(0xFF1D9E75),
              title: 'WhatsApp',
              subtitle: 'Rich updates with order details and agent messages.',
            ),
            DarkPanelAccentItem(
              color: Color(0xFFBA7517),
              title: 'Email',
              subtitle: 'Payment receipts and full order summaries.',
            ),
          ],
        );
    }
  }

  Widget _stepWidget(LoginState state, LoginNotifier notifier) {
    return switch (state.step) {
      LoginStep.phone => _PhoneStep(state: state, notifier: notifier),
      LoginStep.otp => _OtpStep(state: state, notifier: notifier),
      LoginStep.name => _NameStep(state: state, notifier: notifier),
      LoginStep.referral => _ReferralStep(state: state, notifier: notifier),
      LoginStep.contactChannels => _ContactChannelsStep(
        state: state,
        notifier: notifier,
      ),
    };
  }
}

/// Left panel for web login layout.
/// Full bleed photo, right-edge vignette,
/// optional step pill (setup steps),
/// and brand mark.
class _LoginWebPhotoPanel extends StatelessWidget {
  const _LoginWebPhotoPanel({required this.step});

  final LoginStep step;

  static const String _photo = 'assets/onboarding_preference.jpg';

  bool _isSetupStep() {
    switch (step) {
      case LoginStep.name:
      case LoginStep.referral:
      case LoginStep.contactChannels:
        return true;
      default:
        return false;
    }
  }

  String _stepLabel() {
    switch (step) {
      case LoginStep.name:
        return '1 of 3';
      case LoginStep.referral:
        return '2 of 3';
      case LoginStep.contactChannels:
        return '3 of 3';
      default:
        return '';
    }
  }

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
        if (!_isSetupStep())
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: _LoginPhotoPanelContent(step: step),
          ),
        if (_isSetupStep())
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _stepLabel(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    letterSpacing: .3,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AutoImport GH',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Right panel for web login layout.
/// Off-white #F5F4F0 background with
/// logo, optional progress bar,
/// and the existing step form widget
/// unchanged inside a scroll view.
class _LoginWebActionPanel extends StatelessWidget {
  const _LoginWebActionPanel({
    required this.state,
    required this.notifier,
    required this.stepWidget,
  });

  final LoginState state;
  // Reserved for future web-only actions; step widgets use notifier directly.
  // ignore: unused_field
  final LoginNotifier notifier;
  final Widget stepWidget;

  bool get _isSetupStep =>
      state.step == LoginStep.name ||
      state.step == LoginStep.referral ||
      state.step == LoginStep.contactChannels;

  double get _progressFraction {
    switch (state.step) {
      case LoginStep.name:
        return 1 / 3;
      case LoginStep.referral:
        return 2 / 3;
      case LoginStep.contactChannels:
        return 1.0;
      default:
        return 0;
    }
  }

  Color get _progressColor {
    switch (state.step) {
      case LoginStep.referral:
        return const Color(0xFF8C6B00);
      default:
        return AppColors.secondary;
    }
  }

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
                if (!_isSetupStep)
                  OutlinedButton(
                    onPressed: () => context.goNamed(RouteConstants.onboarding),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(color: AppColors.borderSolid, width: .5),
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
                      'Create account',
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
          if (_isSetupStep)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth * _progressFraction;
                  return Stack(
                    children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.borderSolid,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          width: barWidth,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _progressColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Expanded(child: stepWidget),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSetupStep
                      ? 'Already have an account? '
                      : 'New to AutoImport GH? ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed(
                    _isSetupStep
                        ? RouteConstants.login
                        : RouteConstants.onboarding,
                  ),
                  child: Text(
                    _isSetupStep ? 'Sign in' : 'Create account',
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

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

/// White elevated card for setup-step fields on web only.
Widget _loginWebFieldCard(BuildContext context, {required Widget child}) {
  if (!ResponsiveLayout.isWeb(context)) return child;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: child,
  );
}

class _AuthResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const _AuthResponsiveWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (ResponsiveLayout.isMobile(context))
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.07),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.contentMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: ResponsiveLayout.contentPadding(
                context,
              ).copyWith(top: 0, bottom: 40),
              child: ColoredBox(
                color: ResponsiveLayout.isWeb(context)
                    ? AppColors.surface
                    : Colors.white,
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;
  const _AuthPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: canTap ? const Color(0xFF378ADD) : const Color(0xFFE0DFD8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: canTap
              ? [
                  BoxShadow(
                    color: const Color(0xFF378ADD).withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey<String>('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        key: ValueKey<String>(label),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: canTap
                              ? Colors.white
                              : const Color(0xFFAAAAAA),
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

class _StyledTextField extends StatefulWidget {
  final String hintText;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final VoidCallback? onSubmit;
  final bool hasError;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  const _StyledTextField({
    required this.hintText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    this.onSubmit,
    this.hasError = false,
    this.autofocus = false,
    this.inputFormatters,
    this.controller,
  });

  @override
  State<_StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<_StyledTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: widget.hasError ? const Color(0xFFFCEBEB) : Colors.white,
        border: Border.all(
          color: widget.hasError
              ? const Color(0xFFE24B4A)
              : _focused
              ? const Color(0xFF378ADD)
              : const Color(0xFFE0DFD8),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        onFieldSubmitted: (_) => widget.onSubmit?.call(),
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: 15,
          color: const Color(0xFF1A1A18),
          height: null,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            color: const Color(0xFFAAAAAA),
            height: null,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

/// Tappable field that opens [CountryPickerSheet].
/// Matches [_StyledTextField] resting, error, and active (sheet open) borders.
class _CountryPickerField extends StatelessWidget {
  const _CountryPickerField({
    required this.selectedCountry,
    required this.onTap,
    this.hasError = false,
    this.isActive = false,
  });

  final Country? selectedCountry;
  final VoidCallback onTap;
  final bool hasError;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCountry != null;
    final borderFocused = isActive && !hasError;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF378ADD).withValues(alpha: 0.08),
        highlightColor: const Color(0xFF378ADD).withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFCEBEB) : Colors.white,
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE24B4A)
                  : borderFocused
                  ? const Color(0xFF378ADD)
                  : const Color(0xFFE0DFD8),
              width: (hasError || borderFocused) ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (hasSelection) ...[
                  Text(
                    selectedCountry!.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    hasSelection
                        ? selectedCountry!.name
                        : 'Select your country',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 15,
                      color: hasSelection
                          ? const Color(0xFF1A1A18)
                          : const Color(0xFFAAAAAA),
                      height: null,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFFAAAAAA),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium linear progress bar
/// shown on onboarding steps 3-5.
/// Animates smoothly between steps.
class _OnboardingProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _OnboardingProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = (current + 1) / total;
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: 3,
                color: AppColors.borderSolid,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * fraction,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Illustration painters ───────────────────────────────────

/// Phone step: circle + signal waves
class _PhoneIllustrationPainter extends CustomPainter {
  final Color color;
  const _PhoneIllustrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), 44, paint);

    final phonePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 34),
      const Radius.circular(5),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    final screenPaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 16, height: 22),
      const Radius.circular(2),
    );
    canvas.drawRRect(screenRect, screenPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      arcPaint.color = color.withValues(alpha: 1.0 - (i * 0.28));
      final radius = 54.0 + (i * 12.0);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx - 2, cy), radius: radius),
        -0.6,
        1.2,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PhoneIllustrationPainter old) => old.color != color;
}

/// OTP step: shield with checkmark
class _ShieldIllustrationPainter extends CustomPainter {
  final Color color;
  const _ShieldIllustrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final shield = Path();
    shield.moveTo(cx, cy - 40);
    shield.cubicTo(cx + 30, cy - 40, cx + 38, cy - 20, cx + 38, cy);
    shield.cubicTo(cx + 38, cy + 22, cx + 20, cy + 36, cx, cy + 44);
    shield.cubicTo(cx - 20, cy + 36, cx - 38, cy + 22, cx - 38, cy);
    shield.cubicTo(cx - 38, cy - 20, cx - 30, cy - 40, cx, cy - 40);
    shield.close();

    canvas.drawPath(
      shield,
      Paint()
        ..color = color.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      shield,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    final check = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path();
    checkPath.moveTo(cx - 14, cy + 2);
    checkPath.lineTo(cx - 4, cy + 12);
    checkPath.lineTo(cx + 14, cy - 10);
    canvas.drawPath(checkPath, check);
  }

  @override
  bool shouldRepaint(_ShieldIllustrationPainter old) => old.color != color;
}

/// Name step: person + location pin
class _PersonIllustrationPainter extends CustomPainter {
  final Color color;
  const _PersonIllustrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(
      Offset(cx, cy),
      46,
      Paint()
        ..color = color.withValues(alpha: 0.07)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(Offset(cx, cy), 46, stroke);

    canvas.drawCircle(Offset(cx, cy - 14), 13, fill);

    final body = Path();
    body.moveTo(cx - 18, cy + 36);
    body.quadraticBezierTo(cx - 20, cy + 10, cx, cy + 4);
    body.quadraticBezierTo(cx + 20, cy + 10, cx + 18, cy + 36);
    body.close();
    canvas.drawPath(body, fill);

    final pinCx = cx + 28.0;
    final pinCy = cy + 10.0;
    final pinFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final pinPath = Path();
    pinPath.addOval(
      Rect.fromCircle(center: Offset(pinCx, pinCy - 10), radius: 10),
    );
    pinPath.moveTo(pinCx - 4, pinCy - 2);
    pinPath.quadraticBezierTo(pinCx, pinCy + 12, pinCx + 4, pinCy - 2);
    canvas.drawPath(pinPath, pinFill);

    canvas.drawCircle(
      Offset(pinCx, pinCy - 10),
      4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PersonIllustrationPainter old) => old.color != color;
}

/// Referral step: two nodes connected
class _ReferralIllustrationPainter extends CustomPainter {
  final Color color;
  const _ReferralIllustrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final fadeFill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - 32, cy), 18, fadeFill);
    canvas.drawCircle(Offset(cx - 32, cy), 18, stroke);
    canvas.drawCircle(Offset(cx - 32, cy - 5), 6, fill);
    final leftBody = Path();
    leftBody.moveTo(cx - 42, cy + 14);
    leftBody.quadraticBezierTo(cx - 32, cy + 6, cx - 22, cy + 14);
    canvas.drawPath(leftBody, stroke);

    canvas.drawCircle(Offset(cx + 32, cy), 18, fadeFill);
    canvas.drawCircle(Offset(cx + 32, cy), 18, stroke);
    canvas.drawCircle(Offset(cx + 32, cy - 5), 6, fill);
    final rightBody = Path();
    rightBody.moveTo(cx + 22, cy + 14);
    rightBody.quadraticBezierTo(cx + 32, cy + 6, cx + 42, cy + 14);
    canvas.drawPath(rightBody, stroke);

    canvas.drawLine(Offset(cx - 14, cy), Offset(cx + 14, cy), stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 18),
        const Radius.circular(4),
      ),
      fill,
    );
    canvas.drawLine(
      Offset(cx, cy - 9),
      Offset(cx, cy + 9),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(cx - 10, cy),
      Offset(cx + 10, cy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 4, cy - 9), width: 12, height: 10),
      pi,
      pi,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 4, cy - 9), width: 12, height: 10),
      0,
      pi,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ReferralIllustrationPainter old) => old.color != color;
}

/// Stay in the loop step:
/// bell with notification ripples
class _BellIllustrationPainter extends CustomPainter {
  final Color color;
  const _BellIllustrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final bell = Path();
    bell.moveTo(cx, cy - 36);
    bell.cubicTo(cx + 26, cy - 36, cx + 32, cy - 16, cx + 32, cy + 4);
    bell.lineTo(cx + 38, cy + 14);
    bell.lineTo(cx - 38, cy + 14);
    bell.lineTo(cx - 32, cy + 4);
    bell.cubicTo(cx - 32, cy - 16, cx - 26, cy - 36, cx, cy - 36);
    bell.close();
    canvas.drawPath(bell, fill);

    canvas.drawLine(Offset(cx - 38, cy + 14), Offset(cx + 38, cy + 14), fill);

    canvas.drawCircle(Offset(cx, cy + 22), 8, fill);

    canvas.drawLine(Offset(cx, cy - 36), Offset(cx, cy - 44), stroke);

    final arcStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      arcStroke.color = color.withValues(alpha: 0.7 - (i * 0.22));
      final r = 52.0 + (i * 14.0);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy + 4), radius: r),
        -pi * 0.85,
        -pi * 0.3,
        false,
        arcStroke,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy + 4), radius: r),
        -pi * 0.15,
        -pi * 0.3,
        false,
        arcStroke,
      );
    }

    canvas.drawCircle(
      Offset(cx + 28, cy - 34),
      8,
      Paint()
        ..color = AppColors.danger
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BellIllustrationPainter old) => old.color != color;
}

/// Wrapper that animates an
/// illustration in with scale +
/// fade on step entry.
class _IllustrationWidget extends StatefulWidget {
  final CustomPainter painter;
  const _IllustrationWidget({required this.painter});

  @override
  State<_IllustrationWidget> createState() => _IllustrationWidgetState();
}

class _IllustrationWidgetState extends State<_IllustrationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: CustomPaint(painter: widget.painter, size: const Size(120, 120)),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSolid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String? error;
  const _InlineError({this.error});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: error != null
          ? Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFFE24B4A),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error!,
                      style: AppTextStyles.cardLabel.copyWith(
                        color: const Color(0xFFE24B4A),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

class _OtpInputRow extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onCompleted;
  final bool hasError;
  const _OtpInputRow({
    required this.onChanged,
    required this.onCompleted,
    required this.hasError,
  });

  @override
  State<_OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<_OtpInputRow>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
    setState(() {});
    if (_controller.text.length == 6) {
      widget.onCompleted();
    }
  }

  @override
  void didUpdateWidget(_OtpInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _controller.clear();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final offset = t < 1.0 ? sin(t * pi * 4) * 8 * (1 - t) : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const totalGap = 5 * 8.0;
                final boxW = ((constraints.maxWidth - totalGap) / 6).clamp(
                  0.0,
                  52.0,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final text = i < _controller.text.length
                        ? _controller.text[i]
                        : '';
                    final isFocused =
                        _focusNode.hasFocus &&
                        i == _controller.text.length &&
                        i < 6;
                    final isFilled = text.isNotEmpty;
                    return SizedBox(
                      width: boxW,
                      child: _OtpBox(
                        text: text,
                        isFocused: isFocused,
                        isFilled: isFilled,
                        hasError: widget.hasError,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String text;
  final bool isFocused;
  final bool isFilled;
  final bool hasError;
  const _OtpBox({
    required this.text,
    required this.isFocused,
    required this.isFilled,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, 52.0)
            : (((MediaQuery.sizeOf(context).width * 0.6) - (5 * 8.0)) / 6)
                  .clamp(0.0, 52.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: boxW,
          height: 56,
          decoration: BoxDecoration(
            color: hasError
                ? const Color(0xFFFCEBEB)
                : isFocused
                ? const Color(0xFFEBF4FD)
                : Colors.white,
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE24B4A)
                  : isFocused
                  ? const Color(0xFF378ADD)
                  : isFilled
                  ? const Color(0xFF378ADD)
                  : const Color(0xFFE0DFD8),
              width: (isFocused || hasError) ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF1A1A18),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneTermsRichText extends StatefulWidget {
  const _PhoneTermsRichText();

  @override
  State<_PhoneTermsRichText> createState() => _PhoneTermsRichTextState();
}

class _PhoneTermsRichTextState extends State<_PhoneTermsRichText> {
  late TapGestureRecognizer _termsTap;
  late TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _open('https://example.com/terms');
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _open('https://example.com/privacy');
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'By continuing you agree to our ',
            style: AppTextStyles.cardLabel.copyWith(
              color: const Color(0xFFAAAAAA),
            ),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: const Color(0xFF378ADD),
            ),
            recognizer: _termsTap,
          ),
          TextSpan(
            text: ' and ',
            style: AppTextStyles.cardLabel.copyWith(
              color: const Color(0xFFAAAAAA),
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: const Color(0xFF378ADD),
            ),
            recognizer: _privacyTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PhoneInputField extends ConsumerStatefulWidget {
  final String initialDigits;
  final String dialCode;
  final String countryFlag;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final void Function(String dialCode, String flag) onDialSelected;

  const _PhoneInputField({
    required this.initialDigits,
    required this.dialCode,
    required this.countryFlag,
    required this.onChanged,
    required this.onSubmit,
    required this.onDialSelected,
  });

  @override
  ConsumerState<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends ConsumerState<_PhoneInputField> {
  final _focus = FocusNode();
  late final TextEditingController _controller;
  bool _focused = false;
  bool _pickerOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDigits);
    _controller.addListener(() => widget.onChanged(_controller.text));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void didUpdateWidget(_PhoneInputField old) {
    super.didUpdateWidget(old);
    if (widget.initialDigits != old.initialDigits &&
        widget.initialDigits != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialDigits,
        selection: TextSelection.collapsed(offset: widget.initialDigits.length),
      );
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    setState(() => _pickerOpen = true);
    final country = await CountryPickerSheet.show(
      context,
      selectedIsoCode: '',
      sheetTitle: 'Select country code',
      sheetSubtitle: 'Choose your country to set the dial code.',
    );
    if (!mounted) return;
    setState(() => _pickerOpen = false);
    if (country != null && country.dialCode.isNotEmpty) {
      widget.onDialSelected(country.dialCode, country.flag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _focused || _pickerOpen
              ? AppColors.secondary
              : AppColors.borderSolid,
          width: (_focused || _pickerOpen) ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openPicker,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.countryFlag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.dialCode,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 26,
                      color: AppColors.borderSolid,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              onFieldSubmitted: (_) => widget.onSubmit(),
              textInputAction: TextInputAction.done,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                  height: null,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _PhoneFieldWithDialCode extends ConsumerStatefulWidget {
  final String initialDialCode;
  final String initialFlag;
  final String initialDigits;
  final void Function(String dialCode, String flag) onDialCodeChanged;
  final void Function(String digits) onDigitsChanged;
  final bool hasError;

  const _PhoneFieldWithDialCode({
    required this.initialDialCode,
    required this.initialFlag,
    required this.initialDigits,
    required this.onDialCodeChanged,
    required this.onDigitsChanged,
    this.hasError = false,
  });

  @override
  ConsumerState<_PhoneFieldWithDialCode> createState() =>
      _PhoneFieldWithDialCodeState();
}

class _PhoneFieldWithDialCodeState
    extends ConsumerState<_PhoneFieldWithDialCode> {
  final _focus = FocusNode();
  late final TextEditingController _controller;
  late String _dialCode;
  late String _flag;
  bool _focused = false;
  bool _pickerOpen = false;

  @override
  void initState() {
    super.initState();
    _dialCode = widget.initialDialCode;
    _flag = widget.initialFlag;
    _controller = TextEditingController(text: widget.initialDigits);
    _controller.addListener(() => widget.onDigitsChanged(_controller.text));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void didUpdateWidget(_PhoneFieldWithDialCode old) {
    super.didUpdateWidget(old);
    if (widget.initialDialCode != old.initialDialCode) {
      _dialCode = widget.initialDialCode;
    }
    if (widget.initialFlag != old.initialFlag) {
      _flag = widget.initialFlag;
    }
    if (widget.initialDigits != old.initialDigits &&
        widget.initialDigits != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialDigits,
        selection: TextSelection.collapsed(offset: widget.initialDigits.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _openDialCodePicker() async {
    setState(() => _pickerOpen = true);
    final country = await CountryPickerSheet.show(
      context,
      selectedIsoCode: '',
      sheetTitle: 'Select country code',
      sheetSubtitle: 'Choose the country for this phone number.',
    );
    if (!mounted) return;
    setState(() => _pickerOpen = false);
    if (country != null && country.dialCode.isNotEmpty) {
      setState(() {
        _dialCode = country.dialCode;
        _flag = country.flag;
      });
      widget.onDialCodeChanged(country.dialCode, country.flag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      decoration: BoxDecoration(
        color: widget.hasError ? AppColors.dangerMutedBackground : Colors.white,
        border: Border.all(
          color: widget.hasError
              ? AppColors.danger
              : _pickerOpen
              ? AppColors.secondary
              : AppColors.borderSolid,
          width: (widget.hasError || _focused || _pickerOpen) ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openDialCodePicker,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      _dialCode,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 26,
                      color: AppColors.borderSolid,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focus,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'XX XXX XXXX',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                  height: null,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Steps
// ─────────────────────────────────────────────────────────────

class _PhoneStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _PhoneStep({required this.state, required this.notifier});

  @override
  ConsumerState<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<_PhoneStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _logoFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _fieldFade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _logoSlide;
  late final Animation<double> _headingSlide;
  late final Animation<double> _fieldSlide;
  late final Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
    );
    _headingFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    );
    _fieldFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
    );
    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
    );
    _logoSlide = Tween<double>(begin: 0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _headingSlide = Tween<double>(begin: 0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _fieldSlide = Tween<double>(begin: 0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlide = Tween<double>(begin: 0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _animated(
    Widget child,
    Animation<double> fade,
    Animation<double> slideY,
  ) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slideY,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, slideY.value * MediaQuery.sizeOf(context).height),
          child: c,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final showError = state.error != null && state.step == LoginStep.phone;

    final phoneDigits = state.phone.replaceAll(RegExp(r'\D'), '');
    final phoneLooksComplete =
        phoneDigits.length >= 7 && phoneDigits.length <= 15;

    final isWeb = ResponsiveLayout.isWeb(context);

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isWeb) ...[
            const SizedBox(height: 60),
            _animated(
              Center(
                child: _IllustrationWidget(
                  painter: _PhoneIllustrationPainter(AppColors.secondary),
                ),
              ),
              _logoFade,
              _logoSlide,
            ),
            const SizedBox(height: 44),
          ] else
            const SizedBox(height: 24),
          _animated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb)
                  Text(
                    'SIGN IN',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: 9,
                      letterSpacing: .8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                if (isWeb) const SizedBox(height: 3),
                Text(
                  isWeb ? 'Welcome back.' : 'Enter your phone number',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: isWeb ? 22 : 24,
                    fontWeight: isWeb ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isWeb
                      ? 'Enter your phone number to receive a verification code.'
                      : 'We\'ll send a 6-digit verification code',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isWeb ? 12 : null,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 16),
          if (isWeb)
            _animated(
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _WebContextTiles(tiles: kLoginWebPanels['login']!.tiles),
              ),
              _fieldFade,
              _fieldSlide,
            ),
          if (!isWeb) const SizedBox(height: 16),
          _animated(
            _loginWebFieldCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE NUMBER',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFFAAAAAA),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PhoneInputField(
                    initialDigits: state.phone,
                    dialCode: state.dialCode,
                    countryFlag: state.countryFlag,
                    onChanged: notifier.updatePhone,
                    onSubmit: notifier.requestOtp,
                    onDialSelected: notifier.updateDialCode,
                  ),
                  _InlineError(error: showError ? state.error : null),
                  if (!showError) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.phone.isNotEmpty
                          ? 'Sending to ${state.dialCode} ${state.phone}'
                          : 'We\'ll send a code to this number',
                      style: AppTextStyles.cardLabel.copyWith(
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _fieldFade,
            _fieldSlide,
          ),
          const SizedBox(height: 28),
          _animated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AuthPrimaryButton(
                  label: 'Send verification code →',
                  isLoading: state.isLoading,
                  isEnabled: phoneLooksComplete,
                  onTap: notifier.requestOtp,
                ),
                const SizedBox(height: 24),
                const Center(child: _PhoneTermsRichText()),
              ],
            ),
            _buttonFade,
            _buttonSlide,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OtpStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _OtpStep({required this.state, required this.notifier});

  @override
  ConsumerState<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends ConsumerState<_OtpStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _backFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _headingSlide;
  late final Animation<double> _otpFade;
  late final Animation<double> _otpSlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _backFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.40, curve: Curves.easeOutCubic),
    );
    _headingFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.10, 0.55, curve: Curves.easeOutCubic),
    );
    _headingSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.10, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _otpFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    );
    _otpSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
    );
    _buttonSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeOnly(Widget child, Animation<double> fade) {
    return FadeTransition(opacity: fade, child: child);
  }

  Widget _fadeSlide(
    Widget child,
    Animation<double> fade,
    Animation<double> slideY,
  ) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slideY,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, slideY.value * MediaQuery.sizeOf(context).height),
          child: c,
        ),
        child: child,
      ),
    );
  }

  String _resendLabel(LoginState state) {
    final t = state.resendCountdown;
    final m = t ~/ 60;
    final s = t % 60;
    return 'Resend in $m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final isWeb = ResponsiveLayout.isWeb(context);
    final otpError = state.error != null && state.step == LoginStep.otp;

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: _fadeOnly(
              _BackButton(onTap: notifier.goBackToPhone),
              _backFade,
            ),
          ),
          const SizedBox(height: 28),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isWeb) ...[
                  Center(
                    child: _IllustrationWidget(
                      painter: _ShieldIllustrationPainter(AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
                if (isWeb)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Text(
                          '${state.dialCode} ${state.phone}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: notifier.goBackToPhone,
                          child: Text(
                            'Change',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isWeb)
                  Text(
                    'VERIFICATION',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: 9,
                      letterSpacing: .8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                if (isWeb) const SizedBox(height: 3),
                Text(
                  isWeb ? 'Enter your code.' : 'Enter verification code',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: isWeb ? 22 : 24,
                    fontWeight: isWeb ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isWeb)
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF666666),
                      ),
                      children: [
                        const TextSpan(text: 'Sent to '),
                        TextSpan(
                          text: '${state.dialCode} ${state.phone}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                        const TextSpan(text: '  ·  '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: notifier.goBackToPhone,
                            child: Text(
                              'Change',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isWeb) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Check your SMS for the 6-digit verification code.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 24),
          _fadeSlide(
            _loginWebFieldCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWeb) ...[
                    Text(
                      '6-DIGIT CODE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _OtpInputRow(
                    onChanged: notifier.updateOtp,
                    onCompleted: notifier.verifyOtp,
                    hasError: otpError,
                  ),
                ],
              ),
            ),
            _otpFade,
            _otpSlide,
          ),
          _InlineError(error: otpError ? state.error : null),
          const SizedBox(height: 32),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AuthPrimaryButton(
                  label: 'Verify →',
                  isLoading: state.isLoading,
                  isEnabled: state.otp.length == 6 && !state.isLoading,
                  onTap: notifier.verifyOtp,
                ),
                const SizedBox(height: 24),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.resendEnabled
                        ? GestureDetector(
                            key: const ValueKey<String>('resend_active'),
                            onTap: notifier.resendOtp,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Didn\'t receive a code? ',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Resend',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            key: const ValueKey<String>('resend_count'),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _resendLabel(state),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFFAAAAAA),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            _buttonFade,
            _buttonSlide,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NameStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _NameStep({required this.state, required this.notifier});

  @override
  ConsumerState<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<_NameStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _emojiScale;
  late final Animation<double> _emojiFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _headingSlide;
  late final Animation<double> _fieldFade;
  late final Animation<double> _fieldSlide;
  late final Animation<double> _countryFade;
  late final Animation<double> _countrySlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonSlide;
  late final TextEditingController _nameCtrl;
  Country? _selectedCountry;
  bool _countrySheetOpen = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.state.fullName);
    _nameCtrl.addListener(() => widget.notifier.updateFullName(_nameCtrl.text));
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emojiScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _emojiFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
    );
    _headingFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    );
    _headingSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _fieldFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
    );
    _fieldSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _countryFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.38, 0.88, curve: Curves.easeOutCubic),
    );
    _countrySlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.38, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
    );
    _buttonSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _ac.forward();
  }

  @override
  void didUpdateWidget(_NameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.fullName != oldWidget.state.fullName &&
        widget.state.fullName != _nameCtrl.text) {
      _nameCtrl.value = TextEditingValue(
        text: widget.state.fullName,
        selection: TextSelection.collapsed(
          offset: widget.state.fullName.length,
        ),
      );
    }
    if (widget.state.country.isEmpty &&
        oldWidget.state.country.isNotEmpty &&
        _selectedCountry != null) {
      _selectedCountry = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
    Widget child,
    Animation<double> fade,
    Animation<double> slideY,
  ) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slideY,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, slideY.value * MediaQuery.sizeOf(context).height),
          child: c,
        ),
        child: child,
      ),
    );
  }

  Future<void> _openCountryPicker() async {
    setState(() => _countrySheetOpen = true);
    final country = await CountryPickerSheet.show(
      context,
      selectedIsoCode: _selectedCountry?.isoCode ?? widget.state.country,
    );
    if (!mounted) return;
    setState(() {
      _countrySheetOpen = false;
      if (country != null) {
        _selectedCountry = country;
        widget.notifier.updateCountry(country.isoCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final loginStepName = state.step == LoginStep.name;
    final nameFieldHasError =
        loginStepName &&
        state.error != null &&
        state.error != 'Please select your country';
    final countryFieldHasError =
        loginStepName && state.error == 'Please select your country';
    final nameInlineError = nameFieldHasError ? state.error : null;
    final countryInlineError = countryFieldHasError ? state.error : null;

    final countriesAsync = ref.watch(countriesProvider);
    Country? displayCountry = _selectedCountry;
    if (displayCountry == null && state.country.isNotEmpty) {
      displayCountry = countriesAsync.maybeWhen(
        data: (list) {
          for (final c in list) {
            if (c.isoCode == state.country) return c;
          }
          return null;
        },
        orElse: () => null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!ResponsiveLayout.isWeb(context))
          const _OnboardingProgressBar(current: 0, total: 3),
        Expanded(
          child: _AuthResponsiveWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!ResponsiveLayout.isWeb(context)) ...[
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _emojiFade,
                    child: ScaleTransition(
                      scale: _emojiScale,
                      child: Center(
                        child: _IllustrationWidget(
                          painter: _PersonIllustrationPainter(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 24),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'It all starts\nwith a name.'
                            : 'What should we call you?',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: ResponsiveLayout.isWeb(context) ? 22 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'Your agent is a real person who will address '
                                  'you by name throughout your entire import '
                                  'journey.'
                            : 'Your agent will use your name to address you.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF666666),
                          fontSize: ResponsiveLayout.isWeb(context) ? 12 : null,
                        ),
                      ),
                    ],
                  ),
                  _headingFade,
                  _headingSlide,
                ),
                if (ResponsiveLayout.isWeb(context))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _WebContextTiles(
                      tiles: kLoginWebPanels['name']!.tiles,
                    ),
                  ),
                if (!ResponsiveLayout.isWeb(context))
                  const SizedBox(height: 32),
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 12),
                _fadeSlide(
                  _loginWebFieldCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FULL NAME',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFFAAAAAA),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StyledTextField(
                          hintText: 'e.g. Kwame Mensah',
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmit: notifier.completeProfile,
                          hasError: nameFieldHasError,
                          autofocus: true,
                        ),
                        _InlineError(error: nameInlineError),
                      ],
                    ),
                  ),
                  _fieldFade,
                  _fieldSlide,
                ),
                const SizedBox(height: 16),
                _fadeSlide(
                  _loginWebFieldCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COUNTRY',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFFAAAAAA),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CountryPickerField(
                          selectedCountry: displayCountry,
                          onTap: _openCountryPicker,
                          hasError: countryFieldHasError,
                          isActive: _countrySheetOpen,
                        ),
                        _InlineError(error: countryInlineError),
                      ],
                    ),
                  ),
                  _countryFade,
                  _countrySlide,
                ),
                const SizedBox(height: 32),
                _fadeSlide(
                  _AuthPrimaryButton(
                    label: 'Continue →',
                    isLoading: state.isLoading,
                    isEnabled:
                        state.fullName.trim().length >= 2 &&
                        state.country.isNotEmpty,
                    onTap: notifier.completeProfile,
                  ),
                  _buttonFade,
                  _buttonSlide,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferralStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _ReferralStep({required this.state, required this.notifier});

  @override
  ConsumerState<_ReferralStep> createState() => _ReferralStepState();
}

class _ReferralStepState extends ConsumerState<_ReferralStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _emojiScale;
  late final Animation<double> _emojiFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _headingSlide;
  late final Animation<double> _fieldFade;
  late final Animation<double> _fieldSlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonSlide;
  late final TextEditingController _codeCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.state.referralCode);
    _codeCtrl.addListener(
      () => widget.notifier.updateReferralCode(_codeCtrl.text),
    );
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emojiScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _emojiFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
    );
    _headingFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    );
    _headingSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _fieldFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
    );
    _fieldSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
    );
    _buttonSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _ac.forward();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
    Widget child,
    Animation<double> fade,
    Animation<double> slideY,
  ) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slideY,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, slideY.value * MediaQuery.sizeOf(context).height),
          child: c,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final empty = state.referralCode.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: ResponsiveLayout.contentPadding(
            context,
          ).copyWith(top: 16, bottom: 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(onTap: notifier.goBack),
          ),
        ),
        const SizedBox(height: 8),
        if (!ResponsiveLayout.isWeb(context))
          const _OnboardingProgressBar(current: 1, total: 3),
        Expanded(
          child: _AuthResponsiveWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!ResponsiveLayout.isWeb(context)) ...[
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _emojiFade,
                    child: ScaleTransition(
                      scale: _emojiScale,
                      child: Center(
                        child: _IllustrationWidget(
                          painter: _ReferralIllustrationPainter(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 24),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'Share the journey.\nEarn rewards.'
                            : 'Do you have a referral code?',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: ResponsiveLayout.isWeb(context) ? 22 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'If a friend referred you, enter their code. '
                                  'They earn a reward when you complete your '
                                  'first order.'
                            : 'Enter a friend\'s code — they\'ll get a reward when you join.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF666666),
                          fontSize: ResponsiveLayout.isWeb(context) ? 12 : null,
                        ),
                      ),
                    ],
                  ),
                  _headingFade,
                  _headingSlide,
                ),
                if (ResponsiveLayout.isWeb(context))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _WebContextTiles(
                      tiles: kLoginWebPanels['referral']!.tiles,
                    ),
                  ),
                if (!ResponsiveLayout.isWeb(context))
                  const SizedBox(height: 32),
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 12),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFERRAL CODE (OPTIONAL)',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFFAAAAAA),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StyledTextField(
                        hintText: 'e.g. A3K9PX',
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              r'[23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz]',
                            ),
                          ),
                          LengthLimitingTextInputFormatter(6),
                          _UpperCaseFormatter(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '6 characters — letters and numbers only',
                        style: AppTextStyles.cardLabel.copyWith(
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                  _fieldFade,
                  _fieldSlide,
                ),
                const SizedBox(height: 32),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthPrimaryButton(
                        label: empty ? 'Skip →' : 'Apply & continue →',
                        isLoading: false,
                        isEnabled: true,
                        onTap: notifier.proceedToContactChannels,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: notifier.skipReferral,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Skip',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFFAAAAAA),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buttonFade,
                  _buttonSlide,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactChannelsStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _ContactChannelsStep({required this.state, required this.notifier});

  @override
  ConsumerState<_ContactChannelsStep> createState() =>
      _ContactChannelsStepState();
}

class _ContactChannelsStepState extends ConsumerState<_ContactChannelsStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _emojiScale;
  late final Animation<double> _emojiFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _headingSlide;
  late final Animation<double> _fieldFade;
  late final Animation<double> _fieldSlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonSlide;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController(text: widget.state.email);

    _emailCtrl.addListener(
      () => widget.notifier.updateContactEmail(_emailCtrl.text),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = widget.notifier;
      final s = widget.state;
      n.updateSmsDialCode(s.dialCode, s.countryFlag);
      n.updateWhatsappDialCode(s.dialCode, s.countryFlag);
      final rawDigits = s.phone.replaceAll(RegExp(r'\D'), '');
      if (s.smsPhone.isEmpty && rawDigits.isNotEmpty) {
        n.updateSmsPhone(rawDigits);
      }
      if (s.whatsappPhone.isEmpty && rawDigits.isNotEmpty) {
        n.updateWhatsappPhone(rawDigits);
      }
      n.updateContactEmail(_emailCtrl.text);
    });

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emojiScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _emojiFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
    );
    _headingFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    );
    _headingSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _fieldFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
    );
    _fieldSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
    );
    _buttonSlide = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.45, 1.00, curve: Curves.easeOutCubic),
      ),
    );
    _ac.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
    Widget child,
    Animation<double> fade,
    Animation<double> slideY,
  ) {
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slideY,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, slideY.value * MediaQuery.sizeOf(context).height),
          child: c,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final hasError =
        state.error != null && state.step == LoginStep.contactChannels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: ResponsiveLayout.contentPadding(
            context,
          ).copyWith(top: 16, bottom: 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(onTap: notifier.goBack),
          ),
        ),
        const SizedBox(height: 8),
        if (!ResponsiveLayout.isWeb(context))
          const _OnboardingProgressBar(current: 2, total: 3),
        Expanded(
          child: _AuthResponsiveWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!ResponsiveLayout.isWeb(context)) ...[
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _emojiFade,
                    child: ScaleTransition(
                      scale: _emojiScale,
                      child: Center(
                        child: _IllustrationWidget(
                          painter: _BellIllustrationPainter(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 24),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'Never miss\na moment.'
                            : 'Stay in the loop',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: ResponsiveLayout.isWeb(context) ? 22 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ResponsiveLayout.isWeb(context)
                            ? 'We\'ll keep you updated on your order progress '
                                  'via the channels you choose.'
                            : 'We will keep you updated on your order progress. '
                                  'Your phone number has been pre-filled — update it if '
                                  'you use a different number for these channels.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF666666),
                          height: 1.5,
                          fontSize: ResponsiveLayout.isWeb(context) ? 12 : null,
                        ),
                      ),
                    ],
                  ),
                  _headingFade,
                  _headingSlide,
                ),
                if (ResponsiveLayout.isWeb(context))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _WebContextTiles(
                      tiles: kLoginWebPanels['contactChannels']!.tiles,
                    ),
                  ),
                if (!ResponsiveLayout.isWeb(context))
                  const SizedBox(height: 32),
                if (ResponsiveLayout.isWeb(context)) const SizedBox(height: 12),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loginWebFieldCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ContactFieldLabel(
                              label: 'SMS NUMBER',
                              isRequired: true,
                            ),
                            const SizedBox(height: 8),
                            _PhoneFieldWithDialCode(
                              initialDialCode: state.smsDialCode,
                              initialFlag: state.smsCountryFlag,
                              initialDigits: state.smsPhone,
                              onDialCodeChanged: (code, flag) =>
                                  notifier.updateSmsDialCode(code, flag),
                              onDigitsChanged: notifier.updateSmsPhone,
                              hasError:
                                  hasError &&
                                  state.smsPhone
                                      .replaceAll(RegExp(r'\D'), '')
                                      .isEmpty,
                            ),
                            _InlineError(
                              error:
                                  hasError &&
                                      state.smsPhone
                                          .replaceAll(RegExp(r'\D'), '')
                                          .isEmpty
                                  ? state.error
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _loginWebFieldCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ContactFieldLabel(
                              label: 'WHATSAPP NUMBER',
                              isRequired: false,
                            ),
                            const SizedBox(height: 8),
                            _PhoneFieldWithDialCode(
                              initialDialCode: state.whatsappDialCode,
                              initialFlag: state.whatsappCountryFlag,
                              initialDigits: state.whatsappPhone,
                              onDialCodeChanged: (code, flag) =>
                                  notifier.updateWhatsappDialCode(code, flag),
                              onDigitsChanged: notifier.updateWhatsappPhone,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Make sure this number has WhatsApp installed.',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _loginWebFieldCard(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ContactFieldLabel(
                              label: 'EMAIL ADDRESS',
                              isRequired: false,
                            ),
                            const SizedBox(height: 8),
                            _StyledTextField(
                              hintText: 'your@email.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmit: notifier.saveContactChannelsAndFinish,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Required for payment receipts. You will be '
                              'asked to add it before your first payment if '
                              'left empty.',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFFAAAAAA),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _fieldFade,
                  _fieldSlide,
                ),
                const SizedBox(height: 32),
                _fadeSlide(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthPrimaryButton(
                        label: 'Finish →',
                        isLoading: state.isLoading,
                        isEnabled: !state.isLoading,
                        onTap: notifier.saveContactChannelsAndFinish,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: state.isLoading
                              ? null
                              : notifier.skipContactChannelsAndFinish,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Skip for now',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFFAAAAAA),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buttonFade,
                  _buttonSlide,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Label for contact channel fields with required / optional hint.
class _ContactFieldLabel extends StatelessWidget {
  const _ContactFieldLabel({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFFAAAAAA),
            letterSpacing: 0.5,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Required',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(width: 6),
          Text(
            'Optional',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFFCCCCCC),
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }
}

/// Grouped context tiles shown
/// on the right action panel for
/// web setup steps.
/// Uses a coloured left border
/// accent to distinguish from
/// interactive form field cards.
class _WebContextTiles extends StatelessWidget {
  const _WebContextTiles({required this.tiles});

  final List<LoginWebTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECEAE4), width: .5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tiles.length; i++)
            _WebContextTile(tile: tiles[i], isFirst: i == 0),
        ],
      ),
    );
  }
}

class _WebContextTile extends StatelessWidget {
  const _WebContextTile({required this.tile, required this.isFirst});

  final LoginWebTile tile;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: tile.accentColor, width: 2.5),
          top: isFirst
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF0EFE9), width: .5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: tile.iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(tile.icon, size: 13, color: tile.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tile.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (tile.sublabel != null)
                  Text(
                    tile.sublabel!,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textTertiary,
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

/// Content overlaid on the photo
/// panel for login and OTP steps.
/// Shows eyebrow, heading,
/// subheading and accent-border
/// tiles on the dark photo.
class _LoginPhotoPanelContent extends StatelessWidget {
  const _LoginPhotoPanelContent({required this.step});

  final LoginStep step;

  @override
  Widget build(BuildContext context) {
    assert(
      step == LoginStep.phone || step == LoginStep.otp,
      '_LoginPhotoPanelContent is only for phone/otp steps',
    );
    final panel = kLoginWebPanels['login']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          panel.eyebrow,
          style: AppTextStyles.sectionLabel.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 9,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          panel.heading,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          panel.subheading,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: .5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < panel.tiles.length; i++)
                _DarkContextTile(tile: panel.tiles[i], isFirst: i == 0),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single context tile rendered
/// on the dark photo panel.
/// Uses white-tinted colours
/// instead of coloured backgrounds.
class _DarkContextTile extends StatelessWidget {
  const _DarkContextTile({required this.tile, required this.isFirst});

  final LoginWebTile tile;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: tile.accentColor, width: 2.5),
          top: isFirst
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: .5,
                ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: tile.accentColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              tile.icon,
              size: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tile.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (tile.sublabel != null)
                  Text(
                    tile.sublabel!,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.55),
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
