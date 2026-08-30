import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../auth/domain/value_objects/phone_number.dart';
import '../../../auth/presentation/widgets/phone_dial_input_field.dart';
import '../providers/order_creation_context.dart';

class CustomerLookupScreen extends ConsumerStatefulWidget {
  const CustomerLookupScreen({super.key});

  @override
  ConsumerState<CustomerLookupScreen> createState() =>
      _CustomerLookupScreenState();
}

class _CustomerLookupScreenState extends ConsumerState<CustomerLookupScreen> {
  String _dialCode = '+233';
  String _countryFlag = '🇬🇭';
  String _phoneDigits = '';
  bool _loading = false;
  String? _error;

  void _updatePhoneDigits(String digits) {
    setState(() {
      _phoneDigits = digits;
      _error = null;
    });
    ref.read(assistedCustomerProvider.notifier).state = null;
  }

  void _updateDialCode(String dialCode, String flag) {
    setState(() {
      _dialCode = dialCode;
      _countryFlag = flag;
      _error = null;
    });
    ref.read(assistedCustomerProvider.notifier).state = null;
  }

  Future<void> _lookup() async {
    FocusScope.of(context).unfocus();

    String? phone;
    PhoneNumber.fromDialCodeAndDigits(
      dialCode: _dialCode,
      digits: _phoneDigits,
    ).fold(
      (failure) => setState(() => _error = failure.message),
      (value) => phone = value.value,
    );
    if (phone == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('lookupCustomerByPhone');
      final result = await callable.call<Map<String, dynamic>>({
        'phone': phone,
      });
      final data = result.data;
      ref.read(assistedCustomerProvider.notifier).state = AssistedCustomer(
        phone: phone!,
        fullName: data['fullName'] as String,
        maskedPhone: data['maskedPhone'] as String,
      );
      if (mounted) {
        setState(() => _loading = false);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message ?? 'Customer lookup failed.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Customer lookup failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(assistedCustomerProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Find customer')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              Text('Customer phone number', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Only customers who have already registered can be selected.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              PhoneDialInputField(
                dialCode: _dialCode,
                countryFlag: _countryFlag,
                initialDigits: _phoneDigits,
                onDigitsChanged: _updatePhoneDigits,
                onDialCodeChanged: _updateDialCode,
                onSubmit: _loading ? null : _lookup,
                hasError: _error != null,
                hintText: 'Phone number',
                pickerSubtitle:
                    'Choose the country for the customer phone number.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: 'Find customer',
                onPressed: _lookup,
                isLoading: _loading,
              ),
              if (customer != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.successMutedBackground,
                    border: Border.all(color: AppColors.successMutedBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.fullName,
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              customer.maskedPhone,
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
                AppPrimaryButton(
                  label: 'Continue for this customer',
                  onPressed: () => context.go('/preferences/new?assisted=1'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
