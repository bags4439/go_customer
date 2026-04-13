import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_version.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../../shared/providers/currencies_provider.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/country.dart';
import '../../../auth/presentation/providers/countries_providers.dart';
import '../../../auth/presentation/widgets/country_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import '../../core/constants/profile_constants.dart';
import '../../domain/entities/user_session_entity.dart';
import '../providers/profile_providers.dart';
import '../widgets/ghana_card_profile_row.dart';
import '../widgets/id_verification_banner.dart';

double _profileShellFloatingNavExtra(BuildContext context) {
  if (!ResponsiveLayout.isMobile(context)) return 0;
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return bottomInset + 64 + 24;
}

const Color _kPrimary = Color(0xFF378ADD);
const Color _kSuccess = Color(0xFF1D9E75);
const Color _kWarning = Color(0xFFBA7517);
const Color _kDanger = Color(0xFFE24B4A);
const Color _kSurface = Color(0xFFF5F4F0);
const Color _kBorder = Color(0xFFE0DFD8);
const Color _kTextTertiary = Color(0xFFAAAAAA);
const Color _kAmberBg = Color(0xFFFAEEDA);
const Color _kBlueTint = Color(0xFFE6F1FB);
const Color _kBlueText = Color(0xFF185FA5);
const Color _kDarkBrown = Color(0xFF633806);

Future<void> _resetGuide(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(guideNotifierProvider.notifier).resetAll();

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Guide reset — revisit any screen to '
        'see the walkthrough again.',
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
      backgroundColor: AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
  static const int _kSectionCount = 6;
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    final sessionsAsync = ref.watch(sessionListProvider);

    return profileAsync.when(
      data: (user) {
        if (user != null && !_headerAnimated) {
          _headerAnimated = true;
        }
        if (_headerAnimated && user != null && !_sectionsAnimated) {
          _startSectionAnimations();
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              ProfileConstants.appBarTitle,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(color: _kBorder),
            ),
            actions: const [
              GuideHelpButton(),
            ],
          ),
          body: user == null
              ? const _ProfileShimmer()
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentUserProfileProvider);
                    ref.invalidate(orderSummaryProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      24 + _profileShellFloatingNavExtra(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AnimatedHeaderCard(
                          controller: _headerController,
                          animation: _headerAnimation,
                          user: user,
                        ),
                        const SizedBox(height: 12),
                        orderSummaryAsync.when(
                          data: (summary) => _OrderSummaryRow(
                            animation: _sectionAnimations[0]!,
                            activeCount: summary.activeCount,
                            completedCount: summary.completedCount,
                            agentFirstName: summary.agentFirstName,
                          ),
                          loading: () => _OrderSummaryShimmer(
                            animation: _sectionAnimations[0]!,
                          ),
                          error: (_, __) => _OrderSummaryRow(
                            animation: _sectionAnimations[0]!,
                            activeCount: 0,
                            completedCount: 0,
                            agentFirstName: ProfileConstants.noAgentYet,
                          ),
                        ),
                        if (!user.hasGhanaCard) ...[
                          const SizedBox(height: 12),
                          IdVerificationBanner(
                            pulse: _pulseController,
                            user: user,
                          ),
                        ],
                        _AnimatedSection(
                          index: 1,
                          animation: _sectionAnimations[1]!,
                          title: ProfileConstants.sectionPersonalDetails,
                          hasUnsaved: _hasPersonalUnsaved(ref),
                          child: _PersonalDetailsSection(
                            user: user,
                            onSaveFullName: _saveFullName,
                            onSaveLocation: _saveLocation,
                            onPhoneTap: _onPhoneEditTap,
                          ),
                        ),
                        // _AnimatedSection(
                        //   index: 2,
                        //   animation: _sectionAnimations[2]!,
                        //   title: ProfileConstants.sectionNotifications,
                        //   hasUnsaved: false,
                        //   child: _NotificationsSection(user: user),
                        // ),
                        _AnimatedSection(
                          index: 3,
                          animation: _sectionAnimations[3]!,
                          title: ProfileConstants.sectionLanguageCurrency,
                          hasUnsaved: false,
                          child: _LanguageCurrencySection(user: user),
                        ),
                        _AnimatedSection(
                          index: 4,
                          animation: _sectionAnimations[4]!,
                          title: ProfileConstants.sectionSupport,
                          hasUnsaved: false,
                          child: _SupportSection(
                            onResetGuide: () => _resetGuide(context, ref),
                          ),
                        ),
                        _AnimatedSection(
                          index: 5,
                          animation: _sectionAnimations[5]!,
                          title: ProfileConstants.sectionSession,
                          hasUnsaved: false,
                          child: _SessionSection(
                            sessions: sessionsAsync.valueOrNull ?? [],
                            userId: user.id,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _LogOutButton(
                          onPressed: () => _showLogOutConfirm(context),
                        ),
                        const SizedBox(height: 12),
                        _DeleteAccountLink(
                          onPressed: () => _showDeleteAccountSheet(context),
                        ),
                        ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              appVersionLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _kTextTertiary,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            ProfileConstants.appBarTitle,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _ProfileShimmer(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            ProfileConstants.appBarTitle,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _ProfileError(
          message: ProfileConstants.errorLoadProfile,
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
    );
  }

  bool _hasPersonalUnsaved(WidgetRef r) {
    final edit = r.watch(profileEditProvider);
    const personal = ['fullName', 'location', 'phone'];
    return edit.expandedField != null && personal.contains(edit.expandedField);
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

  void _onPhoneEditTap() {
    _showPhoneVerificationSheet(context);
  }

  void _showLogOutConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          ProfileConstants.logOutConfirmTitle,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          ProfileConstants.logOutConfirmBody,
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              ProfileConstants.stayLoggedInAction,
              style: GoogleFonts.dmSans(color: _kPrimary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _doLogOut(ctx);
            },
            child: Text(
              ProfileConstants.logOutConfirmAction,
              style: GoogleFonts.dmSans(
                color: _kDanger,
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
    final sessions = ref.read(sessionListProvider).valueOrNull ?? [];
    for (final s in sessions) {
      final res = await ref.read(profileRepositoryProvider).deleteSession(s.id);
      res.fold((_) {}, (_) {});
    }
    await _signOutAndGoLogin(context);
  }

  Future<void> _signOutAndGoLogin(BuildContext context) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
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
      builder: (ctx) => _DeleteAccountBottomSheet(
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
      builder: (ctx) => _PhoneChangeSheet(
        currentPhone: user.phone,
        onVerified: () {
          ref.read(profileEditProvider.notifier).collapse();
          ref.invalidate(currentUserProfileProvider);
        },
      ),
    );
  }
}

class _AnimatedHeaderCard extends StatelessWidget {
  const _AnimatedHeaderCard({
    required this.controller,
    required this.animation,
    required this.user,
  });

  final AnimationController controller;
  final Animation<double> animation;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _AvatarCircle(user: user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.user});

  final AppUser user;

  String get _initials {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 1
          ? parts.first.substring(0, 1).toUpperCase()
          : '?';
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _kPrimary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (user.isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: _kSuccess,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  const _OrderSummaryRow({
    required this.animation,
    required this.activeCount,
    required this.completedCount,
    required this.agentFirstName,
  });

  final Animation<double> animation;
  final int activeCount;
  final int completedCount;
  final String agentFirstName;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(opacity: t, child: child);
      },
      child: Row(
        children: [
          Expanded(
            child: _SummaryBox(
              value: '$activeCount',
              valueColor: _kPrimary,
              label: ProfileConstants.activeLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryBox(
              value: '$completedCount',
              valueColor: _kSuccess,
              label: ProfileConstants.completedLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryBox(
              value: agentFirstName,
              valueColor: Colors.black87,
              valueSize: 14,
              label: ProfileConstants.yourAgentLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.value,
    required this.valueColor,
    required this.label,
    this.valueSize = 18,
  });

  final String value;
  final Color valueColor;
  final String label;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryShimmer extends StatelessWidget {
  const _OrderSummaryShimmer({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(opacity: t, child: child);
      },
      child: Row(
        children: List.generate(
          3,
          (_) => Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.index,
    required this.animation,
    required this.title,
    required this.hasUnsaved,
    required this.child,
  });

  final int index;
  final Animation<double> animation;
  final String title;
  final bool hasUnsaved;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _kTextTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (hasUnsaved) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _PersonalDetailsSection extends ConsumerWidget {
  const _PersonalDetailsSection({
    required this.user,
    required this.onSaveFullName,
    required this.onSaveLocation,
    required this.onPhoneTap,
  });

  final AppUser user;
  final void Function(String) onSaveFullName;
  final void Function(String) onSaveLocation;
  final VoidCallback onPhoneTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(profileEditProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditRow(
          label: ProfileConstants.fullNameLabel,
          value: user.fullName,
          expanded: edit.expandedField == 'fullName',
          draftValue: edit.draftValue,
          errorMessage: edit.expandedField == 'fullName'
              ? edit.errorMessage
              : null,
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('fullName', user.fullName),
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {
            final v = (edit.draftValue ?? user.fullName).trim();
            if (v.length < 2) {
              ref
                  .read(profileEditProvider.notifier)
                  .setError('At least 2 characters');
              return;
            }
            onSaveFullName(v);
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
          validator: (v) =>
              v.trim().length < 2 ? 'At least 2 characters' : null,
        ),
        _DividerIndent(),
        _EditRow(
          label: ProfileConstants.phoneLabel,
          value: user.phone,
          expanded: edit.expandedField == 'phone',
          draftValue: edit.draftValue,
          isPhone: true,
          onTap: onPhoneTap,
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {},
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
          subtitle: ProfileConstants.phoneChangeNote,
        ),
        _DividerIndent(),
        _CountryRow(
          currentIsoCode: user.country,
          userId: user.id,
        ),
        _DividerIndent(),
        GhanaCardProfileRow(user: user),
        if (user.email != null && user.email!.isNotEmpty) ...[
          _DividerIndent(),
          _ReadOnlyRow(label: ProfileConstants.emailLabel, value: user.email!),
        ],
      ],
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.label,
    required this.value,
    required this.expanded,
    required this.onTap,
    required this.onSave,
    required this.onCancel,
    this.draftValue,
    this.errorMessage,
    this.onDraftChanged,
    this.validator,
    this.isPhone = false,
    this.subtitle,
  });

  final String label;
  final String value;
  final bool expanded;
  final String? draftValue;
  final String? errorMessage;
  final VoidCallback onTap;
  final void Function(String)? onDraftChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? Function(String)? validator;
  final bool isPhone;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (!expanded)
                          Text(
                            value,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!expanded)
                    const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: _kTextTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: draftValue ?? value,
                        keyboardType: isPhone
                            ? TextInputType.phone
                            : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: isPhone ? '+233 XX XXX XXXX' : null,
                          isDense: true,
                          errorText: errorMessage,
                          errorStyle: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _kDanger,
                          ),
                        ),
                        onChanged: onDraftChanged,
                        autofocus: true,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: _kTextTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: onCancel,
                            child: Text(
                              ProfileConstants.cancel,
                              style: GoogleFonts.dmSans(color: _kTextTertiary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final v = draftValue ?? value;
                              if (validator != null && validator!(v) != null) {
                                return;
                              }
                              onSave();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Save',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (expanded && errorMessage != null)
          AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                errorMessage!,
                style: GoogleFonts.dmSans(fontSize: 11, color: _kDanger),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.black54,
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

class _DividerIndent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Divider(height: 1, color: _kBorder, thickness: 0.5),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = user.notificationPreferences;
    return Column(
      children: [
        _ToggleRow(
          label: ProfileConstants.notifAgentMessages,
          subtitle: ProfileConstants.notifAgentMessagesSubtitle,
          value: prefs['agentMessages'] ?? true,
          prefKey: 'agentMessages',
          userId: user.id,
        ),
        _DividerIndent(),
        _ToggleRow(
          label: ProfileConstants.notifOrderUpdates,
          subtitle: ProfileConstants.notifOrderUpdatesSubtitle,
          value: prefs['orderUpdates'] ?? true,
          prefKey: 'orderUpdates',
          userId: user.id,
        ),
        _DividerIndent(),
        _ToggleRow(
          label: ProfileConstants.notifPaymentRequests,
          subtitle: ProfileConstants.notifPaymentRequestsSubtitle,
          value: prefs['paymentRequests'] ?? true,
          prefKey: 'paymentRequests',
          userId: user.id,
        ),
        _DividerIndent(),
        _ToggleRow(
          label: ProfileConstants.notifPromotions,
          subtitle: ProfileConstants.notifPromotionsSubtitle,
          value: prefs['promotionsAndNews'] ?? false,
          prefKey: 'promotionsAndNews',
          userId: user.id,
        ),
      ],
    );
  }
}

class _ToggleRow extends ConsumerStatefulWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.prefKey,
    required this.userId,
  });

  final String label;
  final String subtitle;
  final bool value;
  final String prefKey;
  final String userId;

  @override
  ConsumerState<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends ConsumerState<_ToggleRow> {
  bool _saving = false;
  bool _localValue = false;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(_ToggleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_saving) _localValue = widget.value;
  }

  Future<void> _onToggle(bool v) async {
    setState(() {
      _saving = true;
      _localValue = v;
    });
    final result = await ref
        .read(profileRepositoryProvider)
        .updateNotificationPreference(widget.userId, widget.prefKey, v);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold((_) {
      setState(() => _localValue = widget.value);
      showErrorSnackBar(
        context,
        ProfileConstants.errorUpdatePreference,
        actionLabel: ProfileConstants.retry,
        onAction: () => _onToggle(v),
      );
    }, (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kPrimary,
                  ),
                ),
              ),
            )
          else
            CupertinoSwitch(
              value: _localValue,
              onChanged: _onToggle,
              activeTrackColor: _kPrimary,
            ),
        ],
      ),
    );
  }
}

class _LanguageCurrencySection extends ConsumerWidget {
  const _LanguageCurrencySection({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _LanguageRow(currentLanguage: user.preferredLanguage),
        _DividerIndent(),
        _CurrencyRow(
          currentCurrency: user.preferredCurrency,
          userId: user.id,
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.currentLanguage});

  final String currentLanguage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ProfileConstants.languageLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      ProfileConstants.languageEnglish,
                      style: GoogleFonts.dmSans(),
                    ),
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ProfileConstants.languageLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                ProfileConstants.languageEnglish,
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black54),
              ),
              const Icon(Icons.chevron_right, color: _kTextTertiary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyRow extends ConsumerWidget {
  const _CurrencyRow({
    required this.currentCurrency,
    required this.userId,
  });

  final String currentCurrency;
  final String userId;

  static String _currencyLabel(
    String code,
    List<CurrencyModel>? currencies,
  ) {
    if (currencies == null) return code;
    for (final c in currencies) {
      if (c.code == code) {
        return '${c.symbol}  ${c.name}';
      }
    }
    return code;
  }

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref,
    List<CurrencyModel> currencies,
  ) async {
    if (currencies.isEmpty) return;

    final selected = await showModalBottomSheet<CurrencyModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CurrencyPickerSheet(
        currencies: currencies,
        selectedCode: currentCurrency,
      ),
    );

    if (selected == null) return;
    if (!context.mounted) return;

    final result = await ref
        .read(profileRepositoryProvider)
        .updatePreferredCurrency(userId, selected.code);

    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
      ),
      (_) {
        ref.invalidate(currentUserProfileProvider);
        ref.invalidate(exchangeRateProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesAsync = ref.watch(currenciesProvider);
    final list = currenciesAsync.valueOrNull ?? const <CurrencyModel>[];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context, ref, list),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ProfileConstants.displayCurrencyLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _currencyLabel(
                        currentCurrency,
                        currenciesAsync.valueOrNull,
                      ),
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: _kTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selectedCode,
  });

  final List<CurrencyModel> currencies;
  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.75;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: maxH,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.borderSolid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.currency_exchange_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display currency',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Prices will display in this currency.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.borderSolid,
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    24 + bottomInset,
                  ),
                  itemCount: currencies.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderSolid,
                  ),
                  itemBuilder: (context, i) {
                    final currency = currencies[i];
                    final isSelected = currency.code == selectedCode;
                    return Material(
                      color: isSelected
                          ? AppColors.selectionTint
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, currency),
                        splashColor:
                            AppColors.secondary.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.surface
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  currency.symbol,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.name,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      currency.code,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.secondary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryRow extends ConsumerWidget {
  const _CountryRow({
    required this.currentIsoCode,
    required this.userId,
  });

  final String currentIsoCode;
  final String userId;

  Country? _currentCountry(List<Country>? countries) {
    if (countries == null) return null;
    for (final c in countries) {
      if (c.isoCode == currentIsoCode) return c;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final selected = await CountryPickerSheet.show(
      context,
      selectedIsoCode: currentIsoCode,
    );

    if (selected == null) return;
    if (!context.mounted) return;

    final result = await ref
        .read(profileRepositoryProvider)
        .updateCountry(userId, selected.isoCode);

    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
      ),
      (_) {
        ref.invalidate(currentUserProfileProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);
    final currentCountry =
        _currentCountry(countriesAsync.valueOrNull);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context, ref),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Country',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      currentCountry != null
                          ? currentCountry.displayLabel
                          : currentIsoCode.isNotEmpty
                              ? currentIsoCode
                              : 'Not set',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: _kTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: _kPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: _kTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({required this.onResetGuide});

  final Future<void> Function() onResetGuide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SupportRow(
          label: ProfileConstants.contactSupport,
          onTap: () => SupportBottomSheet.show(context),
        ),
        _DividerIndent(),
        _SupportRow(
          label: ProfileConstants.faqs,
          onTap: () =>  GuideFaqSheet.show(context)
        ),
        _DividerIndent(),
        _SupportRow(
          label: ProfileConstants.termsAndPrivacy,
          onTap: () => launchUrl(
            Uri.parse(ProfileConstants.termsUrl),
            mode: LaunchMode.inAppWebView,
          ),
        ),
        _DividerIndent(),
        _SupportRow(
          label: ProfileConstants.rateTheApp,
          icon: Icons.star,
          iconColor: _kWarning,
          onTap: () async {
            final inAppReview = InAppReview.instance;
            if (await inAppReview.isAvailable()) {
              await inAppReview.requestReview();
            } else {
              await inAppReview.openStoreListing(
                appStoreId: 'YOUR_APP_STORE_ID',
              );
            }
          },
        ),
        _DividerIndent(),
        _ProfileMenuTile(
          icon: Icons.tour_outlined,
          label: 'App guide',
          sublabel: 'Replay the in-app walkthrough',
          onTap: () => onResetGuide(),
        ),
      ],
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.label,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                icon ?? Icons.open_in_new,
                size: 20,
                color: iconColor ?? _kTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionSection extends ConsumerWidget {
  const _SessionSection({required this.sessions, required this.userId});

  final List<UserSessionEntity> sessions;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstSession = sessions.isNotEmpty ? sessions.first : null;
    return Column(
      children: [
        _StayLoggedInRow(
          sessionId: firstSession?.id,
          expiresAt: firstSession?.expiresAt,
          userId: userId,
        ),
        _DividerIndent(),
        _ActiveSessionsRow(
          count: sessions.length,
          sessions: sessions,
          onSignOutSession: (id) async {
            await ref.read(profileRepositoryProvider).deleteSession(id);
          },
        ),
      ],
    );
  }
}

class _StayLoggedInRow extends ConsumerStatefulWidget {
  const _StayLoggedInRow({
    this.sessionId,
    this.expiresAt,
    required this.userId,
  });

  final String? sessionId;
  final DateTime? expiresAt;
  final String userId;

  @override
  ConsumerState<_StayLoggedInRow> createState() => _StayLoggedInRowState();
}

class _StayLoggedInRowState extends ConsumerState<_StayLoggedInRow> {
  bool _saving = false;
  bool _localValue = true;

  @override
  void initState() {
    super.initState();
    if (widget.expiresAt != null) {
      final now = DateTime.now();
      _localValue = widget.expiresAt!.difference(now).inHours > 24;
    }
  }

  @override
  void didUpdateWidget(_StayLoggedInRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_saving && widget.expiresAt != null) {
      final now = DateTime.now();
      _localValue = widget.expiresAt!.difference(now).inHours > 24;
    }
  }

  Future<void> _onToggle(bool v) async {
    if (widget.sessionId == null) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final expiresAt = v
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(hours: 24));
    final result = await ref
        .read(profileRepositoryProvider)
        .updateSessionExpiry(widget.sessionId!, expiresAt);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _localValue = v;
    });
    result.fold(
      (_) => showErrorSnackBar(context, ProfileConstants.errorUpdatePreference),
      (_) => ref.invalidate(sessionListProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ProfileConstants.stayLoggedIn,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ProfileConstants.stayLoggedInSubtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _kPrimary,
              ),
            )
          else
            CupertinoSwitch(
              value: _localValue,
              onChanged: widget.sessionId != null ? _onToggle : null,
              activeTrackColor: _kPrimary,
            ),
        ],
      ),
    );
  }
}

class _ActiveSessionsRow extends StatelessWidget {
  const _ActiveSessionsRow({
    required this.count,
    required this.sessions,
    required this.onSignOutSession,
  });

  final int count;
  final List<UserSessionEntity> sessions;
  final void Function(String) onSignOutSession;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => _SessionsBottomSheet(
              sessions: sessions,
              onSignOut: onSignOutSession,
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ProfileConstants.activeSessions,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '$count ${ProfileConstants.devicesCount}',
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black54),
              ),
              const Icon(Icons.chevron_right, color: _kTextTertiary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionsBottomSheet extends StatelessWidget {
  const _SessionsBottomSheet({required this.sessions, required this.onSignOut});

  final List<UserSessionEntity> sessions;
  final void Function(String) onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ProfileConstants.activeSessions,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...sessions.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final date = s.lastUsedAt != null
                ? '${s.lastUsedAt!.day}/${s.lastUsedAt!.month}/${s.lastUsedAt!.year}'
                : '—';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.phone_android, color: _kTextTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device ${i + 1}',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          date,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _kTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onSignOut(s.id);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign out of this session',
                      style: GoogleFonts.dmSans(fontSize: 12, color: _kDanger),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _kDanger,
          side: const BorderSide(color: _kDanger, width: 1),
        ),
        child: Text(
          ProfileConstants.logOut,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _DeleteAccountLink extends StatelessWidget {
  const _DeleteAccountLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          ProfileConstants.deleteAccount,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: _kDanger,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountBottomSheet extends ConsumerStatefulWidget {
  const _DeleteAccountBottomSheet({
    required this.userId,
    required this.onDeleted,
  });

  final String userId;
  final VoidCallback onDeleted;

  @override
  ConsumerState<_DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState
    extends ConsumerState<_DeleteAccountBottomSheet> {
  final _controller = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _canConfirm = _controller.text == 'DELETE');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ProfileConstants.deleteConfirmHeading,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileConstants.deleteConfirmWarning,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kAmberBg,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: _kWarning, width: 3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: _kWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ProfileConstants.deleteConfirmWarning,
                    style: GoogleFonts.dmSans(fontSize: 12, color: _kDarkBrown),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: ProfileConstants.deleteTypeToConfirm,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) =>
                setState(() => _canConfirm = _controller.text == 'DELETE'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ProfileConstants.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canConfirm ? _confirmDelete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kDanger,
                    disabledBackgroundColor: _kTextTertiary,
                  ),
                  child: Text(
                    ProfileConstants.deleteConfirmButton,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final result = await ref
        .read(profileRepositoryProvider)
        .deleteUserAccount(widget.userId);
    if (!mounted) return;
    result.fold(
      (_) => showErrorSnackBar(context, 'Could not delete account.'),
      (_) {
        Navigator.pop(context);
        widget.onDeleted();
      },
    );
  }
}

class _PhoneChangeSheet extends ConsumerStatefulWidget {
  const _PhoneChangeSheet({
    required this.currentPhone,
    required this.onVerified,
  });

  final String currentPhone;
  final VoidCallback onVerified;

  @override
  ConsumerState<_PhoneChangeSheet> createState() => _PhoneChangeSheetState();
}

class _PhoneChangeSheetState extends ConsumerState<_PhoneChangeSheet> {
  int _step = 0;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _busy = false;
  String? _verificationId;
  int? _resendToken;
  String? _newPhone;
  int _countdown = 0;
  String _otpCode = '';
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  String _dialCodeForCountry(String isoCode) {
    const map = {
      'GH': '+233',
      'NG': '+234',
      'US': '+1',
      'GB': '+44',
      'CA': '+1',
      'DE': '+49',
      'FR': '+33',
      'ZA': '+27',
      'KE': '+254',
      'AU': '+61',
      'NL': '+31',
    };
    return map[isoCode] ?? '+233';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown <= 1) {
          _countdown = 0;
          t.cancel();
        } else {
          _countdown--;
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    final digits =
        _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7 || digits.length > 11) {
      showErrorSnackBar(
        context,
        'Enter a valid phone number',
      );
      return;
    }

    final user = ref.read(currentUserProfileProvider).valueOrNull;
    final iso = user?.country ?? '';
    final dialCode = _dialCodeForCountry(iso.isNotEmpty ? iso : 'GH');
    final phone = '$dialCode$digits';

    setState(() => _busy = true);

    final result = await ref
        .read(startPhoneVerificationUseCaseProvider)
        .call(
          phoneNumber: phone,
          resendToken: _resendToken,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    result.fold(
      (f) => showErrorSnackBar(context, f.message),
      (session) {
        setState(() {
          _verificationId = session.verificationId;
          _resendToken = session.resendToken;
          _newPhone = phone;
          _step = 1;
          _countdown = 30;
        });
        _startCountdown();
      },
    );
  }

  Future<void> _resend() async {
    if (_countdown > 0 || _newPhone == null) return;
    setState(() => _busy = true);

    final result = await ref
        .read(startPhoneVerificationUseCaseProvider)
        .call(
          phoneNumber: _newPhone!,
          resendToken: _resendToken,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    result.fold(
      (f) => showErrorSnackBar(context, f.message),
      (session) {
        setState(() {
          _verificationId = session.verificationId;
          _resendToken = session.resendToken;
          _countdown = 30;
        });
        _startCountdown();
        showSuccessSnackBar(context, 'New code sent.');
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6 || _verificationId == null) return;
    setState(() => _busy = true);

    final result = await ref.read(verifyOtpUseCaseProvider).call(
          verificationId: _verificationId!,
          smsCode: _otpCode,
        );

    if (!mounted) return;

    await result.fold<Future<void>>(
      (failure) async {
        if (!mounted) return;
        setState(() => _busy = false);
        showErrorSnackBar(context, failure.message);
      },
      (userId) async {
        final updateResult = await ref
            .read(profileRepositoryProvider)
            .updatePhone(userId, _newPhone!);
        if (!mounted) return;
        setState(() => _busy = false);
        updateResult.fold(
          (f) => showErrorSnackBar(context, f.message),
          (_) {
            ref.invalidate(currentUserProfileProvider);
            Navigator.pop(context);
            widget.onVerified();
            showSuccessSnackBar(
              context,
              'Phone number updated.',
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.viewInsetsOf(context).bottom;
    final user = ref.watch(currentUserProfileProvider).valueOrNull;
    final iso = user?.country ?? '';
    final dialCode = _dialCodeForCountry(iso.isNotEmpty ? iso : 'GH');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (_step == 0) ...[
            Text(
              'Change phone number',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your new phone number. '
              'We will send a verification code.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSolid,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Text(
                      dialCode,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 0.5,
                    height: 24,
                    color: AppColors.borderSolid,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _busy ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.borderSolid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send code',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _step = 0;
                    _otpCtrl.clear();
                    _otpCode = '';
                  }),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Enter verification code',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Code sent to $_newPhone',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 12,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 24,
                  letterSpacing: 12,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) {
                setState(() => _otpCode = v);
                if (v.length == 6) _verifyOtp();
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _countdown > 0 ? null : _resend,
              child: Text(
                _countdown > 0
                    ? 'Resend code in ${_countdown}s'
                    : 'Resend code',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _countdown > 0
                      ? AppColors.textTertiary
                      : AppColors.secondary,
                  fontWeight: _countdown > 0
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    (_otpCode.length == 6 && !_busy) ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.borderSolid,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Verify & update',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + _profileShellFloatingNavExtra(context),
      ),
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + _profileShellFloatingNavExtra(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: Text(
                ProfileConstants.retry,
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
