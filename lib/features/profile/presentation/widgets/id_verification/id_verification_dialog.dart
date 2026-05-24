import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/utils/responsive_layout.dart';

import '../../providers/profile_providers.dart';
import 'id_verification_form.dart';

/// Shows ID verification in a centered dialog on web profile.
Future<void> showProfileIdVerificationDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) => const IdVerificationDialog(),
  );
}

class IdVerificationDialog extends ConsumerWidget {
  const IdVerificationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docLabel = ref.watch(currentUserProfileProvider).valueOrNull
            ?.idDocumentLabel ??
        'ID Verification';

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: () {
            final w = ResponsiveLayout.contentMaxWidth(context);
            if (!w.isFinite) return 480.0;
            return w.clamp(360.0, 520.0);
          }(),
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      docLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: IdVerificationForm(
                showHeading: true,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                onSuccess: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
