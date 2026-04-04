import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/delivery.dart';
import '../providers/delivery_providers.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
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
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
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
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
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
    final deliveryAsync = ref.watch(deliveryProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        title: Text(
          'Delivery',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: deliveryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: ResponsiveLayout.contentPadding(context),
            child: Text(
              'Could not load delivery details.',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (delivery) {
          if (delivery?.isConfirmed == true) {
            return _wrapScrollable(
              context,
              _ConfirmedState(orderId: widget.orderId),
            );
          }

          if (delivery?.hasLocation == true && !_editingLocation) {
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
          }

          return _wrapScrollable(
            context,
            _LocationInputState(
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
              onSaveManual: _isSavingLocation ? null : _saveManualLocation,
            ),
          );
        },
      ),
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
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'By confirming, you acknowledge that you have received your vehicle '
          'in the expected condition.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
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
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              'Yes, I received it',
              style: GoogleFonts.dmSans(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
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
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your agent will use this address to arrange delivery.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
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
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            style: GoogleFonts.dmSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search for a place...',
              hintStyle: GoogleFonts.dmSans(color: AppColors.textTertiary),
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
                        style: GoogleFonts.dmSans(fontSize: 13),
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
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
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
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  delivery.locationLabel ?? delivery.deliveryAddress ?? '',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (delivery.deliveryCity != null &&
                    delivery.deliveryCity!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    delivery.deliveryCity!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.infoText,
                      height: 1.35,
                    ),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _headerTitle(currentStep),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.successMutedForeground,
                        height: 1.4,
                      ),
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
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.infoText,
                        height: 1.4,
                      ),
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
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: isActive || isComplete
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isActive || isComplete
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
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
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for confirming receipt. Please take a moment to share '
            'your experience — your feedback helps us improve.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
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
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
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
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.dmSans(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
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
