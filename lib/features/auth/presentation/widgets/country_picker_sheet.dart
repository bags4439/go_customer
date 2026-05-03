import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../domain/entities/country.dart';
import '../providers/countries_providers.dart';

class CountryPickerSheet extends ConsumerStatefulWidget {
  const CountryPickerSheet({
    super.key,
    required this.selectedIsoCode,
    required this.onSelected,
    this.sheetTitle,
    this.sheetSubtitle,
  });

  final String selectedIsoCode;
  final void Function(Country) onSelected;
  final String? sheetTitle;
  final String? sheetSubtitle;

  static Future<Country?> show(
    BuildContext context, {
    required String selectedIsoCode,
    String? sheetTitle,
    String? sheetSubtitle,
  }) async {
    Country? result;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CountryPickerSheet(
        selectedIsoCode: selectedIsoCode,
        sheetTitle: sheetTitle,
        sheetSubtitle: sheetSubtitle,
        onSelected: (country) {
          result = country;
          Navigator.of(context).pop();
        },
      ),
    );
    return result;
  }

  @override
  ConsumerState<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends ConsumerState<CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String get _query => _searchCtrl.text.toLowerCase().trim();

  List<Country> _filtered(List<Country> all) {
    if (_query.isEmpty) return all;
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(_query) ||
              c.isoCode.toLowerCase().contains(_query) ||
              c.dialCode.toLowerCase().contains(_query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.borderSolid,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.public_rounded,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sheetTitle ?? 'Where are you based?',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.sheetSubtitle ??
                                  'This helps us show prices '
                                      'in your currency.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                        color: _searchFocused
                            ? AppColors.secondary
                            : AppColors.borderSolid,
                        width: _searchFocused ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _searchFocus,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: null,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search countries',
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textTertiary,
                                height: null,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  left: 8,
                                  right: 12,
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: countriesAsync.when(
                    loading: () => const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (_, __) => Center(
                      child: Text(
                        'Could not load countries.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    data: (countries) {
                      final filtered = _filtered(countries);
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No countries found.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          32 + bottomInset,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.borderSolid,
                        ),
                        itemBuilder: (context, i) {
                          final country = filtered[i];
                          final isSelected =
                              country.isoCode == widget.selectedIsoCode;
                          return _CountryTile(
                            country: country,
                            isSelected: isSelected,
                            onTap: () => widget.onSelected(country),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  final Country country;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.selectionTint : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.secondary.withValues(alpha: 0.08),
        highlightColor: AppColors.secondary.withValues(alpha: 0.04),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    country.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (country.dialCode.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    country.dialCode,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
