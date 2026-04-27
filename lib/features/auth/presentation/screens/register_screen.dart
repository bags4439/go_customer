import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_visual_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();

  late final AnimationController _introController;

  static const Color _primary = Color(0xFF378ADD);
  static const Color _border = Color(0xFFE0DFD8);
  static const Color _textPrimary = Color(0xFF1A1A18);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _textTertiary = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    final form = ref.read(registrationFormProvider);
    _nameController = TextEditingController(text: form.fullName);
    _phoneController = TextEditingController(text: form.phoneDigits);
    _locationController = TextEditingController(text: form.location);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    void refresh() => setState(() {});
    _nameFocus.addListener(refresh);
    _phoneFocus.addListener(refresh);
    _locationFocus.addListener(refresh);
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
    parent: _introController,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  Widget _entrance(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _locationFocus.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = ref.read(registrationFormProvider);
    final phoneDigits = form.phoneDigits.replaceAll(RegExp(r'[^0-9]'), '');
    if (form.fullName.trim().isEmpty ||
        form.location.trim().isEmpty ||
        phoneDigits.length < 9) {
      showAuthSnackBar(context, 'Please enter valid registration details.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref
        .read(startPhoneVerificationUseCaseProvider)
        .call(phoneNumber: form.fullPhone);
    if (!mounted) return;
    result.fold((failure) => showFailureSnackBar(context, failure), (session) {
      ref.read(otpVerificationSessionProvider.notifier).state = session;
      ref.read(otpAttemptCountProvider.notifier).state = 0;
      ref.read(otpCountdownControllerProvider).start();
      context.goNamed(
        RouteConstants.otpVerification,
        extra: {'register': true},
      );
    });
    if (mounted) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  String _countryLabel(String code) {
    switch (code) {
      case '+234':
        return '🇳🇬  +234';
      case '+1':
        return '🇺🇸  +1';
      default:
        return '🇬🇭  +233';
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registrationFormProvider);
    final phoneFocused = _phoneFocus.hasFocus;

    final logoAnim = _interval(0.0, 0.5);
    final headAnim = _interval(0.12, 0.62);
    final nameAnim = _interval(0.22, 0.72);
    final phoneAnim = _interval(0.32, 0.82);
    final locAnim = _interval(0.38, 0.88);
    final firstAnim = _interval(0.42, 0.92);
    final btnAnim = _interval(0.48, 1.0);
    final footerAnim = _interval(0.52, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: _textSecondary,
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.contentMaxWidth(context),
              ),
              child: Padding(
                padding: ResponsiveLayout.contentPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _entrance(
                      logoAnim,
                      const Center(child: AuthAppLogo(fontSize: 22)),
                    ),
                    const SizedBox(height: 28),
                    _entrance(
                      headAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create your account',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Join thousands importing cars from the US',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _entrance(
                      nameAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthFormFieldLabel('FULL NAME'),
                          const SizedBox(height: 8),
                          StyledAuthTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hintText: 'e.g. Kwame Mensah',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            focused: _nameFocus.hasFocus,
                            onChanged: (v) => ref
                                .read(registrationFormProvider.notifier)
                                .updateFullName(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _entrance(
                      phoneAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthFormFieldLabel('PHONE NUMBER'),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: phoneFocused ? _primary : _border,
                                width: phoneFocused ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: form.countryCode,
                                      isDense: true,
                                      icon: const Icon(
                                        Icons.expand_more,
                                        color: _textSecondary,
                                        size: 20,
                                      ),
                                      style: AppTextStyles.titleSmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: _textPrimary,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: '+233',
                                          child: Text('🇬🇭  +233'),
                                        ),
                                        DropdownMenuItem(
                                          value: '+234',
                                          child: Text('🇳🇬  +234'),
                                        ),
                                        DropdownMenuItem(
                                          value: '+1',
                                          child: Text('🇺🇸  +1'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) {
                                          ref
                                              .read(
                                                registrationFormProvider
                                                    .notifier,
                                              )
                                              .updateCountryCode(v);
                                        }
                                      },
                                      selectedItemBuilder: (context) {
                                        final t = AppTextStyles.titleSmall
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: _textPrimary,
                                        );
                                        return [
                                          Text(_countryLabel('+233'), style: t),
                                          Text(_countryLabel('+234'), style: t),
                                          Text(_countryLabel('+1'), style: t),
                                        ];
                                      },
                                    ),
                                  ),
                                ),
                                Container(width: 1, height: 24, color: _border),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    keyboardType: TextInputType.phone,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: 15,
                                      color: _textPrimary,
                                      height: null,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '24 000 0000',
                                      hintStyle: AppTextStyles.bodyLarge
                                          .copyWith(
                                        fontSize: 15,
                                        color: _textTertiary,
                                        height: null,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                    ),
                                    onChanged: (v) => ref
                                        .read(registrationFormProvider.notifier)
                                        .updatePhoneDigits(v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _entrance(
                      locAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthFormFieldLabel('LOCATION (CITY)'),
                          const SizedBox(height: 8),
                          StyledAuthTextField(
                            controller: _locationController,
                            focusNode: _locationFocus,
                            hintText: 'e.g. Accra',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            focused: _locationFocus.hasFocus,
                            onChanged: (v) => ref
                                .read(registrationFormProvider.notifier)
                                .updateLocation(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _entrance(
                      firstAnim,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthFormFieldLabel(
                            'FIRST TIME IMPORTING A CAR?',
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<bool>(
                                value: form.isFirstTimeBuyer,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: _textSecondary,
                                ),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 15,
                                  color: _textPrimary,
                                  height: null,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Yes'),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('No'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    ref
                                        .read(registrationFormProvider.notifier)
                                        .updateFirstTimeBuyer(v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _entrance(
                      btnAnim,
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _border,
                            disabledForegroundColor: _textTertiary,
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Send verification code',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _entrance(
                      footerAnim,
                      _RegisterTermsText(
                        onTerms: () => _openUrl('https://example.com/terms'),
                        onPrivacy: () =>
                            _openUrl('https://example.com/privacy'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _entrance(
                      footerAnim,
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _textSecondary,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    context.goNamed(RouteConstants.login),
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign in',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: _primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _RegisterTermsText extends StatefulWidget {
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _RegisterTermsText({required this.onTerms, required this.onPrivacy});

  @override
  State<_RegisterTermsText> createState() => _RegisterTermsTextState();
}

class _RegisterTermsTextState extends State<_RegisterTermsText> {
  late TapGestureRecognizer _termsTap;
  late TapGestureRecognizer _privacyTap;

  static const Color _primary = Color(0xFF378ADD);
  static const Color _textTertiary = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = widget.onTerms;
    _privacyTap = TapGestureRecognizer()..onTap = widget.onPrivacy;
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
            text: 'By creating an account you agree to our ',
            style: AppTextStyles.cardLabel.copyWith(color: _textTertiary),
          ),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: _primary,
            ),
            recognizer: _termsTap,
          ),
          TextSpan(
            text: ' and ',
            style: AppTextStyles.cardLabel.copyWith(color: _textTertiary),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              color: _primary,
            ),
            recognizer: _privacyTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
