import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/support_providers.dart';

class SupportBottomSheet extends ConsumerWidget {
  const SupportBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SupportBottomSheet(),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showLaunchErrorSnackBar(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showLaunchErrorSnackBar(context);
      }
    }
  }

  void _showLaunchErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open. Please try again.',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white, height: 1.2),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Digits only for [wa.me](https://wa.me) (country code, no +).
  static String sanitiseWhatsAppNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(supportContactProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      Icons.headset_mic_rounded,
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
                          'Customer Support',
                          style: AppTextStyles.titleSmall
                              .copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.1, color: AppColors.textPrimary, letterSpacing: 0.0),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "We're here to help.",
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary, height: 1.2, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSolid, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'SUPPORT HOURS',
                          style: AppTextStyles.badgeText
                              .copyWith(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _HoursRow(
                      day: 'Monday – Friday',
                      hours: '8:00 AM – 6:00 PM',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.borderSolid),
                    ),
                    const _HoursRow(
                      day: 'Saturday',
                      hours: '9:00 AM – 2:00 PM',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.borderSolid),
                    ),
                    const _HoursRow(
                      day: 'Sunday',
                      hours: 'Closed',
                      isClosed: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: contactAsync.when(
                loading: () => const _ContactShimmer(),
                error: (_, __) => const _UnavailableNote(),
                data: (contact) {
                  final waDigits = contact.hasWhatsApp
                      ? SupportBottomSheet.sanitiseWhatsAppNumber(
                          contact.whatsappNumber!,
                        )
                      : '';
                  final showWhatsApp =
                      contact.hasWhatsApp && waDigits.isNotEmpty;
                  if (!contact.hasCall && !showWhatsApp) {
                    return const _UnavailableNote();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (contact.hasCall)
                        _ContactTile(
                          icon: Icons.call_rounded,
                          label: 'Call us',
                          number: contact.callNumber!.trim(),
                          accentColor: AppColors.success,
                          accentBg: AppColors.successMutedBackground,
                          onTap: () => _launch(
                            context,
                            Uri(
                              scheme: 'tel',
                              path: contact.callNumber!.trim(),
                            ),
                          ),
                        ),
                      if (contact.hasCall && showWhatsApp)
                        const SizedBox(height: 10),
                      if (showWhatsApp)
                        _ContactTile(
                          icon: Icons.chat_rounded,
                          label: 'WhatsApp',
                          number: contact.whatsappNumber!.trim(),
                          accentColor: const Color(0xFF25D366),
                          accentBg: const Color(0xFFECFDF5),
                          onTap: () => _launch(
                            context,
                            Uri.parse('https://wa.me/$waDigits'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  final String day;
  final String hours;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary, height: 1.0, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.0),
        ),
        Text(
          hours,
          style: AppTextStyles.labelLarge
              .copyWith(
            fontSize: 13,
            color: isClosed ? AppColors.textTertiary : AppColors.textPrimary,
            fontWeight: isClosed ? FontWeight.w400 : FontWeight.w500,
            letterSpacing: 0.0,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.number,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String number;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
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
                      Text(
                        label,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        number,
                        style: AppTextStyles.cardLabel,
                      ),
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

class _ContactShimmer extends StatelessWidget {
  const _ContactShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box() => Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSolid, width: 0.5),
        ),
      ),
    );

    return Column(children: [box(), const SizedBox(height: 10), box()]);
  }
}

class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Text(
        'Support contact details are temporarily '
        'unavailable. Please try again shortly.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(height: 1.5, color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.0),
      ),
    );
  }
}
