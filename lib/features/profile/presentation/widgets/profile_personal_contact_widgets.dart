import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/countries_providers.dart';
import '../../../auth/presentation/widgets/country_picker_sheet.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import 'ghana_card_profile_row.dart';
import 'profile_language_currency_widgets.dart';
import 'profile_section_shell.dart';
import 'profile_ui_tokens.dart';

class ProfilePersonalDetailsSection extends ConsumerWidget {
  const ProfilePersonalDetailsSection({
    super.key,
    required this.user,
    required this.onSaveFullName,
    required this.onSaveLocation,
    required this.onPhoneTap,
  });

  final AppUser user;
  final void Function(String) onSaveFullName;
  final void Function(String) onSaveLocation;
  final VoidCallback onPhoneTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(profileEditProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileEditRow(
          label: ProfileConstants.fullNameLabel,
          value: user.fullName,
          expanded: edit.expandedField == 'fullName',
          draftValue: edit.draftValue,
          errorMessage: edit.expandedField == 'fullName'
              ? edit.errorMessage
              : null,
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('fullName', user.fullName),
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {
            final v = (edit.draftValue ?? user.fullName).trim();
            if (v.length < 2) {
              ref
                  .read(profileEditProvider.notifier)
                  .setError('At least 2 characters');
              return;
            }
            onSaveFullName(v);
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
          validator: (v) =>
              v.trim().length < 2 ? 'At least 2 characters' : null,
        ),
        const ProfileSectionDivider(),
        ProfileEditRow(
          label: ProfileConstants.locationLabel,
          value: user.location.isNotEmpty ? user.location : 'Not set',
          expanded: edit.expandedField == 'location',
          draftValue: edit.expandedField == 'location' ? edit.draftValue : null,
          errorMessage: edit.expandedField == 'location'
              ? edit.errorMessage
              : null,
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('location', user.location),
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {
            final v = (edit.draftValue ?? user.location).trim();
            if (v.length < 2) {
              ref
                  .read(profileEditProvider.notifier)
                  .setError('At least 2 characters');
              return;
            }
            onSaveLocation(v);
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
          validator: (v) =>
              v.trim().length < 2 ? 'At least 2 characters' : null,
        ),
        const ProfileSectionDivider(),
        ProfileEditRow(
          label: ProfileConstants.phoneLabel,
          value: user.phone,
          expanded: edit.expandedField == 'phone',
          draftValue: edit.draftValue,
          isPhone: true,
          onTap: onPhoneTap,
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {},
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
          subtitle: ProfileConstants.phoneChangeNote,
        ),
        const ProfileSectionDivider(),
        ProfileCountryRow(currentIsoCode: user.country, userId: user.id),
        const ProfileSectionDivider(),
        GhanaCardProfileRow(user: user),
      ],
    );
  }
}

class ProfileContactChannelsSection extends ConsumerWidget {
  const ProfileContactChannelsSection({
    super.key,
    required this.user,
    required this.onSaveSmsPhone,
    required this.onSaveWhatsappPhone,
    required this.onSaveEmail,
  });

  final AppUser user;
  final void Function(String) onSaveSmsPhone;
  final void Function(String) onSaveWhatsappPhone;
  final void Function(String) onSaveEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(profileEditProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfilePhoneEditRow(
          label: ProfileConstants.smsPhoneLabel,
          value: user.smsPhone?.isNotEmpty == true ? user.smsPhone! : 'Not set',
          expanded: edit.expandedField == 'smsPhone',
          errorMessage: edit.expandedField == 'smsPhone'
              ? edit.errorMessage
              : null,
          subtitle: 'Used for order status SMS updates',
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('smsPhone', user.smsPhone ?? ''),
          onSave: (fullNumber) {
            onSaveSmsPhone(fullNumber);
            ref.read(profileEditProvider.notifier).collapse();
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
        ),
        const ProfileSectionDivider(),
        ProfilePhoneEditRow(
          label: ProfileConstants.whatsappLabel,
          value: user.whatsappPhone?.isNotEmpty == true
              ? user.whatsappPhone!
              : 'Not set',
          expanded: edit.expandedField == 'whatsappPhone',
          errorMessage: edit.expandedField == 'whatsappPhone'
              ? edit.errorMessage
              : null,
          subtitle: 'Make sure this number has WhatsApp installed',
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('whatsappPhone', user.whatsappPhone ?? ''),
          onSave: (fullNumber) {
            onSaveWhatsappPhone(fullNumber);
            ref.read(profileEditProvider.notifier).collapse();
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
        ),
        const ProfileSectionDivider(),
        ProfileEditRow(
          label: ProfileConstants.emailLabel,
          value: user.email?.isNotEmpty == true ? user.email! : 'Not set',
          expanded: edit.expandedField == 'email',
          draftValue: edit.expandedField == 'email' ? edit.draftValue : null,
          errorMessage: edit.expandedField == 'email'
              ? edit.errorMessage
              : null,
          subtitle: 'Used for payment receipts and order summaries',
          onTap: () => ref
              .read(profileEditProvider.notifier)
              .expandField('email', user.email ?? ''),
          onDraftChanged: (v) =>
              ref.read(profileEditProvider.notifier).updateDraft(v),
          onSave: () {
            final v = (edit.draftValue ?? user.email ?? '').trim();
            onSaveEmail(v);
          },
          onCancel: () => ref.read(profileEditProvider.notifier).collapse(),
        ),
      ],
    );
  }
}

class ProfileEditRow extends StatelessWidget {
  const ProfileEditRow({
    super.key,
    required this.label,
    required this.value,
    required this.expanded,
    required this.onTap,
    required this.onSave,
    required this.onCancel,
    this.draftValue,
    this.errorMessage,
    this.onDraftChanged,
    this.validator,
    this.isPhone = false,
    this.subtitle,
  });

  final String label;
  final String value;
  final bool expanded;
  final String? draftValue;
  final String? errorMessage;
  final VoidCallback onTap;
  final void Function(String)? onDraftChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? Function(String)? validator;
  final bool isPhone;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (!expanded)
                          Text(
                            value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!expanded)
                    const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: ProfileUi.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: draftValue ?? value,
                        keyboardType: isPhone
                            ? TextInputType.phone
                            : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: isPhone ? '+XX XXXXXXXXX' : null,
                          isDense: true,
                          errorText: errorMessage,
                          errorStyle: AppTextStyles.caption.copyWith(
                            color: ProfileUi.danger,
                          ),
                        ),
                        onChanged: onDraftChanged,
                        autofocus: true,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: ProfileUi.textTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: onCancel,
                            child: Text(
                              ProfileConstants.cancel,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: ProfileUi.textTertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final v = draftValue ?? value;
                              if (validator != null && validator!(v) != null) {
                                return;
                              }
                              onSave();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProfileUi.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Save',
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (expanded && errorMessage != null)
          AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                errorMessage!,
                style: AppTextStyles.caption.copyWith(color: ProfileUi.danger),
              ),
            ),
          ),
      ],
    );
  }
}

/// A profile edit row specifically for phone number fields.
/// Supports a tappable country code prefix that opens
/// [CountryPickerSheet], followed by a digits-only input.
///
/// Stores the full E.164 number (dialCode + digits) via [onSave].
class ProfilePhoneEditRow extends ConsumerStatefulWidget {
  const ProfilePhoneEditRow({
    super.key,
    required this.label,
    required this.value,
    required this.expanded,
    required this.onTap,
    required this.onSave,
    required this.onCancel,
    this.subtitle,
    this.errorMessage,
  });

  final String label;

  /// Current saved value — full E.164 e.g. +233XXXXXXXXX or 'Not set'
  final String value;
  final bool expanded;
  final VoidCallback onTap;

  /// Called with the full E.164 number when the user taps Save
  final void Function(String) onSave;
  final VoidCallback onCancel;
  final String? subtitle;
  final String? errorMessage;

  @override
  ConsumerState<ProfilePhoneEditRow> createState() =>
      _ProfilePhoneEditRowState();
}

class _ProfilePhoneEditRowState extends ConsumerState<ProfilePhoneEditRow> {
  late String _dialCode;
  late String _flag;
  late String _digits;
  late TextEditingController _ctrl;
  bool _pickerOpen = false;

  @override
  void initState() {
    super.initState();
    _initFromValue(widget.value);
    _ctrl = TextEditingController(text: _digits);
    _ctrl.addListener(() {
      setState(() {
        _digits = _ctrl.text;
      });
    });
  }

  @override
  void didUpdateWidget(ProfilePhoneEditRow old) {
    super.didUpdateWidget(old);
    if (widget.expanded && !old.expanded) {
      _initFromValue(widget.value);
      _ctrl.text = _digits;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Parses a saved E.164 value into dial code + digits.
  /// Falls back to Ghana defaults.
  void _initFromValue(String raw) {
    if (raw.isEmpty || raw == 'Not set' || !raw.startsWith('+')) {
      _dialCode = '+233';
      _flag = '🇬🇭';
      _digits = '';
      return;
    }

    final countries = ref.read(countriesProvider).valueOrNull ?? [];
    final sorted = [...countries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

    for (final c in sorted) {
      if (c.dialCode.isNotEmpty && raw.startsWith(c.dialCode)) {
        _dialCode = c.dialCode;
        _flag = c.flag;
        _digits = raw.substring(c.dialCode.length);
        return;
      }
    }

    _dialCode = '+233';
    _flag = '🇬🇭';
    _digits = raw.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _openPicker() async {
    setState(() => _pickerOpen = true);
    final country = await CountryPickerSheet.show(
      context,
      selectedIsoCode: '',
      sheetTitle: 'Select country code',
      sheetSubtitle: 'Choose the country for this phone number.',
    );
    if (!mounted) return;
    setState(() => _pickerOpen = false);
    if (country != null && country.dialCode.isNotEmpty) {
      setState(() {
        _dialCode = country.dialCode;
        _flag = country.flag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (!widget.expanded)
                          Text(
                            widget.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!widget.expanded)
                    const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: ProfileUi.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: widget.expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _pickerOpen
                                ? ProfileUi.primary
                                : ProfileUi.border,
                            width: _pickerOpen ? 1.5 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _openPicker,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _flag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _dialCode,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: ProfileUi.textTertiary,
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 1,
                                        height: 22,
                                        color: ProfileUi.border,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _ctrl,
                                autofocus: true,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'XX XXX XXXX',
                                  hintStyle: AppTextStyles.bodySmall.copyWith(
                                    color: ProfileUi.textTertiary,
                                  ),
                                  isDense: true,
                                  border: InputBorder.none,
                                  errorText: widget.errorMessage,
                                  errorStyle: AppTextStyles.caption.copyWith(
                                    color: ProfileUi.danger,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: ProfileUi.textTertiary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: widget.onCancel,
                            child: Text(
                              ProfileConstants.cancel,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: ProfileUi.textTertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final digits = _digits.trim();
                              if (digits.isEmpty) {
                                return;
                              }
                              widget.onSave('$_dialCode$digits');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProfileUi.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Save',
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
