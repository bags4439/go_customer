import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../core/constants/referral_ui_constants.dart';
import '../../core/utils/referral_share_message_builder.dart';
import '../../domain/entities/referral_share_settings.dart';
import '../providers/referral_share_providers.dart';
import 'referral_promo_trophy_painter.dart';

class ReferralPromoCard extends ConsumerWidget {
  const ReferralPromoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(referralShareSettingsProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return settingsAsync.when(
      data: (settings) {
        final code = profileAsync.valueOrNull?.referralCode ?? '';
        return _ReferralPromoCardBody(settings: settings, referralCode: code);
      },
      loading: () => const _ReferralPromoCardSkeleton(),
      error: (_, __) => _ReferralPromoCardBody(
        settings: const ReferralShareSettings(),
        referralCode: profileAsync.valueOrNull?.referralCode ?? '',
      ),
    );
  }
}

class _ReferralPromoCardBody extends StatelessWidget {
  const _ReferralPromoCardBody({
    required this.settings,
    required this.referralCode,
  });

  final ReferralShareSettings settings;
  final String referralCode;

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        !(uri.hasScheme && (uri.isScheme('https') || uri.isScheme('http')))) {
      showErrorSnackBar(context, 'Link is not available.');
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        showErrorSnackBar(context, 'Could not open link.');
      }
    } catch (_) {
      if (context.mounted) showErrorSnackBar(context, 'Could not open link.');
    }
  }

  String _bodyText() {
    if (settings.hasDiscount) {
      return '${ReferralUiConstants.bodyWithRewardPrefix}'
          '${CurrencyFormatter.formatGhs(settings.referralDiscountGhs!)}'
          '${ReferralUiConstants.bodyWithRewardMiddle}'
          '${ReferralUiConstants.bodyPerks}';
    }
    return '${ReferralUiConstants.bodyGeneric}${ReferralUiConstants.bodyGenericSuffix}';
  }

  static bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final hasCode = referralCode.trim().isNotEmpty;
    final s = settings;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.referralCardGradientStart,
                    AppColors.referralCardGradientMid,
                    AppColors.referralCardGradientEnd,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ReferralPromoTrophyPainter(opacity: 0.22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ReferralUiConstants.cardTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _bodyText(),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.5,
                  ),
                ),
                if (s.hasAnyLink) ...[
                  const SizedBox(height: 14),
                  Text(
                    ReferralUiConstants.quickLinksHeading,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_nonEmpty(s.appStoreUrl))
                        _GhostLinkChip(
                          label: ReferralUiConstants.linkAppStore,
                          icon: Icons.apple_rounded,
                          onTap: () => _openUrl(context, s.appStoreUrl!),
                        ),
                      if (_nonEmpty(s.playstoreUrl))
                        _GhostLinkChip(
                          label: ReferralUiConstants.linkGooglePlay,
                          icon: Icons.android_rounded,
                          onTap: () => _openUrl(context, s.playstoreUrl!),
                        ),
                      if (_nonEmpty(s.websiteUrl))
                        _GhostLinkChip(
                          label: ReferralUiConstants.linkWebsite,
                          icon: Icons.language_rounded,
                          onTap: () => _openUrl(context, s.websiteUrl!),
                        ),
                    ],
                  ),
                ],
                if (hasCode) ...[
                  const SizedBox(height: 16),
                  Text(
                    ReferralUiConstants.yourCodeLabel.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            referralCode.trim(),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final code = referralCode.trim();
                            await Clipboard.setData(ClipboardData(text: code));
                            if (!context.mounted) return;
                            showSuccessSnackBar(
                              context,
                              ReferralUiConstants.codeCopied,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.copy_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Text(
                    ReferralUiConstants.codeMissingHint,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      final text = ReferralShareMessageBuilder.build(
                        settings: s,
                        referralCode: referralCode,
                      );
                      Share.share(
                        text,
                        subject: AppConstants.appName,
                        sharePositionOrigin: _shareOrigin(context),
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      child: Text(
                        ReferralUiConstants.inviteFriendsCta,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.referralCtaLabel,
                        ),
                      ),
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

Rect? _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  final origin = box.localToGlobal(Offset.zero);
  return origin & box.size;
}

class _GhostLinkChip extends StatelessWidget {
  const _GhostLinkChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.95)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralPromoCardSkeleton extends StatelessWidget {
  const _ReferralPromoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.referralCardGradientMid.withValues(alpha: 0.45),
      highlightColor: AppColors.referralCardGradientStart.withValues(
        alpha: 0.65,
      ),
      child: Container(
        height: 260,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.referralCardGradientEnd,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
