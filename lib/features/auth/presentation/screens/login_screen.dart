import 'dart:math' show pi, sin;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/acquisition_layout.dart';
import '../data/login_web_content.dart';
import '../widgets/auth_visual_widgets.dart';
import '../../domain/entities/country.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/login_state.dart';
import '../providers/countries_providers.dart';
import '../providers/login_providers.dart';
import '../providers/referral_login_tiles_provider.dart';
import '../providers/returning_user_provider.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/mobile_auth_shell.dart';
import '../widgets/phone_dial_input_field.dart';

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
    final useWeb = AcquisitionLayout.useWebLayout(context);

    return _LoginSessionHydrator(
      child: useWeb
          ? Scaffold(
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
      )
          : Scaffold(
              backgroundColor: AcquisitionLayout.usePhoneLayout(context)
                  ? (AcquisitionLayout.isPortraitTablet(context)
                      ? AppColors.surface
                      : AppColors.background)
                  : Colors.white,
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
    );
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
        return AppColors.warningDark;
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
            child: const Row(
              children: [
                AuthAppLogo(fontSize: 16),
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
          if (_isSetupStep)
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
                    'Already have an account? ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed(RouteConstants.login),
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

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

/// White elevated card for setup-step fields on web only.
Widget _loginWebFieldCard(BuildContext context, {required Widget child}) {
  if (!AcquisitionLayout.useWebLayout(context)) return child;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: ColoredBox(
        color: AppColors.surface,
        child: child,
      ),
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
          color: canTap ? AppColors.brand : AppColors.borderSolid,
          borderRadius: AppTheme.pillBorderRadius(52),
          boxShadow: canTap
              ? [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.30),
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
            borderRadius: AppTheme.pillBorderRadius(52),
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
                              : AppColors.textTertiary,
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
        color: widget.hasError ? AppColors.dangerMutedBackground : Colors.white,
        border: Border.all(
          color: widget.hasError
              ? AppColors.danger
              : _focused
              ? AppColors.brand
              : AppColors.borderSolid,
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
          color: AppColors.textPrimary,
          height: null,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            color: AppColors.textTertiary,
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
        splashColor: AppColors.brand.withValues(alpha: 0.08),
        highlightColor: AppColors.brand.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: hasError ? AppColors.dangerMutedBackground : Colors.white,
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : borderFocused
                  ? AppColors.brand
                  : AppColors.borderSolid,
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
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      height: null,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
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
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error!,
                      style: AppTextStyles.cardLabel.copyWith(
                        color: AppColors.danger,
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
                ? AppColors.dangerMutedBackground
                : isFocused
                ? AppColors.brandMuted
                : Colors.white,
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : isFocused
                  ? AppColors.brand
                  : isFilled
                  ? AppColors.brand
                  : AppColors.borderSolid,
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
                    ? AppColors.danger
                    : AppColors.textPrimary,
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
              color: AppColors.textTertiary,
            ),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: AppColors.brand,
            ),
            recognizer: _termsTap,
          ),
          TextSpan(
            text: ' and ',
            style: AppTextStyles.cardLabel.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: AppColors.brand,
            ),
            recognizer: _privacyTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
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
  late final Animation<double> _headingFade;
  late final Animation<double> _fieldFade;
  late final Animation<double> _buttonFade;
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

    final isWeb = AcquisitionLayout.useWebLayout(context);
    final loginPanel = kLoginWebPanels['login']!;
    final isReturning =
        ref.watch(isReturningLoginUserProvider).valueOrNull ?? false;
    final welcomeCopy = loginPhoneWelcomeCopy(isReturning: isReturning);

    if (!isWeb) {
      return MobileAuthShell(
        panel: loginPanel,
        title: welcomeCopy.title,
        subtitle: welcomeCopy.subtitle,
        trustTiles: loginTrustTilesForPhone(),
        showEyebrow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _animated(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE NUMBER',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PhoneDialInputField(
                    dialCode: state.dialCode,
                    countryFlag: state.countryFlag,
                    initialDigits: state.phone,
                    onDigitsChanged: notifier.updatePhone,
                    onSubmit: notifier.requestOtp,
                    onDialCodeChanged: notifier.updateDialCode,
                    autofocus: true,
                    pickerSubtitle:
                        'Choose your country to set the dial code.',
                  ),
                  _InlineError(error: showError ? state.error : null),
                  if (!showError) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.phone.isNotEmpty
                          ? 'Sending to ${state.dialCode} ${state.phone}'
                          : 'We\'ll send a code to this number',
                      style: AppTextStyles.cardLabel.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
              _fieldFade,
              _fieldSlide,
            ),
            const SizedBox(height: 24),
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
                  const SizedBox(height: 16),
                  const Center(child: _PhoneTermsRichText()),
                ],
              ),
              _buttonFade,
              _buttonSlide,
            ),
          ],
        ),
      );
    }

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _animated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIGN IN',
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontSize: 9,
                    letterSpacing: .8,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  welcomeCopy.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  welcomeCopy.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 16),
          _animated(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _WebContextTiles(tiles: loginTrustTilesForWeb()),
            ),
            _fieldFade,
            _fieldSlide,
          ),
          _animated(
            _loginWebFieldCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE NUMBER',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PhoneDialInputField(
                    dialCode: state.dialCode,
                    countryFlag: state.countryFlag,
                    initialDigits: state.phone,
                    onDigitsChanged: notifier.updatePhone,
                    onSubmit: notifier.requestOtp,
                    onDialCodeChanged: notifier.updateDialCode,
                    autofocus: true,
                    pickerSubtitle:
                        'Choose your country to set the dial code.',
                  ),
                  _InlineError(error: showError ? state.error : null),
                  if (!showError) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.phone.isNotEmpty
                          ? 'Sending to ${state.dialCode} ${state.phone}'
                          : 'We\'ll send a code to this number',
                      style: AppTextStyles.cardLabel.copyWith(
                        color: AppColors.textTertiary,
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
    final isWeb = AcquisitionLayout.useWebLayout(context);
    final otpError = state.error != null && state.step == LoginStep.otp;
    final loginPanel = kLoginWebPanels['login']!;

    if (!isWeb) {
      return MobileAuthShell(
        panel: loginPanel,
        title: 'Enter your code.',
        subtitle: 'Check your SMS for the 6-digit verification code.',
        showTrustTiles: false,
        showEyebrow: false,
        onBack: notifier.goBackToPhone,
        headerExtra: Text.rich(
          TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Sent to '),
              TextSpan(
                text: '${state.dialCode} ${state.phone}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fadeSlide(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6-DIGIT CODE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _OtpInputRow(
                    onChanged: notifier.updateOtp,
                    onCompleted: notifier.verifyOtp,
                    hasError: otpError,
                  ),
                ],
              ),
              _otpFade,
              _otpSlide,
            ),
            _InlineError(error: otpError ? state.error : null),
            const SizedBox(height: 24),
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
                  const SizedBox(height: 12),
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
                                          color: AppColors.textSecondary,
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
                                  color: AppColors.textTertiary,
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
          ],
        ),
      );
    }

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
                          color: AppColors.textTertiary,
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
                Text(
                  'VERIFICATION',
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontSize: 9,
                    letterSpacing: .8,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Enter your code.',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Check your SMS for the 6-digit verification code.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
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
                  Text(
                    '6-DIGIT CODE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                        color: AppColors.textSecondary,
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
                                color: AppColors.textTertiary,
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

    final isWeb = AcquisitionLayout.useWebLayout(context);
    final namePanel = kLoginWebPanels['name']!;

    if (!isWeb) {
      return MobileAuthShell(
        panel: namePanel,
        setupStepCurrent: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fadeSlide(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FULL NAME',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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
              _fieldFade,
              _fieldSlide,
            ),
            const SizedBox(height: 16),
            _fadeSlide(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COUNTRY',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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
              _countryFade,
              _countrySlide,
            ),
            const SizedBox(height: 24),
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
          ],
        ),
      );
    }

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'It all starts\nwith a name.',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your agent is a real person who will address '
                  'you by name throughout your entire import '
                  'journey.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _WebContextTiles(tiles: namePanel.tiles),
          ),
          const SizedBox(height: 12),
          _fadeSlide(
            _loginWebFieldCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FULL NAME',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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
                      color: AppColors.textTertiary,
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

    final isWeb = AcquisitionLayout.useWebLayout(context);
    final referralPanel = kLoginWebPanels['referral']!;
    final referralTiles = ref.watch(referralLoginTrustTilesProvider);

    if (!isWeb) {
      return MobileAuthShell(
        panel: referralPanel,
        setupStepCurrent: 1,
        onBack: notifier.goBack,
        trustTiles: referralTiles,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fadeSlide(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REFERRAL CODE (OPTIONAL)',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
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
                    '6 characters, letters and numbers only',
                    style: AppTextStyles.cardLabel.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              _fieldFade,
              _fieldSlide,
            ),
            const SizedBox(height: 24),
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
                  const SizedBox(height: 8),
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
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buttonFade,
              _buttonSlide,
            ),
          ],
        ),
      );
    }

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referralPanel.heading,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  referralPanel.subheading,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _WebContextTiles(tiles: referralTiles),
          ),
          const SizedBox(height: 12),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REFERRAL CODE (OPTIONAL)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
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
                  '6 characters, letters and numbers only',
                  style: AppTextStyles.cardLabel.copyWith(
                    color: AppColors.textTertiary,
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
                        color: AppColors.textTertiary,
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

    final isWeb = AcquisitionLayout.useWebLayout(context);
    final contactPanel = kLoginWebPanels['contactChannels']!;

    if (!isWeb) {
      return MobileAuthShell(
        panel: contactPanel,
        setupStepCurrent: 2,
        onBack: notifier.goBack,
        showTrustTiles: false,
        subtitle:
            'We\'ll keep you updated on your order progress via the '
            'channels you choose. Your phone number has been pre-filled.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fadeSlide(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ContactFieldLabel(
                    label: 'SMS NUMBER',
                    isRequired: true,
                  ),
                  const SizedBox(height: 8),
                  PhoneDialInputField(
                    dialCode: state.smsDialCode,
                    countryFlag: state.smsCountryFlag,
                    initialDigits: state.smsPhone,
                    onDialCodeChanged: notifier.updateSmsDialCode,
                    onDigitsChanged: notifier.updateSmsPhone,
                    hasError:
                        hasError &&
                        state.smsPhone.replaceAll(RegExp(r'\D'), '').isEmpty,
                    pickerSubtitle:
                        'Choose the country for this phone number.',
                  ),
                  _InlineError(
                    error:
                        hasError &&
                            state.smsPhone.replaceAll(RegExp(r'\D'), '')
                                .isEmpty
                        ? state.error
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const _ContactFieldLabel(
                    label: 'WHATSAPP NUMBER',
                    isRequired: false,
                  ),
                  const SizedBox(height: 8),
                  PhoneDialInputField(
                    dialCode: state.whatsappDialCode,
                    countryFlag: state.whatsappCountryFlag,
                    initialDigits: state.whatsappPhone,
                    onDialCodeChanged: notifier.updateWhatsappDialCode,
                    onDigitsChanged: notifier.updateWhatsappPhone,
                    hintText: 'XX XXX XXXX',
                    pickerSubtitle:
                        'Choose the country for this phone number.',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Make sure this number has WhatsApp installed.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              _fieldFade,
              _fieldSlide,
            ),
            const SizedBox(height: 24),
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
                  const SizedBox(height: 8),
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
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buttonFade,
              _buttonSlide,
            ),
          ],
        ),
      );
    }

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Never miss\na moment.',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We\'ll keep you updated on your order progress '
                  'via the channels you choose.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 16),
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
                      PhoneDialInputField(
                        dialCode: state.smsDialCode,
                        countryFlag: state.smsCountryFlag,
                        initialDigits: state.smsPhone,
                        onDialCodeChanged: notifier.updateSmsDialCode,
                        onDigitsChanged: notifier.updateSmsPhone,
                        hasError:
                            hasError &&
                            state.smsPhone
                                .replaceAll(RegExp(r'\D'), '')
                                .isEmpty,
                        pickerSubtitle:
                            'Choose the country for this phone number.',
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
                      PhoneDialInputField(
                        dialCode: state.whatsappDialCode,
                        countryFlag: state.whatsappCountryFlag,
                        initialDigits: state.whatsappPhone,
                        onDialCodeChanged: notifier.updateWhatsappDialCode,
                        onDigitsChanged: notifier.updateWhatsappPhone,
                        hintText: 'XX XXX XXXX',
                        pickerSubtitle:
                            'Choose the country for this phone number.',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Make sure this number has WhatsApp installed.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
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
                          color: AppColors.textTertiary,
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
                        color: AppColors.textTertiary,
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
            color: AppColors.textTertiary,
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
              color: AppColors.textCaption,
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
        color: AppColors.referralTileBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.referralTileBorder, width: .5),
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
              : const BorderSide(color: AppColors.hoverSurface, width: .5),
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
                  style: AppTextStyles.labelMedium.copyWith(
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

class _LoginSessionHydrator extends ConsumerStatefulWidget {
  const _LoginSessionHydrator({required this.child});

  final Widget child;

  @override
  ConsumerState<_LoginSessionHydrator> createState() =>
      _LoginSessionHydratorState();
}

class _LoginSessionHydratorState extends ConsumerState<_LoginSessionHydrator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginNotifierProvider.notifier).hydrateRegistrationFromSession();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}