import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/submitting_primary_button.dart';
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
    final label = choice == true
        ? RepairConstants.confirmYesButton
        : choice == false
        ? RepairConstants.confirmNoButton
        : RepairConstants.confirmButtonSelectOption;

    return SubmittingPrimaryButton(
      label: label,
      hasSelection: choice != null,
      isSubmitting: isSubmitting,
      onPressed: onConfirm,
      textStyle: choice == null
          ? AppTextStyles.buttonLarge.copyWith(color: AppColors.textPrimary)
          : AppTextStyles.buttonLarge,
    );
  }
}
