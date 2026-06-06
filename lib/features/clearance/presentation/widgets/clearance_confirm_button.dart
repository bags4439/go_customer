import 'package:flutter/material.dart';

import '../../../../core/widgets/submitting_primary_button.dart';
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
    return SubmittingPrimaryButton(
      label: label,
      hasSelection: option != null,
      isSubmitting: isSubmitting,
      onPressed: onConfirm,
    );
  }
}
