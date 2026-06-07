import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/content/guide_context_registry.dart';
import '../providers/guide_providers.dart';
import 'guide_learn_more_sheet.dart';

/// Brief, dismissible in-page hint with optional learn-more sheet.
///
/// Use [GuideHint] with a [GuideKeys] constant. Copy lives in
/// [GuideContextRegistry].
class GuideHint extends ConsumerWidget {
  const GuideHint({
    super.key,
    required this.guideKey,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  final String guideKey;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = GuideContextRegistry.entryFor(guideKey);
    if (entry == null) return const SizedBox.shrink();

    final seenAsync = ref.watch(hasSeenGuideProvider(guideKey));

    return seenAsync.when(
      data: (seen) {
        if (seen) return const SizedBox.shrink();
        return Padding(
          padding: padding,
          child: _HintCard(
            entry: entry,
            onLearnMore: () => GuideLearnMoreSheet.show(context, guideKey),
            onDismiss: () => ref
                .read(guideNotifierProvider.notifier)
                .markSeen(guideKey),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.entry,
    required this.onLearnMore,
    required this.onDismiss,
  });

  final GuideContextEntry entry;
  final VoidCallback onLearnMore;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final brief = entry.briefFor(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.infoText.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: AppColors.infoText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.briefTitle != null) ...[
                  Text(
                    entry.briefTitle!,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.infoText,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  brief,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onLearnMore,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Learn more',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// @deprecated Use [GuideHint] instead.
typedef GuideContextualHintBanner = GuideHint;
