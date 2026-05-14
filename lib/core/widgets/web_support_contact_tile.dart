import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

/// Tappable contact tile for the web dashboard right panel.
/// Matches [_ContactTile] in [SupportBottomSheet] (layout and behaviour).
class WebSupportContactTile extends StatelessWidget {
  const WebSupportContactTile({
    super.key,
    required this.icon,
    required this.label,
    required this.number,
    required this.accentColor,
    required this.accentBg,
    required this.uri,
  });

  final IconData icon;
  final String label;
  final String number;
  final Color accentColor;
  final Color accentBg;

  /// URI to launch on tap (`tel:` for calls, `https://wa.me/...` for WhatsApp).
  final Uri uri;

  Future<void> _launch(BuildContext context) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open. Please try again.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                height: 1.2,
              ),
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open. Please try again.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                height: 1.2,
              ),
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _launch(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: accentColor.withValues(alpha: 0.08),
        highlightColor: accentColor.withValues(alpha: 0.04),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSolid, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: accentColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label, style: AppTextStyles.titleSmall),
                      const SizedBox(height: 1),
                      Text(number, style: AppTextStyles.cardLabel),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
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
