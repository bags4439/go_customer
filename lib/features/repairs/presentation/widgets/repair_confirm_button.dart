import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/constants/repair_constants.dart';

class RepairConfirmButton extends StatelessWidget {
  const RepairConfirmButton({
    super.key,
    required this.choice,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final bool? choice;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final enabled = choice != null && !isSubmitting;
    final label = choice == true
        ? RepairConstants.confirmYesButton
        : choice == false
        ? RepairConstants.confirmNoButton
        : RepairConstants.confirmButtonSelectOption;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.secondary : AppColors.surface,
          foregroundColor: enabled ? Colors.white : AppColors.textTertiary,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.buttonLarge),
      ),
    );
  }
}
