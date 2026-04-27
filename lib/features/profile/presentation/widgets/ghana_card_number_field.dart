import 'package:flutter/material.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

class GhanaCardNumberField extends StatefulWidget {
  const GhanaCardNumberField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'GHA-XXXXXXXXX-X',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<GhanaCardNumberField> createState() => _GhanaCardNumberFieldState();
}

class _GhanaCardNumberFieldState extends State<GhanaCardNumberField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _focused ? AppColors.secondary : AppColors.borderSolid,
          width: _focused ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        textCapitalization: TextCapitalization.characters,
        onChanged: widget.onChanged,
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: null,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            color: AppColors.textTertiary,
            height: null,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
