import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum CardPosition { above, below, auto }

class CoachMarkCard extends StatelessWidget {
  const CoachMarkCard({
    super.key,
    required this.title,
    required this.body,
    required this.onDismiss,
    this.onNext,
    this.showFaqLink = true,
    this.onFaqTap,
    this.dismissLabel,
  });

  final String title;
  final String body;
  final VoidCallback onDismiss;

  /// When non-null shows "Next →" button and
  /// calls this on tap instead of dismissing.
  final VoidCallback? onNext;

  final bool showFaqLink;
  final VoidCallback? onFaqTap;

  /// Custom label for the dismiss button.
  /// Defaults to "Got it" when onNext is null,
  /// "Skip guide" when onNext is non-null.
  final String? dismissLabel;

  @override
  Widget build(BuildContext context) {
    final hasNext = onNext != null;
    final gotItLabel = dismissLabel ?? (hasNext ? 'Skip guide' : 'Got it');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall
                .copyWith(height: 1.3, color: AppColors.textPrimary, letterSpacing: 0.0),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showFaqLink)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFaqTap,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 48,
                            minWidth: 48,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'View FAQ →',
                                style: AppTextStyles.labelMedium
                                    .copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 48,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Center(
                        child: Text(
                          gotItLabel,
                          style: AppTextStyles.labelLarge
                              .copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasNext) ...[
                const SizedBox(width: 8),
                Material(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onNext,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        minWidth: 48,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Center(
                          child: Text(
                            'Next →',
                            style: AppTextStyles.labelLarge
                                .copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
