import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/layout/web_app_body.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../../shared/providers/app_version_label_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import '../widgets/id_verification_banner.dart';
import '../widgets/profile_account_sheets.dart';
import '../widgets/profile_header_order_summary.dart';
import '../widgets/profile_language_currency_widgets.dart';
import '../widgets/profile_loading_states.dart';
import '../widgets/profile_notification_prefs_widgets.dart';
import '../widgets/profile_personal_contact_widgets.dart';
import '../widgets/profile_section_shell.dart';
import '../widgets/profile_session_widgets.dart';
import '../widgets/profile_support_widgets.dart';
import '../widgets/profile_ui_tokens.dart';

Future<void> _resetGuide(BuildContext context, WidgetRef ref) async {
  await ref.read(guideNotifierProvider.notifier).resetAll();

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Guide reset — revisit any screen to '
        'see the walkthrough again.',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerAnimation;
  final Map<int, AnimationController> _sectionControllers = {};
  final Map<int, Animation<double>> _sectionAnimations = {};
  static const int _kSectionCount = 7;
  bool _headerAnimated = false;
  bool _sectionsAnimated = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    for (int i = 0; i < _kSectionCount; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
      _sectionControllers[i] = c;
      _sectionAnimations[i] = CurvedAnimation(parent: c, curve: Curves.easeOut);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _headerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    for (final c in _sectionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startSectionAnimations() {
    if (_sectionsAnimated) return;
    _sectionsAnimated = true;
    for (int i = 0; i < _kSectionCount; i++) {
      Future.delayed(Duration(milliseconds: 60 * (i + 1)), () {
        if (mounted) _sectionControllers[i]?.forward();
      });
    }
  }

  PreferredSizeWidget _buildProfileAppBar(BuildContext context) {
    final title = Text(
      ProfileConstants.appBarTitle,
      style: AppTextStyles.appBarTitle.copyWith(color: Colors.black),
    );

    return AppBar(
      backgroundColor: dashboardMobileAppBarBackground(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: DashboardAppBarToolbar(
        leading: title,
        actions: const [GuideHelpButton()],
      ),
      actions: const <Widget>[],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: AppColors.borderSolid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    final sessions = ref.watch(sessionListProvider).valueOrNull ?? [];

    return profileAsync.when(
      data: (user) {
        if (user != null && !_headerAnimated) {
          _headerAnimated = true;
        }
        if (_headerAnimated && user != null && !_sectionsAnimated) {
          _startSectionAnimations();
        }
        final isWeb = AppBreakpoints.useWebShell(context);
        final authUid = ref.watch(authStateProvider).value;
        final Widget body = user == null
            ? (authUid != null
                ? const ProfileIncompleteSetupBody()
                : const ProfileBodyShimmer())
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(currentUserProfileProvider);
                  ref.invalidate(orderSummaryProvider);
                  ref.invalidate(sessionListProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: DashboardLayout.flowScrollPadding(
                    context,
                    top: 16,
                    bottom: 24 + profileShellFloatingNavExtra(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardContainer(
                        paddingType: CardContainerPaddingType.large,
                        child: Column(
                          children: [
                            ProfileAnimatedHeaderCard(
                              controller: _headerController,
                              animation: _headerAnimation,
                              user: user,
                            ),
                            const SizedBox(height: 12),
                            orderSummaryAsync.when(
                              data: (summary) => ProfileOrderSummaryRow(
                                animation: _sectionAnimations[0]!,
                                activeCount: summary.activeCount,
                                completedCount: summary.completedCount,
                                agentFirstName: summary.agentFirstName,
                              ),
                              loading: () => ProfileOrderSummaryShimmer(
                                animation: _sectionAnimations[0]!,
                              ),
                              error: (_, __) => ProfileOrderSummaryRow(
                                animation: _sectionAnimations[0]!,
                                activeCount: 0,
                                completedCount: 0,
                                agentFirstName: ProfileConstants.noAgentYet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!user.hasGhanaCard) ...[
                        const SizedBox(height: 12),
                        IdVerificationBanner(
                          pulse: _pulseController,
                          user: user,
                        ),
                      ],
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[1]!,
                          title: ProfileConstants.sectionPersonalDetails,
                          hasUnsaved: _hasPersonalUnsaved(ref),
                          child: ProfilePersonalDetailsSection(
                            user: user,
                            onSaveFullName: _saveFullName,
                            onSaveLocation: _saveLocation,
                            onPhoneTap: _onPhoneEditTap,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[2]!,
                          title: ProfileConstants.sectionContactChannels,
                          hasUnsaved: _hasContactUnsaved(ref),
                          child: ProfileContactChannelsSection(
                            user: user,
                            onSaveSmsPhone: _saveSmsPhone,
                            onSaveWhatsappPhone: _saveWhatsappPhone,
                            onSaveEmail: _saveEmail,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[3]!,
                          title: ProfileConstants.sectionLanguageCurrency,
                          hasUnsaved: false,
                          child: ProfileLanguageCurrencySection(user: user),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[4]!,
                          title: ProfileConstants.sectionNotifications,
                          hasUnsaved: false,
                          child: ProfileNotificationsSection(user: user),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[5]!,
                          title: ProfileConstants.sectionSession,
                          hasUnsaved: false,
                          child: ProfileSessionSection(sessions: sessions),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardContainer(
                        child: ProfileAnimatedSection(
                          animation: _sectionAnimations[6]!,
                          title: ProfileConstants.sectionSupport,
                          hasUnsaved: false,
                          child: ProfileSupportSection(
                            onResetGuide: () => _resetGuide(context, ref),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ProfileLogOutButton(
                        onPressed: () => _showLogOutConfirm(context),
                      ),
                      const SizedBox(height: 32),
                      ProfileDeleteAccountLink(
                        onPressed: () => _showDeleteAccountSheet(context),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          ref.watch(appVersionLabelProvider),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );

        if (isWeb) {
          return WebAppBody(
            body: body,
            pageTitle: ProfileConstants.appBarTitle,
            appBarActions: [GuideHelpButton()],
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildProfileAppBar(context),
          body: DashboardPortraitFrame(child: body),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildProfileAppBar(context),
        body: const DashboardPortraitFrame(child: ProfileBodyShimmer()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildProfileAppBar(context),
        body: DashboardPortraitFrame(
          child: ProfileBodyError(
            message: ProfileConstants.errorLoadProfile,
            onRetry: () => ref.invalidate(currentUserProfileProvider),
          ),
        ),
      ),
    );
  }

  bool _hasPersonalUnsaved(WidgetRef r) {
    final edit = r.watch(profileEditProvider);
    const personal = ['fullName', 'location', 'phone'];
    return edit.expandedField != null && personal.contains(edit.expandedField);
  }

  bool _hasContactUnsaved(WidgetRef r) {
    final edit = r.watch(profileEditProvider);
    const fields = ['smsPhone', 'whatsappPhone', 'email'];
    return edit.expandedField != null && fields.contains(edit.expandedField);
  }

  Future<void> _saveFullName(String value) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .updateFullName(user.id, value);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
        onAction: () => _saveFullName(value),
      ),
      (_) {
        ref.read(profileEditProvider.notifier).collapse();
      },
    );
  }

  Future<void> _saveLocation(String value) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .updateLocation(user.id, value);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
        onAction: () => _saveLocation(value),
      ),
      (_) {
        ref.read(profileEditProvider.notifier).collapse();
      },
    );
  }

  Future<void> _saveSmsPhone(String value) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .updateSmsPhone(user.id, value);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
        onAction: () => _saveSmsPhone(value),
      ),
      (_) {
        ref.read(profileEditProvider.notifier).collapse();
        ref.invalidate(currentUserProfileProvider);
      },
    );
  }

  Future<void> _saveWhatsappPhone(String value) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .updateWhatsappPhone(user.id, value);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
        onAction: () => _saveWhatsappPhone(value),
      ),
      (_) {
        ref.read(profileEditProvider.notifier).collapse();
        ref.invalidate(currentUserProfileProvider);
      },
    );
  }

  Future<void> _saveEmail(String value) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .updateEmail(user.id, value);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
        onAction: () => _saveEmail(value),
      ),
      (_) {
        ref.read(profileEditProvider.notifier).collapse();
        ref.invalidate(currentUserProfileProvider);
      },
    );
  }

  void _onPhoneEditTap() {
    _showPhoneVerificationSheet(context);
  }

  void _showLogOutConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          ProfileConstants.logOutConfirmTitle,
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          ProfileConstants.logOutConfirmBody,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              ProfileConstants.stayLoggedInAction,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.brand,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _doLogOut(ctx);
            },
            child: Text(
              ProfileConstants.logOutConfirmAction,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogOut(BuildContext context) async {
    final userId = ref.read(authStateProvider).value;
    if (userId == null) {
      await _signOutAndGoLogin(context);
      return;
    }
    final sessionList = ref.read(sessionListProvider).valueOrNull ?? [];
    for (final s in sessionList) {
      final res = await ref.read(profileRepositoryProvider).deleteSession(s.id);
      res.fold((_) {}, (_) {});
    }
    if (!context.mounted) return;
    await _signOutAndGoLogin(context);
  }

  Future<void> _signOutAndGoLogin(BuildContext context) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!context.mounted) return;
      context.go('/login');
    } catch (_) {
      if (!context.mounted) return;
      showErrorSnackBar(
        context,
        ProfileConstants.errorLogOut,
        actionLabel: ProfileConstants.retry,
        onAction: () => _doLogOut(context),
      );
    }
  }

  void _showDeleteAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfileDeleteAccountBottomSheet(
        userId: ref.read(authStateProvider).value ?? '',
        onDeleted: () => context.go('/login'),
      ),
    );
  }

  void _showPhoneVerificationSheet(BuildContext context) {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ProfilePhoneChangeSheet(
        currentPhone: user.phone,
        onVerified: () {
          ref.read(profileEditProvider.notifier).collapse();
          ref.invalidate(currentUserProfileProvider);
        },
      ),
    );
  }
}
