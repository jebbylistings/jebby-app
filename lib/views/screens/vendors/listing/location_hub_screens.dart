import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/listing_form_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/listing_kit.dart';
import 'package:jebby/views/widgets/address_autocomplete_field.dart';
import 'package:jebby/views/widgets/address_map_picker_screen.dart';

class ListingItemLocationScreen extends StatefulWidget {
  const ListingItemLocationScreen({super.key});

  @override
  State<ListingItemLocationScreen> createState() =>
      _ListingItemLocationScreenState();
}

class _ListingItemLocationScreenState extends State<ListingItemLocationScreen> {
  late final TextEditingController _search;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _zip;
  final _manualFieldsKey = GlobalKey();
  ParsedUsAddress? _resolved;
  bool _showManualForm = false;
  final _places = GooglePlacesAddressService();

  static const _usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
  ];

  @override
  void initState() {
    super.initState();
    final c = Get.find<ListingFormController>();
    final loc = c.draft.location;
    final initialSearch = loc.line1.isNotEmpty
        ? loc.line1
        : (loc.isComplete ? loc.toParsedAddress().displayLine : '');
    _search = TextEditingController(text: initialSearch);
    _line1 = TextEditingController(text: loc.line1);
    _line2 = TextEditingController(text: loc.line2);
    _city = TextEditingController(text: loc.city);
    _state = TextEditingController(text: loc.state);
    _zip = TextEditingController(text: loc.postalCode);
    _resolved = loc.isComplete ? loc.toParsedAddress() : null;
  }

  @override
  void dispose() {
    _search.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
    super.dispose();
  }

  LatLng get _mapTarget {
    final lat = _resolved?.latitude ?? Get.find<ListingFormController>().draft.location.latitude;
    final lng = _resolved?.longitude ?? Get.find<ListingFormController>().draft.location.longitude;
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return const LatLng(27.9506, -82.4572);
  }

  String get _mapCityLabel {
    final city = _city.text.trim();
    if (city.isNotEmpty) return city.toUpperCase();
    return 'YOUR AREA';
  }

  Future<void> _apply(ParsedUsAddress address) async {
    setState(() {
      _resolved = address;
      _search.text = address.line1.isNotEmpty ? address.line1 : address.displayLine;
      _line1.text = address.line1;
      _line2.text = address.line2;
      _city.text = address.city;
      _state.text = address.state;
      _zip.text = address.postalCode;
    });
  }

  void _openManualEntry() {
    setState(() => _showManualForm = true);
  }

  void _backToAddressSearch() {
    setState(() => _showManualForm = false);
  }

  void _clearAddressSelection() {
    if (_resolved == null) return;
    setState(() => _resolved = null);
  }

  Future<void> _pickState() async {
    final picked = await showListingChoiceSheet(
      context,
      title: 'Choose a state',
      options: _usStates,
      selected: _state.text.trim().isEmpty ? null : _state.text.trim().toUpperCase(),
    );
    if (picked != null) {
      setState(() => _state.text = picked);
    }
  }

  ParsedUsAddress _currentAddressForPin() {
    final c = Get.find<ListingFormController>();
    final loc = c.draft.location;
    return ParsedUsAddress.fromStored(
      line1: _line1.text.trim().isNotEmpty ? _line1.text.trim() : loc.line1,
      line2: _line2.text.trim().isNotEmpty ? _line2.text.trim() : loc.line2,
      city: _city.text.trim().isNotEmpty ? _city.text.trim() : loc.city,
      state: _state.text.trim().isNotEmpty ? _state.text.trim() : loc.state,
      postalCode: _zip.text.trim().isNotEmpty ? _zip.text.trim() : loc.postalCode,
      latitude: _resolved?.latitude ?? loc.latitude,
      longitude: _resolved?.longitude ?? loc.longitude,
    );
  }

  Future<void> _openMapPicker() async {
    final address = _currentAddressForPin();
    final picked = await showAddressMapPicker(
      context,
      style: AddressMapPickerStyle.adjustPin,
      preserveAddressFields: address,
      initialLatitude: address.latitude,
      initialLongitude: address.longitude,
    );
    if (picked != null) await _apply(picked);
  }

  Future<void> _save() async {
    final c = Get.find<ListingFormController>();
    var lat = _resolved?.latitude ?? c.draft.location.latitude;
    var lng = _resolved?.longitude ?? c.draft.location.longitude;

    if (lat == null || lng == null) {
      final query = [
        _line1.text.trim(),
        _city.text.trim(),
        _state.text.trim(),
        _zip.text.trim(),
      ].where((p) => p.isNotEmpty).join(', ');
      if (query.isNotEmpty) {
        final geocoded = await _places.geocodeAddress(query);
        if (geocoded != null) {
          lat = geocoded.latitude;
          lng = geocoded.longitude;
          _resolved = geocoded;
        }
      }
    }

    c.draft.location = ListingLocation(
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      postalCode: _zip.text.trim(),
      latitude: lat,
      longitude: lng,
    );
    c.markDirty();
    await c.persistDraft();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Item location',
      subtitle: 'Review or update your pickup address.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Where will renters pick it up?',
            style: onboardingNunito(size: 22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve filled in your saved address. You can change it for this item.',
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
          const SizedBox(height: 20),
          if (!_showManualForm)
            _ListingAddressSearchSection(
              searchController: _search,
              resolvedAddress: _resolved,
              onAddressSelected: _apply,
              onSelectionCleared: _clearAddressSelection,
              onEnterManually: _openManualEntry,
            ),
          if (_showManualForm) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _backToAddressSearch,
                icon: Icon(Icons.search, color: AppColors.jebbyBlue, size: 20),
                label: Text(
                  'Search for an address',
                  style: onboardingNunito(
                    size: 16,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyBlue,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.jebbySoftBlue,
                  foregroundColor: AppColors.jebbyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            KeyedSubtree(
              key: _manualFieldsKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const OnboardingFieldLabel('Street address', muted: true),
                  OnboardingTextField(
                    controller: _line1,
                    hint: '123 Example St',
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const OnboardingFieldLabel(
                    'Apartment or unit (optional)',
                    muted: true,
                  ),
                  OnboardingTextField(
                    controller: _line2,
                    hint: 'Add unit',
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const OnboardingFieldLabel('City', muted: true),
                  OnboardingTextField(
                    controller: _city,
                    hint: 'Tampa',
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const OnboardingFieldLabel('State', muted: true),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: _pickState,
                                borderRadius: BorderRadius.circular(12),
                                child: IgnorePointer(
                                  child: OnboardingTextField(
                                    controller: _state,
                                    hint: 'FL',
                                    fillColor: Colors.white,
                                    readOnly: true,
                                    suffix: Icon(
                                      Icons.expand_more,
                                      color: AppColors.jebbyTextMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const OnboardingFieldLabel('ZIP code', muted: true),
                            OnboardingTextField(
                              controller: _zip,
                              hint: '33602',
                              fillColor: Colors.white,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LocationMapPreview(
              target: _mapTarget,
              cityLabel: _mapCityLabel,
              onTap: _openMapPicker,
            ),
            const SizedBox(height: 16),
            _WhatRentersSeeCard(),
            const SizedBox(height: 12),
            Text(
              'Any changes here apply only to this listing.',
              textAlign: TextAlign.center,
              style: onboardingNunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
          ],
        ],
      ),
      bottomBar: OnboardingPrimaryButton(
        label: 'Save location',
        onPressed: _save,
      ),
    );
  }
}

class _ListingAddressSearchSection extends StatefulWidget {
  final TextEditingController searchController;
  final ParsedUsAddress? resolvedAddress;
  final Future<void> Function(ParsedUsAddress address) onAddressSelected;
  final VoidCallback onSelectionCleared;
  final VoidCallback onEnterManually;

  const _ListingAddressSearchSection({
    required this.searchController,
    required this.resolvedAddress,
    required this.onAddressSelected,
    required this.onSelectionCleared,
    required this.onEnterManually,
  });

  @override
  State<_ListingAddressSearchSection> createState() =>
      _ListingAddressSearchSectionState();
}

class _ListingAddressSearchSectionState
    extends State<_ListingAddressSearchSection> {
  static const _locationTimeout = Duration(seconds: 10);

  final _places = GooglePlacesAddressService();
  List<Map<String, dynamic>> _predictions = [];
  bool _loadingDetails = false;
  bool _locating = false;
  bool _suppressQuery = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchTextChanged);
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onQueryChanged(String value) async {
    if (_suppressQuery) return;
    if (widget.resolvedAddress != null) {
      widget.onSelectionCleared();
    }
    if (value.trim().length < 3) {
      if (mounted) setState(() => _predictions = []);
      return;
    }

    try {
      final results = await _places.fetchPredictions(value);
      if (mounted) setState(() => _predictions = results.take(5).toList());
    } catch (_) {
      if (mounted) setState(() => _predictions = []);
    }
  }

  (String main, String sub) _predictionLines(Map<String, dynamic> prediction) {
    final structured = prediction['structured_formatting'];
    if (structured is Map) {
      final main = structured['main_text']?.toString() ?? '';
      final sub = structured['secondary_text']?.toString() ?? '';
      if (main.isNotEmpty) return (main, sub);
    }
    final desc = prediction['description']?.toString() ?? '';
    final parts = desc.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts.first, parts.sublist(1).join(', '));
    }
    return (desc, '');
  }

  Future<void> _finishAddress(ParsedUsAddress parsed) async {
    if (parsed.isComplete) {
      await widget.onAddressSelected(parsed);
      return;
    }
    final completed = await showMissingAddressDialog(context, initial: parsed);
    if (!mounted || completed == null) return;
    await widget.onAddressSelected(completed);
  }

  Future<void> _selectPrediction(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id']?.toString() ?? '';
    if (placeId.isEmpty) return;

    final (main, _) = _predictionLines(prediction);
    setState(() {
      _loadingDetails = true;
      _predictions = [];
    });
    _suppressQuery = true;
    widget.searchController.text = main.isNotEmpty
        ? main
        : (prediction['description']?.toString() ?? '');
    _suppressQuery = false;

    try {
      final parsed = await _places.resolvePlace(placeId);
      if (!mounted || parsed == null) return;
      await _finishAddress(parsed);
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  Future<Position?> _readDevicePosition() async {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    ).timeout(_locationTimeout);
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        showAppErrorSnackbar('Turn on location services to use your position.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showAppErrorSnackbar(
          'Location permission is required to use your position.',
        );
        return;
      }

      final position = await _readDevicePosition();
      if (position == null) {
        showAppErrorSnackbar('Could not get your location. Try again or enter an address.');
        return;
      }

      setState(() {
        _loadingDetails = true;
        _predictions = [];
      });

      final parsed = await _places.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      if (parsed == null || !parsed.hasLine1) {
        showAppErrorSnackbar('Could not resolve your address. Enter it manually.');
        return;
      }

      _suppressQuery = true;
      widget.searchController.text =
          parsed.line1.isNotEmpty ? parsed.line1 : parsed.displayLine;
      _suppressQuery = false;

      await _finishAddress(parsed);
    } on TimeoutException {
      showAppErrorSnackbar(
        'Location is taking too long. Try again or enter an address.',
      );
    } catch (_) {
      showAppErrorSnackbar('Could not get your location. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
          _loadingDetails = false;
        });
      }
    }
  }

  void _clearSearch() {
    _suppressQuery = true;
    widget.searchController.clear();
    _suppressQuery = false;
    if (widget.resolvedAddress != null) {
      widget.onSelectionCleared();
    }
    setState(() => _predictions = []);
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.resolvedAddress;
    final hasSelection =
        resolved != null && resolved.displaySummary.trim().isNotEmpty;
    final showClear = widget.searchController.text.isNotEmpty &&
        !_loadingDetails &&
        !hasSelection;
    final showSelectedCheck =
        hasSelection && _predictions.isEmpty && !_loadingDetails;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.searchController,
            onChanged: _onQueryChanged,
            style: onboardingNunito(size: 15, weight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search for an address',
              hintStyle: onboardingNunito(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.jebbyBlue, size: 22),
              suffixIcon: _loadingDetails
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.jebbyBlue,
                        ),
                      ),
                    )
                  : showSelectedCheck
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        )
                      : showClear
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: AppColors.jebbyBlue,
                                size: 20,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
            ),
          ),
        ),
        if (showSelectedCheck) ...[
          const SizedBox(height: 12),
          _ListingSelectedAddressChip(address: resolved),
        ],
        if (_predictions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Matching addresses',
            style: onboardingNunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_predictions.length, (index) {
            final prediction = _predictions[index];
            final (main, sub) = _predictionLines(prediction);
            return Padding(
              padding: EdgeInsets.only(bottom: index < _predictions.length - 1 ? 8 : 0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _selectPrediction(prediction),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined, color: AppColors.jebbyBlue, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                main,
                                style: onboardingNunito(
                                  size: 15,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              if (sub.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  sub,
                                  style: onboardingNunito(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: AppColors.jebbyTextMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.jebbyTextMuted.withValues(alpha: 0.6),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _locating ? null : _useCurrentLocation,
            icon: _locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.jebbyBlue,
                    ),
                  )
                : Icon(Icons.navigation_outlined, color: AppColors.jebbyBlue, size: 20),
            label: Text(
              'Use current location',
              style: onboardingNunito(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.jebbyBlue,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.jebbySoftBlue,
              foregroundColor: AppColors.jebbyBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OnboardingPrimaryButton(
          label: 'Enter address manually',
          onPressed: widget.onEnterManually,
        ),
        const SizedBox(height: 16),
        const _AddressStaysPrivateCard(),
      ],
    );
  }
}

class _ListingSelectedAddressChip extends StatelessWidget {
  final ParsedUsAddress address;

  const _ListingSelectedAddressChip({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8D4B8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 22,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location selected',
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w800,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.displaySummary,
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMapPreview extends StatelessWidget {
  final LatLng target;
  final String cityLabel;
  final VoidCallback onTap;

  const _LocationMapPreview({
    required this.target,
    required this.cityLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 168,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  key: ValueKey(
                    '${target.latitude.toStringAsFixed(5)}_'
                    '${target.longitude.toStringAsFixed(5)}',
                  ),
                  initialCameraPosition: CameraPosition(
                    target: target,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: target,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  liteModeEnabled: true,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Text(
                    cityLabel,
                    style: onboardingNunito(
                      size: 22,
                      weight: FontWeight.w900,
                      color: AppColors.jebbyTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingLocationInfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _ListingLocationInfoCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.jebbySoftBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.visibility_outlined,
              color: AppColors.jebbyBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressStaysPrivateCard extends StatelessWidget {
  const _AddressStaysPrivateCard();

  @override
  Widget build(BuildContext context) {
    return const _ListingLocationInfoCard(
      title: 'Your address stays private',
      body:
          'Renters see your city and approximate area. Your exact address is shared only for confirmed pickups.',
    );
  }
}

class _WhatRentersSeeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _ListingLocationInfoCard(
      title: 'What renters see',
      body:
          'Your listing shows your city and approximate area. Only renters with a confirmed pickup booking can see your exact address.',
    );
  }
}
