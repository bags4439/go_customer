import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import 'country_picker_sheet.dart';

/// Phone row with country dial picker and digit field.
/// Uses a single outer border — no inner focus ring on the text field.
class PhoneDialInputField extends ConsumerStatefulWidget {
  const PhoneDialInputField({
    super.key,
    required this.dialCode,
    required this.countryFlag,
    required this.initialDigits,
    required this.onDigitsChanged,
    required this.onDialCodeChanged,
    this.onSubmit,
    this.hasError = false,
    this.autofocus = false,
    this.hintText = 'Phone number',
    this.pickerSubtitle = 'Choose your country to set the dial code.',
    this.maxLength = 15,
  });

  final String dialCode;
  final String countryFlag;
  final String initialDigits;
  final ValueChanged<String> onDigitsChanged;
  final void Function(String dialCode, String flag) onDialCodeChanged;
  final VoidCallback? onSubmit;
  final bool hasError;
  final bool autofocus;
  final String hintText;
  final String pickerSubtitle;
  final int maxLength;

  @override
  ConsumerState<PhoneDialInputField> createState() =>
      _PhoneDialInputFieldState();
}

class _PhoneDialInputFieldState extends ConsumerState<PhoneDialInputField> {
  final _focus = FocusNode();
  late final TextEditingController _controller;
  bool _focused = false;
  bool _pickerOpen = false;

  static const _plainFieldDecoration = InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    isCollapsed: true,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDigits);
    _controller.addListener(() => widget.onDigitsChanged(_controller.text));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void didUpdateWidget(PhoneDialInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDigits != oldWidget.initialDigits &&
        widget.initialDigits != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialDigits,
        selection: TextSelection.collapsed(offset: widget.initialDigits.length),
      );
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openDialCodePicker() async {
    setState(() => _pickerOpen = true);
    final country = await CountryPickerSheet.show(
      context,
      selectedIsoCode: '',
      sheetTitle: 'Select country code',
      sheetSubtitle: widget.pickerSubtitle,
    );
    if (!mounted) return;
    setState(() => _pickerOpen = false);
    if (country != null && country.dialCode.isNotEmpty) {
      widget.onDialCodeChanged(country.dialCode, country.flag);
    }
  }

  bool get _isActive => _focused || _pickerOpen;

  Color get _borderColor {
    if (widget.hasError) return AppColors.danger;
    if (_isActive) return AppColors.secondary;
    return AppColors.borderSolid;
  }

  double get _borderWidth => (widget.hasError || _isActive) ? 1.5 : 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      decoration: BoxDecoration(
        color: widget.hasError
            ? AppColors.dangerMutedBackground
            : Colors.white,
        border: Border.all(color: _borderColor, width: _borderWidth),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openDialCodePicker,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.countryFlag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.dialCode,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 26,
                      color: AppColors.borderSolid,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.maxLength),
              ],
              onFieldSubmitted: (_) => widget.onSubmit?.call(),
              textInputAction: widget.onSubmit != null
                  ? TextInputAction.done
                  : TextInputAction.next,
              style: AppTextStyles.bodyLarge,
              decoration: _plainFieldDecoration.copyWith(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                  height: null,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
