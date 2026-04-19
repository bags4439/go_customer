import 'dart:math' show pi, sin;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/cross_platform_image.dart';
import '../../../../core/utils/responsive_layout.dart';
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
      if (next.nav == LoginNav.goHome &&
          prev?.nav != LoginNav.goHome) {
        context.go('/home');
      }
    });

    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return SlideTransition(
              position: slide,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(state.step),
            child: _stepWidget(state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(
    LoginState state,
    LoginNotifier notifier,
  ) {
    return switch (state.step) {
      LoginStep.phone =>
        _PhoneStep(state: state, notifier: notifier),
      LoginStep.otp =>
        _OtpStep(state: state, notifier: notifier),
      LoginStep.name =>
        _NameStep(state: state, notifier: notifier),
      LoginStep.referral =>
        _ReferralStep(state: state, notifier: notifier),
      LoginStep.ghanaCard =>
        _GhanaCardStep(state: state, notifier: notifier),
    };
  }
}

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

class _AuthResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const _AuthResponsiveWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: SingleChildScrollView(
          padding: ResponsiveLayout.contentPadding(context)
              .copyWith(top: 0, bottom: 40),
          child: child,
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  final double fontSize;
  const _AppLogo({this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: fontSize * 1.4,
          height: fontSize * 1.4,
          decoration: BoxDecoration(
            color: const Color(0xFF378ADD),
            borderRadius: BorderRadius.circular(fontSize * 0.28),
          ),
          child: Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: fontSize * 0.82,
          ),
        ),
        SizedBox(width: fontSize * 0.36),
        Text(
          'AutoImport',
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A18),
          ),
        ),
        Text(
          ' GH',
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF378ADD),
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
          color: canTap
              ? const Color(0xFF378ADD)
              : const Color(0xFFE0DFD8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: canTap
              ? [
                  BoxShadow(
                    color: const Color(0xFF378ADD)
                        .withValues(alpha: 0.30),
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
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
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
  final VoidCallback? onSubmit;
  final bool hasError;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  const _StyledTextField({
    required this.hintText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
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
      height: 56,
      decoration: BoxDecoration(
        color: widget.hasError
            ? const Color(0xFFFCEBEB)
            : Colors.white,
        border: Border.all(
          color: widget.hasError
              ? const Color(0xFFE24B4A)
              : _focused
                  ? const Color(0xFF378ADD)
                  : const Color(0xFFE0DFD8),
          width: (_focused || widget.hasError) ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        onFieldSubmitted: (_) => widget.onSubmit?.call(),
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF1A1A18),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 15,
            color: const Color(0xFFAAAAAA),
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
            color: hasError
                ? const Color(0xFFFCEBEB)
                : Colors.white,
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
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: hasSelection
                          ? const Color(0xFF1A1A18)
                          : const Color(0xFFAAAAAA),
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

class _OnboardingProgress extends StatelessWidget {
  final int current;
  final int total;
  const _OnboardingProgress({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final isDone = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: (isDone || isActive)
                ? const Color(0xFF378ADD)
                : const Color(0xFFE0DFD8),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0DFD8)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: Color(0xFF666666),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
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
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
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
        final offset = t < 1.0
            ? sin(t * pi * 4) * 8 * (1 - t)
            : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final text = i < _controller.text.length
                    ? _controller.text[i]
                    : '';
                final isFocused = _focusNode.hasFocus &&
                    i == _controller.text.length &&
                    i < 6;
                final isFilled = text.isNotEmpty;
                return _OtpBox(
                  text: text,
                  isFocused: isFocused,
                  isFilled: isFilled,
                  hasError: widget.hasError,
                );
              }),
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
    final padding = ResponsiveLayout.contentPadding(context);
    final screenW = MediaQuery.sizeOf(context).width;
    final maxContent = ResponsiveLayout.contentMaxWidth(context);
    final contentW =
        maxContent.isFinite ? maxContent : screenW;
    final availableW = contentW - padding.horizontal - (5 * 8.0);
    final boxW = (availableW / 6).clamp(0.0, 52.0);

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
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: hasError
                ? const Color(0xFFE24B4A)
                : const Color(0xFF1A1A18),
          ),
        ),
      ),
    );
  }
}

class _GhanaCardPhotoField extends StatelessWidget {
  final String? photoPath;
  final bool isUploading;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;
  const _GhanaCardPhotoField({
    required this.photoPath,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  Future<void> _pickPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(
                'Take a photo',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(
                'Choose from gallery',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (file != null && context.mounted) {
      onPick(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: isUploading ? null : () => _pickPhoto(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4F0),
              border: Border.all(color: const Color(0xFFE0DFD8)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: photoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        buildLocalImage(
                          photoPath!,
                          fit: BoxFit.cover,
                        ),
                        if (isUploading)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF378ADD),
                              ),
                              minHeight: 3,
                            ),
                          ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 32,
                        color: Color(0xFFAAAAAA),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to upload',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      Text(
                        'Camera or gallery',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (photoPath != null && !isUploading)
          Positioned(
            top: -8,
            right: -8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClear,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE24B4A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
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
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF378ADD),
            ),
            recognizer: _termsTap,
          ),
          TextSpan(
            text: ' and ',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

class _PhoneInputField extends StatefulWidget {
  final String initialDigits;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  const _PhoneInputField({
    required this.initialDigits,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  final _focus = FocusNode();
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDigits);
    _controller.addListener(() => widget.onChanged(_controller.text));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void didUpdateWidget(_PhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDigits != oldWidget.initialDigits &&
        widget.initialDigits != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialDigits,
        selection:
            TextSelection.collapsed(offset: widget.initialDigits.length),
      );
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _focused
              ? const Color(0xFF378ADD)
              : const Color(0xFFE0DFD8),
          width: _focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇬🇭', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '+233',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE0DFD8),
                ),
              ],
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
                LengthLimitingTextInputFormatter(9),
              ],
              onFieldSubmitted: (_) => widget.onSubmit(),
              textInputAction: TextInputAction.done,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1A18),
              ),
              decoration: InputDecoration(
                hintText: 'XX XXX XXXX',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
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
    final showError =
        state.error != null && state.step == LoginStep.phone;

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 52),
          _animated(
            const Center(child: _AppLogo(fontSize: 26)),
            _logoFade,
            _logoSlide,
          ),
          const SizedBox(height: 44),
          _animated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your phone number',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We\'ll send a 6-digit verification code',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 32),
          _animated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHONE NUMBER',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _PhoneInputField(
                  initialDigits: state.phone,
                  onChanged: notifier.updatePhone,
                  onSubmit: notifier.requestOtp,
                ),
                _InlineError(error: showError ? state.error : null),
                if (!showError) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.phone.length == 9
                        ? 'Sending to +233 ${state.phone}'
                        : 'We\'ll send a code to this number',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ],
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
                  isEnabled: state.phone.length == 9,
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
    final otpError =
        state.error != null && state.step == LoginStep.otp;

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
          const SizedBox(height: 36),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter verification code',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                    children: [
                      const TextSpan(text: 'Sent to '),
                      TextSpan(
                        text: '+233 ${state.phone}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
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
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF378ADD),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 36),
          _fadeSlide(
            _OtpInputRow(
              onChanged: notifier.updateOtp,
              onCompleted: notifier.verifyOtp,
              hasError: otpError,
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
                  isEnabled:
                      state.otp.length == 6 && !state.isLoading,
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
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Resend',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF378ADD),
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
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
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
    _nameCtrl.addListener(
      () => widget.notifier.updateFullName(_nameCtrl.text),
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
      selectedIsoCode:
          _selectedCountry?.isoCode ?? widget.state.country,
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
    final nameFieldHasError = loginStepName &&
        state.error != null &&
        state.error != 'Please select your country';
    final countryFieldHasError =
        loginStepName && state.error == 'Please select your country';
    final nameInlineError = nameFieldHasError ? state.error : null;
    final countryInlineError =
        countryFieldHasError ? state.error : null;

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

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Center(
            child: _OnboardingProgress(current: 0, total: 3),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _emojiFade,
            child: ScaleTransition(
              scale: _emojiScale,
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What should we call you?',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your agent will use your name to address you.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 32),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FULL NAME',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
            _countryFade,
            _countrySlide,
          ),
          const SizedBox(height: 32),
          _fadeSlide(
            _AuthPrimaryButton(
              label: 'Continue →',
              isLoading: state.isLoading,
              isEnabled: state.fullName.trim().length >= 2 &&
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

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Center(
            child: _OnboardingProgress(current: 1, total: 3),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _emojiFade,
            child: ScaleTransition(
              scale: _emojiScale,
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do you have a referral code?',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter a friend\'s code — they\'ll get a reward when you join.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 32),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REFERRAL CODE (OPTIONAL)',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
                  onTap: notifier.proceedToGhanaCard,
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
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
    );
  }
}

class _GhanaCardStep extends ConsumerStatefulWidget {
  final LoginState state;
  final LoginNotifier notifier;
  const _GhanaCardStep({required this.state, required this.notifier});

  @override
  ConsumerState<_GhanaCardStep> createState() => _GhanaCardStepState();
}

class _GhanaCardStepState extends ConsumerState<_GhanaCardStep>
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
  late final TextEditingController _cardCtrl;

  @override
  void initState() {
    super.initState();
    _cardCtrl = TextEditingController(text: widget.state.ghanaCardNumber);
    _cardCtrl.addListener(
      () => widget.notifier.updateGhanaCardNumber(_cardCtrl.text),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notifier.updateIdDocumentType(
        widget.state.country == 'GH' ? 'ghana_card' : 'passport',
      );
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
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
    final isGhanaian = state.country == 'GH';
    final docLabel = isGhanaian ? 'Ghana Card' : 'Passport';
    final numberLabel = isGhanaian
        ? 'GHANA CARD NUMBER (OPTIONAL)'
        : 'PASSPORT NUMBER (OPTIONAL)';
    final numberHint = isGhanaian ? 'GHA-XXXXXXXXX-X' : 'A12345678';
    final photoLabel = isGhanaian
        ? 'PHOTO OF GHANA CARD (OPTIONAL)'
        : 'PHOTO OF PASSPORT (OPTIONAL)';
    final emoji = isGhanaian ? '🪪' : '🛂';
    final cardError = state.error != null &&
        state.step == LoginStep.ghanaCard;

    return _AuthResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Center(
            child: _OnboardingProgress(current: 2, total: 3),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _emojiFade,
            child: ScaleTransition(
              scale: _emojiScale,
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 44),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your identity',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add your $docLabel to help your agent verify your '
                  'identity. Optional — you can do this from your profile '
                  'anytime.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            _headingFade,
            _headingSlide,
          ),
          const SizedBox(height: 32),
          _fadeSlide(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  numberLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _StyledTextField(
                  hintText: numberHint,
                  controller: _cardCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                Text(
                  photoLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _GhanaCardPhotoField(
                  photoPath: state.ghanaCardPhotoPath,
                  isUploading: state.isUploadingPhoto,
                  onPick: notifier.setGhanaCardPhoto,
                  onClear: notifier.clearGhanaCardPhoto,
                ),
                _InlineError(error: cardError ? state.error : null),
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
                  label: state.isUploadingPhoto
                      ? 'Uploading...'
                      : 'Save & finish →',
                  isLoading: state.isLoading,
                  isEnabled: !state.isLoading,
                  onTap: notifier.saveGhanaCardAndFinish,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed:
                        state.isLoading ? null : notifier.skipGhanaCardAndFinish,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
    );
  }
}
