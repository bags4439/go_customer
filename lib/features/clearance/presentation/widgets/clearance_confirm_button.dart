import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/clearance_providers.dart';

class ClearanceConfirmButton extends StatelessWidget {
  const ClearanceConfirmButton({
    super.key,
    required this.option,
    required this.isSubmitting,
    required this.onConfirm,
    required this.label,
  });

  final ClearanceOption? option;
  final bool isSubmitting;
  final VoidCallback onConfirm;
  final String label;

  @override
  Widget build(BuildContext context) {
    final enabled = option != null && !isSubmitting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.secondary : AppColors.surface,
          foregroundColor: enabled
              ? Colors.white
              : AppColors.primary.withValues(alpha: 0.6),
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
