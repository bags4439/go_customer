import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../core/constants/delivery_constants.dart';
import '../../domain/entities/delivery.dart';
import '../providers/delivery_providers.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen>
    with CoachMarkMixin<DeliveryScreen> {
  final _locationSectionKey = GlobalKey();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _isSavingLocation = false;
  bool _isConfirming = false;
  bool _isSearching = false;
  bool _editingLocation = false;
  List<_PlaceSuggestion> _suggestions = [];
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedLocationLabel;
  Timer? _searchDebounce;

  @override
  String get coachMarkKey => GuideKeys.stageDelivery;

  bool _showDeliveryLocationCoach(Delivery? d) {
    if (d == null) return false;
    if (d.isConfirmed == true) return false;
    if (d.hasLocation == true && !_editingLocation) return false;
    return true;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _snackError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: Colors.white, height: 1.3),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _snackSuccess(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: Colors.white, height: 1.3),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _prefillFromDelivery(Delivery d) {
    _addressCtrl.text = d.deliveryAddress ?? '';
    _cityCtrl.text = d.deliveryCity ?? '';
    _searchCtrl.clear();
    _suggestions = [];
    _selectedLat = d.latitude;
    _selectedLng = d.longitude;
    _selectedLocationLabel = d.locationLabel ?? d.deliveryAddress;
  }

  Widget _wrapScrollable(BuildContext context, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(
      deliveryScreenStateProvider(widget.orderId),
    );
    final deliveryAsync = ref.watch(
      deliveryProvider(widget.orderId),
    );
    final delivery = deliveryAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
          ),
          color: AppColors.textPrimary,
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Delivery',
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          GuideHelpButton(
            onShowGuide: showCoachMarkManually,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppColors.borderSolid,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _buildBody(
              context,
              screenState,
              delivery,
              deliveryAsync,
            ),
          ),
          if (showCoachMark &&
              _showDeliveryLocationCoach(delivery))
            CoachMarkOverlay(
              guideKey: GuideKeys.stageDelivery,
              targetKey: _locationSectionKey,
              title: 'Set your delivery address',
              body:
                  'Tell us where to bring your car. Your agent will deliver it directly'
                  ' to this address.',
              spotlightShape: SpotlightShape.roundedRect,
              onDismiss: hideCoachMark,
              onFaqTap: () {
                hideCoachMark();
                GuideFaqSheet.show(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeliveryScreenState screenState,
    Delivery? delivery,
    AsyncValue<Delivery?> deliveryAsync,
  ) {
    if (deliveryAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (deliveryAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                DeliveryConstants.errorMessage,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  ref.invalidate(
                    deliveryProvider(widget.orderId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    switch (screenState) {
      case DeliveryScreenState.notAvailable:
        return _wrapScrollable(
          context,
          _State0NotAvailable(orderId: widget.orderId),
        );

      case DeliveryScreenState.choice:
        return _wrapScrollable(
          context,
          _State1Choice(
            orderId: widget.orderId,
            onConfirmAgent: _confirmAgentDelivery,
            onConfirmSelf: _confirmSelfPickup,
          ),
        );

      case DeliveryScreenState.awaitingPaymentClearance:
        return _wrapScrollable(
          context,
          _State2AwaitingPayment(orderId: widget.orderId),
        );

      case DeliveryScreenState.addressEntry:
        return _wrapScrollable(
          context,
          KeyedSubtree(
            key: _locationSectionKey,
            child: _LocationInputState(
              addressCtrl: _addressCtrl,
              cityCtrl: _cityCtrl,
              searchCtrl: _searchCtrl,
              isSaving: _isSavingLocation,
              isSearching: _isSearching,
              suggestions: _suggestions,
              selectedLat: _selectedLat,
              selectedLng: _selectedLng,
              selectedLabel: _selectedLocationLabel,
              onSearchChanged: _onSearchChangedDebounced,
              onSuggestionSelected: _onSuggestionSelected,
              onUseGps: _isSavingLocation ? null : _useGpsLocation,
              onSaveManual:
                  _isSavingLocation ? null : _saveManualLocation,
            ),
          ),
        );

      case DeliveryScreenState.locationSet:
        if (_editingLocation) {
          return _wrapScrollable(
            context,
            KeyedSubtree(
              key: _locationSectionKey,
              child: _LocationInputState(
                addressCtrl: _addressCtrl,
                cityCtrl: _cityCtrl,
                searchCtrl: _searchCtrl,
                isSaving: _isSavingLocation,
                isSearching: _isSearching,
                suggestions: _suggestions,
                selectedLat: _selectedLat,
                selectedLng: _selectedLng,
                selectedLabel: _selectedLocationLabel,
                onSearchChanged: _onSearchChangedDebounced,
                onSuggestionSelected: _onSuggestionSelected,
                onUseGps: _isSavingLocation ? null : _useGpsLocation,
                onSaveManual:
                    _isSavingLocation ? null : _saveManualLocation,
              ),
            ),
          );
        }
        return _wrapScrollable(
          context,
          _LocationSetState(
            delivery: delivery!,
            isConfirming: _isConfirming,
            onEdit: () => setState(() {
              _editingLocation = true;
              _prefillFromDelivery(delivery);
            }),
            onConfirm: () => _confirmDelivery(),
            onViewMap: () => _openMap(delivery),
          ),
        );

      case DeliveryScreenState.selfPickup:
        return _wrapScrollable(
          context,
          _State5SelfPickup(
            orderId: widget.orderId,
            delivery: delivery!,
          ),
        );

      case DeliveryScreenState.confirmed:
        return _wrapScrollable(
          context,
          _ConfirmedState(orderId: widget.orderId),
        );
    }
  }

  Future<void> _confirmAgentDelivery() async {
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.confirmAgentDelivery(widget.orderId);
    if (!mounted) return;
    result.fold(
      (f) => _snackError(f.message),
      (_) {},
    );
  }

  Future<void> _confirmSelfPickup() async {
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.confirmSelfPickup(widget.orderId);
    if (!mounted) return;
    result.fold(
      (f) => _snackError(f.message),
      (_) {},
    );
  }

  void _onSearchChangedDebounced(String query) {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetchSuggestions(trimmed);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (AppConstants.googlePlacesApiKey == 'YOUR_KEY') {
      if (mounted) {
        setState(() => _isSearching = false);
      }
      return;
    }
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=${AppConstants.googlePlacesApiKey}'
        '&components=country:gh',
      );
      final response = await http.get(url);
      if (response.statusCode != 200 || !mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        return;
      }
      final predictions = data['predictions'] as List? ?? [];
      final list = <_PlaceSuggestion>[];
      for (final p in predictions) {
        if (p is! Map<String, dynamic>) continue;
        final id = p['place_id'] as String?;
        final desc = p['description'] as String?;
        if (id != null && desc != null) {
          list.add(_PlaceSuggestion(placeId: id, description: desc));
        }
      }
      setState(() => _suggestions = list);
    } catch (_) {
      // User can still enter manually
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _onSuggestionSelected(_PlaceSuggestion suggestion) async {
    _searchCtrl.text = suggestion.description;
    setState(() => _suggestions = []);

    if (AppConstants.googlePlacesApiKey != 'YOUR_KEY') {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${Uri.encodeComponent(suggestion.placeId)}'
          '&fields=geometry,formatted_address'
          '&key=${AppConstants.googlePlacesApiKey}',
        );
        final response = await http.get(url);
        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final result = data['result'] as Map<String, dynamic>?;
            final loc =
                result?['geometry']?['location'] as Map<String, dynamic>?;
            if (loc != null) {
              setState(() {
                _selectedLat = (loc['lat'] as num).toDouble();
                _selectedLng = (loc['lng'] as num).toDouble();
                _selectedLocationLabel =
                    result?['formatted_address'] as String?;
                _addressCtrl.text = suggestion.description;
              });
            }
          }
        }
      } catch (_) {}
    }

    await _saveSearchLocation(suggestion.description);
  }

  Future<void> _useGpsLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          _snackError(
            'Location permission denied. Please enable it in Settings.',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String? address;
      String? city;
      if (AppConstants.googlePlacesApiKey != 'YOUR_KEY') {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${position.latitude},${position.longitude}'
          '&key=${AppConstants.googlePlacesApiKey}',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            final results = data['results'] as List? ?? [];
            if (results.isNotEmpty) {
              final first = results.first as Map<String, dynamic>;
              address = first['formatted_address'] as String?;
              final components = first['address_components'] as List? ?? [];
              for (final c in components) {
                if (c is! Map<String, dynamic>) continue;
                final types = c['types'] as List? ?? [];
                if (types.contains('locality')) {
                  city = c['long_name'] as String?;
                  break;
                }
              }
            }
          }
        }
      }

      if (!mounted) return;
      final resolvedAddress = (address != null && address.trim().isNotEmpty)
          ? address.trim()
          : 'GPS: ${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}';
      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
        _selectedLocationLabel = (address != null && address.trim().isNotEmpty)
            ? address.trim()
            : resolvedAddress;
        _addressCtrl.text = resolvedAddress;
        _cityCtrl.text = city ?? '';
      });

      await _saveGpsLocation(
        position.latitude,
        position.longitude,
        resolvedAddress,
        city ?? '',
      );
    } catch (_) {
      if (mounted) {
        _snackError('Could not get location. Please try again.');
      }
    }
  }

  Future<void> _saveGpsLocation(
    double lat,
    double lng,
    String address,
    String city,
  ) async {
    setState(() => _isSavingLocation = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.saveDeliveryLocation(
      orderId: widget.orderId,
      address: address,
      city: city,
      locationSource: 'gps',
      latitude: lat,
      longitude: lng,
      locationLabel: address,
    );
    if (mounted) {
      setState(() {
        _isSavingLocation = false;
        _editingLocation = false;
      });
    }
    if (!mounted) return;
    result.fold(
      (f) => _snackError(f.message),
      (_) => _snackSuccess('Location saved.'),
    );
  }

  Future<void> _saveSearchLocation(String description) async {
    setState(() => _isSavingLocation = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.saveDeliveryLocation(
      orderId: widget.orderId,
      address: description,
      city: '',
      locationSource: 'search',
      latitude: _selectedLat,
      longitude: _selectedLng,
      locationLabel: _selectedLocationLabel,
    );
    if (mounted) {
      setState(() {
        _isSavingLocation = false;
        _editingLocation = false;
      });
    }
    if (!mounted) return;
    result.fold(
      (f) => _snackError(f.message),
      (_) => _snackSuccess('Location saved.'),
    );
  }

  Future<void> _saveManualLocation() async {
    final address = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    if (address.isEmpty) {
      _snackError('Please enter your delivery address.');
      return;
    }
    setState(() => _isSavingLocation = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.saveDeliveryLocation(
      orderId: widget.orderId,
      address: address,
      city: city,
      locationSource: 'manual',
    );
    if (mounted) {
      setState(() {
        _isSavingLocation = false;
        _editingLocation = false;
      });
    }
    if (!mounted) return;
    result.fold(
      (f) => _snackError(f.message),
      (_) => _snackSuccess('Location saved.'),
    );
  }

  Future<void> _confirmDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm vehicle receipt?',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'By confirming, you acknowledge that you have received your vehicle '
          'in the expected condition.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              'Yes, I received it',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.secondary, letterSpacing: 0.1),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isConfirming = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.confirmDelivery(widget.orderId);
    if (mounted) setState(() => _isConfirming = false);

    if (!mounted) return;
    result.fold((f) => _snackError(f.message), (_) {});
  }

  Future<void> _openMap(Delivery delivery) async {
    final lat = delivery.latitude;
    final lng = delivery.longitude;
    final label = Uri.encodeComponent(
      delivery.locationLabel ?? delivery.deliveryAddress ?? 'Delivery location',
    );

    Uri? nativeUri;
    Uri? webUri;

    if (lat != null && lng != null) {
      nativeUri = Uri.parse('geo:$lat,$lng?q=$label');
      webUri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    } else {
      webUri = Uri.parse('https://maps.google.com/?q=$label');
    }

    var launched = false;
    if (nativeUri != null) {
      try {
        launched = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        launched = false;
      }
    }
    if (!launched) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}

final deliveryChoiceProvider =
    StateProvider.family<bool?, String>((ref, _) => null);

class _State0NotAvailable extends StatelessWidget {
  const _State0NotAvailable({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 72,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              DeliveryConstants.state0Heading,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              DeliveryConstants.state0Body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/order/$orderId'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSolid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  DeliveryConstants.state0BackButton,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _State1Choice extends ConsumerStatefulWidget {
  const _State1Choice({
    required this.orderId,
    required this.onConfirmAgent,
    required this.onConfirmSelf,
  });

  final String orderId;
  final Future<void> Function() onConfirmAgent;
  final Future<void> Function() onConfirmSelf;

  @override
  ConsumerState<_State1Choice> createState() => _State1ChoiceState();
}

class _State1ChoiceState extends ConsumerState<_State1Choice> {
  bool _isSubmitting = false;

  Future<void> _onConfirm() async {
    final choice = ref.read(deliveryChoiceProvider(widget.orderId));
    if (choice == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      if (choice) {
        await widget.onConfirmAgent();
      } else {
        await widget.onConfirmSelf();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(deliveryChoiceProvider(widget.orderId));
    final feeAsync = ref.watch(deliveryServiceFeeProvider);
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final feeUsd = feeAsync.valueOrNull ??
        DeliveryConstants.deliveryFeeFallbackUsd;
    final feeDisplay = feeUsd > 0
        ? CurrencyFormatter.formatForDisplay(
            usdAmount: feeUsd,
            preferredCurrency: preferredCurrency,
          )
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DeliveryConstants.state1Heading,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            DeliveryConstants.state1Subtitle,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          _DeliveryOptionCard(
            orderId: widget.orderId,
            isDeliver: true,
            isSelected: choice == true,
            feeDisplay: feeDisplay,
            bullets: DeliveryConstants.optionDeliverBullets,
          ),
          const SizedBox(height: 12),
          _DeliveryOptionCard(
            orderId: widget.orderId,
            isDeliver: false,
            isSelected: choice == false,
            feeDisplay: null,
            bullets: DeliveryConstants.optionPickupBullets,
          ),
          const SizedBox(height: 16),
          if (choice == true) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.infoText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DeliveryConstants.optionDeliverTowingNote,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.infoText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
                  choice != null && !_isSubmitting ? _onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: choice != null
                    ? AppColors.secondary
                    : AppColors.surface,
                foregroundColor: choice != null
                    ? AppColors.background
                    : AppColors.textTertiary,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : Text(
                      choice == true
                          ? DeliveryConstants.confirmDeliverButton
                          : choice == false
                              ? DeliveryConstants.confirmPickupButton
                              : DeliveryConstants.confirmSelectOption,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: choice != null
                            ? AppColors.background
                            : AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionCard extends ConsumerWidget {
  const _DeliveryOptionCard({
    required this.orderId,
    required this.isDeliver,
    required this.isSelected,
    required this.feeDisplay,
    required this.bullets,
  });

  final String orderId;
  final bool isDeliver;
  final bool isSelected;
  final CurrencyDisplay? feeDisplay;
  final List<String> bullets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(deliveryChoiceProvider(orderId).notifier);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => notifier.state = isDeliver,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.infoBackground
                : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.borderSolid,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDeliver
                          ? AppColors.infoBackground
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDeliver
                          ? Icons.local_shipping_rounded
                          : Icons.directions_walk_rounded,
                      size: 20,
                      color: isDeliver
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDeliver
                              ? DeliveryConstants.optionDeliverTitle
                              : DeliveryConstants.optionPickupTitle,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isDeliver && feeDisplay != null) ...[
                          Text(
                            feeDisplay!.primary,
                            style: AppTextStyles.amountMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          if (feeDisplay!.hasSecondary)
                            Text(
                              feeDisplay!.secondary!,
                              style: AppTextStyles.amountSmall,
                            ),
                          Text(
                            DeliveryConstants.optionDeliverFeeLabel,
                            style: AppTextStyles.caption,
                          ),
                        ] else if (!isDeliver)
                          Text(
                            DeliveryConstants.optionPickupFeeLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.borderSolid,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.background,
                          )
                        : null,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bullets
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: isDeliver
                                                ? AppColors.secondary
                                                : AppColors.textTertiary,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            b,
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _State2AwaitingPayment extends ConsumerWidget {
  const _State2AwaitingPayment({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync =
        ref.watch(deliveryPendingPaymentsProvider(orderId));
    final preferredCurrency = ref.watch(preferredCurrencyProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderSolid,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.infoBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_top_rounded,
                          size: 20,
                          color: AppColors.infoText,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DeliveryConstants.state2Heading,
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            paymentsAsync.when(
                              loading: () => Text(
                                'Loading…',
                                style: AppTextStyles.bodySmall,
                              ),
                              error: (_, __) => Text(
                                DeliveryConstants.state2NoPaymentsBody,
                                style: AppTextStyles.bodySmall,
                              ),
                              data: (payments) => Text(
                                payments.isEmpty
                                    ? DeliveryConstants.state2NoPaymentsBody
                                    : DeliveryConstants.state2PaymentsSubtitle,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                paymentsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (payments) {
                    if (payments.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DeliveryConstants.state2PaymentsTitle,
                          style: AppTextStyles.sectionLabel,
                        ),
                        const SizedBox(height: 10),
                        ...payments.map(
                          (p) => _PaymentRequestMiniCard(
                            payment: p,
                            preferredCurrency: preferredCurrency,
                            orderId: orderId,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentRequestMiniCard extends StatelessWidget {
  const _PaymentRequestMiniCard({
    required this.payment,
    required this.preferredCurrency,
    required this.orderId,
  });

  final PaymentRequestModel payment;
  final CurrencyModel preferredCurrency;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final label = payment.type == PaymentRequestType.towingFee
        ? DeliveryConstants.state2TowingFeeLabel
        : DeliveryConstants.state2DeliveryFeeLabel;
    final formatted = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: preferredCurrency,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSolid,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  formatted.primary,
                  style: AppTextStyles.amountMedium.copyWith(fontSize: 18),
                ),
                if (formatted.hasSecondary)
                  Text(
                    formatted.secondary!,
                    style: AppTextStyles.amountSmall,
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push(
              '/order/$orderId/payment-request/${payment.id}',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.background,
              elevation: 0,
              minimumSize: const Size(72, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Pay',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _State5SelfPickup extends ConsumerStatefulWidget {
  const _State5SelfPickup({
    required this.orderId,
    required this.delivery,
  });

  final String orderId;
  final Delivery delivery;

  @override
  ConsumerState<_State5SelfPickup> createState() =>
      _State5SelfPickupState();
}

class _State5SelfPickupState extends ConsumerState<_State5SelfPickup> {
  bool _isConfirming = false;

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          DeliveryConstants.state5ConfirmDialogTitle,
          style: AppTextStyles.titleSmall,
        ),
        content: Text(
          DeliveryConstants.state5ConfirmDialogBody,
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              DeliveryConstants.state5ConfirmDialogCancel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              DeliveryConstants.state5ConfirmDialogYes,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isConfirming = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.confirmSelfCollection(widget.orderId);
    if (mounted) {
      setState(() => _isConfirming = false);
    }
    if (!mounted) return;
    result.fold(
      (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              f.message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.background,
              ),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {},
    );
  }

  Future<void> _openDirections() async {
    final lat = widget.delivery.collectionLatitude;
    final lng = widget.delivery.collectionLongitude;
    if (lat == null || lng == null) return;

    Uri uri;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&origin=${pos.latitude},${pos.longitude}'
          '&destination=$lat,$lng',
        );
      } else {
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
        );
      }
    } catch (_) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    final hasDetails = delivery.hasCollectionDetails;
    final agentName = ref
            .watch(agentFirstNameProvider(widget.orderId))
            .valueOrNull ??
        'Your agent';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DeliveryConstants.state5Heading,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 6),
                if (!hasDetails) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderSolid,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DeliveryConstants.state5NoDetailsBody,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderSolid,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.06),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 18,
                                  color: AppColors.background,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COLLECTION POINT',
                                      style: AppTextStyles.sectionLabel
                                          .copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Set by $agentName',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                delivery.collectionAddress!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (delivery.collectionNotes != null &&
                                  delivery.collectionNotes!.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColors.secondary,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AGENT NOTE',
                                        style: AppTextStyles.badgeText.copyWith(
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        delivery.collectionNotes!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (delivery.collectionLatitude != null &&
                                  delivery.collectionLongitude != null)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _openDirections,
                                    icon: const Icon(
                                      Icons.directions_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      DeliveryConstants.state5DirectionsButton,
                                      style: AppTextStyles.buttonMedium.copyWith(
                                        color: AppColors.background,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: AppColors.background,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(
                        '/order/${widget.orderId}?tab=chat',
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        DeliveryConstants.state5ChatButton,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasDetails)
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.borderSolid,
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              14 + MediaQuery.paddingOf(context).bottom,
            ),
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.background,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : Text(
                      DeliveryConstants.state5ConfirmButton,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.background,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class _LocationInputState extends StatelessWidget {
  const _LocationInputState({
    required this.addressCtrl,
    required this.cityCtrl,
    required this.searchCtrl,
    required this.isSaving,
    required this.isSearching,
    required this.suggestions,
    required this.selectedLat,
    required this.selectedLng,
    required this.selectedLabel,
    required this.onSearchChanged,
    required this.onSuggestionSelected,
    required this.onUseGps,
    required this.onSaveManual,
  });

  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController searchCtrl;
  final bool isSaving;
  final bool isSearching;
  final List<_PlaceSuggestion> suggestions;
  final double? selectedLat;
  final double? selectedLng;
  final String? selectedLabel;
  final void Function(String) onSearchChanged;
  final Future<void> Function(_PlaceSuggestion) onSuggestionSelected;
  final VoidCallback? onUseGps;
  final VoidCallback? onSaveManual;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Where should we deliver your vehicle?',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your agent will use this address to arrange delivery.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _OptionButton(
            icon: Icons.my_location_rounded,
            label: 'Use my current location',
            onTap: onUseGps,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'SEARCH ADDRESS',
            style: AppTextStyles.labelSmall
                .copyWith(letterSpacing: 0.5, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search for a place...',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textTertiary, height: 1.2),
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSolid),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSolid),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSolid),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.borderSolid),
                itemBuilder: (context, i) {
                  final s = suggestions[i];
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      minVerticalPadding: 14,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        s.description,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      onTap: isSaving ? null : () => onSuggestionSelected(s),
                    ),
                  );
                },
              ),
            ),
          ],
          if (selectedLat != null &&
              selectedLng != null &&
              (selectedLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Selected: ${selectedLabel ?? ''}',
              style: AppTextStyles.cardLabel,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.borderSolid)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR ENTER MANUALLY',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textTertiary, letterSpacing: 0.3),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.borderSolid)),
            ],
          ),
          const SizedBox(height: 16),
          _StyledTextField(
            controller: addressCtrl,
            label: 'Street address / landmark',
            hint: 'e.g. House 12, Cantonments Road',
          ),
          const SizedBox(height: 12),
          _StyledTextField(
            controller: cityCtrl,
            label: 'City / area',
            hint: 'e.g. Accra',
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onSaveManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.borderSolid,
                disabledForegroundColor: AppColors.textTertiary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save delivery location →',
                      style: AppTextStyles.buttonLarge,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSetState extends StatelessWidget {
  const _LocationSetState({
    required this.delivery,
    required this.isConfirming,
    required this.onEdit,
    required this.onConfirm,
    required this.onViewMap,
  });

  final Delivery delivery;
  final bool isConfirming;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onViewMap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSolid),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delivery address',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        color: AppColors.primary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  delivery.locationLabel ?? delivery.deliveryAddress ?? '',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary, height: 1.4),
                ),
                if (delivery.deliveryCity != null &&
                    delivery.deliveryCity!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    delivery.deliveryCity!,
                    style: AppTextStyles.cardLabel,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewMap,
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: Text(
                          'View on map',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          'Edit location',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.borderSolid),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.infoText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Only confirm receipt once your vehicle has been '
                    'physically delivered to you.',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.infoText, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          if (delivery.status != null &&
              delivery.status != 'pending_payment') ...[
            const SizedBox(height: 20),
            _AgentStatusCard(status: delivery.status!),
            const SizedBox(height: 20),
          ] else
            const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isConfirming ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.borderSolid,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm I received my vehicle ✓',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: Colors.white, height: 1.0),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentStatusCard extends StatelessWidget {
  const _AgentStatusCard({required this.status});

  final String status;

  static const _steps = [
    'ready_for_delivery',
    'en_route',
    'agent_marked_delivered',
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'pending_payment' || status == 'delivery_confirmed') {
      return const SizedBox.shrink();
    }

    final currentStep = _steps.indexOf(status);
    if (currentStep == -1) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY UPDATE',
                        style: AppTextStyles.sectionLabel
                            .copyWith(color: AppColors.secondary),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _headerTitle(currentStep),
                        style: AppTextStyles.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProgressStep(
                  icon: Icons.inventory_2_outlined,
                  label: 'Ready for delivery',
                  sublabel: 'Vehicle prepared and ready.',
                  isComplete: currentStep >= 0,
                  isActive: currentStep == 0,
                  showLine: true,
                ),
                _ProgressStep(
                  icon: Icons.route_rounded,
                  label: 'En route',
                  sublabel: 'Agent is on the way to you.',
                  isComplete: currentStep >= 1,
                  isActive: currentStep == 1,
                  showLine: true,
                ),
                _ProgressStep(
                  icon: Icons.where_to_vote_rounded,
                  label: 'Delivered',
                  sublabel: currentStep >= 2
                      ? 'Confirm receipt below.'
                      : 'Pending delivery.',
                  isComplete: currentStep >= 2,
                  isActive: currentStep == 2,
                  showLine: false,
                ),
              ],
            ),
          ),
          if (currentStep == 2)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successMutedBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.successMutedBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your agent has marked the vehicle as '
                      'delivered. Tap the button below to '
                      'confirm receipt.',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.successMutedForeground, height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.infoText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentStep == 0
                          ? 'Your agent is preparing the vehicle. '
                                'You will be notified when they are '
                                'on the way.'
                          : 'Your agent is on the way. Please be '
                                'available at your delivery location.',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.infoText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _headerTitle(int step) {
    switch (step) {
      case 0:
        return 'Vehicle ready for delivery';
      case 1:
        return 'Your vehicle is on the way';
      case 2:
        return 'Vehicle delivered';
      default:
        return 'Delivery in progress';
    }
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isComplete,
    required this.isActive,
    required this.showLine,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool isComplete;
  final bool isActive;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isComplete
        ? AppColors.success
        : isActive
        ? AppColors.secondary
        : AppColors.borderSolid;

    final Color lineColor = isComplete
        ? AppColors.success
        : AppColors.borderSolid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isComplete || isActive ? dotColor : AppColors.surface,
                  shape: BoxShape.circle,
                  border: isComplete || isActive
                      ? null
                      : Border.all(color: AppColors.borderSolid),
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : icon,
                  size: 16,
                  color: isComplete || isActive
                      ? Colors.white
                      : AppColors.textTertiary,
                ),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 28,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (isActive || isComplete
                          ? AppTextStyles.labelLarge
                          : AppTextStyles.bodySmall)
                      .copyWith(
                    fontSize: 13,
                    color: isActive || isComplete
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: isActive || isComplete
                        ? FontWeight.w600
                        : FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: AppTextStyles.caption
                      .copyWith(
                    color: isActive || isComplete
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                    height: 1.3,
                  ),
                ),
                if (showLine) const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmedState extends StatelessWidget {
  const _ConfirmedState({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          Text(
            'Vehicle received!',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for confirming receipt. Please take a moment to share '
            'your experience — your feedback helps us improve.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pushNamed(
                RouteConstants.orderReview,
                pathParameters: {'orderId': orderId},
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Leave feedback →',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
        label: Text(
          label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: color, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall
              .copyWith(letterSpacing: 0.5, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary, height: 1.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderSolid),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderSolid),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceSuggestion {
  const _PlaceSuggestion({required this.placeId, required this.description});

  final String placeId;
  final String description;
}
