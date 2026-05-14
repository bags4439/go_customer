import 'package:flutter/material.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import '../../core/constants/profile_constants.dart';
import 'profile_section_shell.dart';
import 'profile_ui_tokens.dart';

class ProfileSupportSection extends StatelessWidget {
  const ProfileSupportSection({super.key, required this.onResetGuide});

  final Future<void> Function() onResetGuide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileSupportRow(
          label: ProfileConstants.contactSupport,
          onTap: () => SupportBottomSheet.show(context),
        ),
        const ProfileSectionDivider(),
        ProfileSupportRow(
          label: ProfileConstants.faqs,
          onTap: () => GuideFaqSheet.show(context),
        ),
        const ProfileSectionDivider(),
        ProfileSupportRow(
          label: ProfileConstants.termsAndPrivacy,
          onTap: () => launchUrl(
            Uri.parse(ProfileConstants.termsUrl),
            mode: LaunchMode.inAppWebView,
          ),
        ),
        const ProfileSectionDivider(),
        ProfileSupportRow(
          label: ProfileConstants.rateTheApp,
          icon: Icons.star,
          iconColor: ProfileUi.warning,
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
        const ProfileSectionDivider(),
        ProfileMenuTile(
          icon: Icons.tour_outlined,
          label: 'App guide',
          sublabel: 'Replay the in-app walkthrough',
          onTap: () => onResetGuide(),
        ),
      ],
    );
  }
}

class ProfileSupportRow extends StatelessWidget {
  const ProfileSupportRow({
    super.key,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                icon ?? Icons.open_in_new,
                size: 20,
                color: iconColor ?? ProfileUi.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.scaleForWebPanel = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool scaleForWebPanel;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final labelStyle = scaleForWebPanel
        ? AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: AppBreakpoints.scaledFontSize(13, sw),
          )
        : AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          );
    final subStyle = scaleForWebPanel
        ? AppTextStyles.cardLabel.copyWith(
            color: ProfileUi.textTertiary,
            fontSize: AppBreakpoints.scaledFontSize(11, sw),
          )
        : AppTextStyles.cardLabel.copyWith(color: ProfileUi.textTertiary);
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
              Icon(icon, size: 22, color: ProfileUi.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: labelStyle),
                    const SizedBox(height: 2),
                    Text(sublabel, style: subStyle),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: ProfileUi.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileLogOutButton extends StatelessWidget {
  const ProfileLogOutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ProfileUi.danger,
          side: const BorderSide(color: ProfileUi.danger, width: 1),
        ),
        child: Text(ProfileConstants.logOut, style: AppTextStyles.labelLarge),
      ),
    );
  }
}

class ProfileDeleteAccountLink extends StatelessWidget {
  const ProfileDeleteAccountLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          ProfileConstants.deleteAccount,
          style: AppTextStyles.cardLabel.copyWith(
            color: ProfileUi.danger,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
