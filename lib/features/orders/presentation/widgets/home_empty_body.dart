import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/coach_mark_card.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../../referral/presentation/widgets/referral_promo_card.dart';
import 'home_empty_how_it_works.dart';
import 'home_empty_illustrations.dart';
import 'home_layout_utils.dart';
import 'home_theme.dart';

class HomeEmptyBody extends ConsumerStatefulWidget {
  final String? firstName;

  const HomeEmptyBody({super.key, this.firstName});

  @override
  ConsumerState<HomeEmptyBody> createState() => _HomeEmptyBodyState();
}

class _HomeEmptyBodyState extends ConsumerState<HomeEmptyBody>
    with CoachMarkMixin<HomeEmptyBody> {
  final _importButtonKey = GlobalKey();

  @override
  String get coachMarkKey => GuideKeys.homeEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  20 + homeShellFloatingNavScrollBottomExtra(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homeTimeGreeting(),
                      style: AppTextStyles.sectionLabel.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: HomeColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.firstName != null
                          ? 'Hi ${widget.firstName}'
                          : 'Welcome',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        color: HomeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ready to buy your first car?',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13.5,
                        color: HomeColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CTA card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HomeColors.bgPrimary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: HomeColors.border,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const HomeEmptyCtaIllustration(),
                                const SizedBox(height: 16),

                                Text(
                                  'Buy your car from the US, Dubai or China',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 18,
                                    height: 1.25,
                                    color: HomeColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  'Tell us what you want, we handle everything '
                                  'from auction to your driveway.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: HomeColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                SizedBox(
                                  key: _importButtonKey,
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => GoRouter.of(
                                      context,
                                    ).push('/preferences/new'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HomeColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get started',
                                          style: AppTextStyles.buttonLarge,
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: HomeColors.bgSecondary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(17),
                                bottomRight: Radius.circular(17),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: HomeColors.border,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 11,
                                  color: HomeColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'No payment until your agent sends a request',
                                  style: AppTextStyles.caption.copyWith(
                                    color: HomeColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'HOW IT WORKS',
                      style: AppTextStyles.sectionLabel.copyWith(
                        fontWeight: FontWeight.w600,
                        color: HomeColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const HomeEmptyHowItWorksGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showCoachMark)
          CoachMarkOverlay(
            guideKey: GuideKeys.homeEmpty,
            targetKey: _importButtonKey,
            title: 'Import your first car',
            body:
                'Tap here to tell us exactly what '
                'car you want. No payment is ever '
                'taken until your agent sends a '
                'payment request.',
            spotlightShape: SpotlightShape.roundedRect,
            cardPosition: CardPosition.above,
            onDismiss: hideCoachMark,
            onFaqTap: () {
              hideCoachMark();
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );
  }
}
