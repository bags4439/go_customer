import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:go_customer/core/widgets/web_support_contact_tile.dart';
import 'package:go_customer/features/support/presentation/widgets/support_contact_section.dart';
import 'package:go_customer/features/referral/presentation/widgets/referral_promo_card.dart';
import 'package:go_customer/features/support/presentation/providers/support_providers.dart';

/// Persistent right panel shown on web for home, notifications and profile.
///
/// Width is set by the parent [Expanded] flex ratio (typically 4 of 9).
///
/// Contains: (1) Customer support — header, hours card, call + WhatsApp tiles.
/// (2) [ReferralPromoCard].
class WebDashboardRightPanel extends ConsumerWidget {
  const WebDashboardRightPanel({super.key});

  static String _sanitiseWa(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(supportContactProvider);

    return Container(
      padding: const EdgeInsets.only(top: 4, left: 32, right: 16),
      child: CardContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.headset_mic_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Support',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "We're here to help.",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SupportHoursCard(),
                    const SizedBox(height: 12),
                    contactAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (contact) {
                        final waDigits = contact.hasWhatsApp
                            ? _sanitiseWa(contact.whatsappNumber!)
                            : '';
                        final showWa = contact.hasWhatsApp && waDigits.isNotEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (contact.hasCall) ...[
                              WebSupportContactTile(
                                icon: Icons.call_rounded,
                                label: 'Call us',
                                number: contact.callNumber!.trim(),
                                accentColor: AppColors.success,
                                accentBg: AppColors.successMutedBackground,
                                uri: Uri(
                                  scheme: 'tel',
                                  path: contact.callNumber!.trim(),
                                ),
                              ),
                              if (showWa) const SizedBox(height: 10),
                            ],
                            if (showWa)
                              WebSupportContactTile(
                                icon: Icons.chat_rounded,
                                label: 'WhatsApp',
                                number: contact.whatsappNumber!.trim(),
                                accentColor: const Color(0xFF25D366),
                                accentBg: const Color(0xFFECFDF5),
                                uri: Uri.parse('https://wa.me/$waDigits'),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: AppColors.borderSolid,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: ReferralPromoCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
