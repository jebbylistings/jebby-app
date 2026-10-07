import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';

enum AddressMapPickerStyle {
  /// Pick a location on the map and resolve the full address from the pin.
  pickOnMap,

  /// Move pin only; street address fields stay as provided (listing pickup spot).
  adjustPin,
}

/// Full-screen map to drop a pin (move map under fixed marker) and confirm address.
Future<ParsedUsAddress?> showAddressMapPicker(
  BuildContext context, {
  double? initialLatitude,
  double? initialLongitude,
  AddressMapPickerStyle style = AddressMapPickerStyle.pickOnMap,
  ParsedUsAddress? preserveAddressFields,
}) {
  return Navigator.of(context).push<ParsedUsAddress>(
    MaterialPageRoute(
      builder: (context) => AddressMapPickerScreen(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        style: style,
        preserveAddressFields: preserveAddressFields,
      ),
    ),
  );
}

class AddressMapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final AddressMapPickerStyle style;
  final ParsedUsAddress? preserveAddressFields;

  const AddressMapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.style = AddressMapPickerStyle.pickOnMap,
    this.preserveAddressFields,
  });

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  static const LatLng _usCenter = LatLng(39.8283, -98.5795);
  static const double _streetZoom = 16;
  static const Duration _locationTimeout = Duration(seconds: 12);

  final GooglePlacesAddressService _placesService = GooglePlacesAddressService();
  GoogleMapController? _mapController;

  late LatLng _pinPosition;
  late double _initialZoom;
  bool _resolving = false;
  bool _locating = false;
  bool _previewLoading = false;
  String _previewLine = '';
  ParsedUsAddress? _previewAddress;
  Timer? _geocodeDebounce;
  int _geocodeGeneration = 0;

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  bool get _isAdjustPin => widget.style == AddressMapPickerStyle.adjustPin;

  bool get _hasSavedCoordinates =>
      widget.initialLatitude != null && widget.initialLongitude != null;

  ParsedUsAddress? get _fixedAddress => widget.preserveAddressFields;

  String get _fixedLine1 {
    final line = _fixedAddress?.line1.trim() ?? '';
    if (line.isNotEmpty) return line;
    return 'Street address';
  }

  String get _fixedCityLine {
    final city = _fixedAddress?.city.trim() ?? '';
    final state = _fixedAddress?.state.trim().toUpperCase() ?? '';
    final zip = _fixedAddress?.postalCode.trim() ?? '';
    return [
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (zip.isNotEmpty) zip,
    ].join(', ').replaceAll(RegExp(r',\s*,+'), ', ').trim();
  }

  String _cityStateZipLine(ParsedUsAddress address) {
    final city = address.city.trim();
    final state = address.state.trim().toUpperCase();
    final zip = address.postalCode.trim();
    return [
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (zip.isNotEmpty) zip,
    ].join(', ');
  }

  String get _pinCardLine1 {
    if (_previewLoading && _previewAddress == null) {
      return 'Finding location…';
    }
    final preview = _previewAddress;
    if (preview != null) {
      final line = preview.line1.trim();
      if (line.isNotEmpty) return line;
    }
    return _fixedLine1;
  }

  String get _pinCardCityLine {
    final preview = _previewAddress;
    if (preview != null) {
      final tail = _cityStateZipLine(preview);
      if (tail.isNotEmpty) return tail;
    }
    return _fixedCityLine;
  }

  String get _mapCityLabel {
    final previewCity = _previewAddress?.city.trim() ?? '';
    if (previewCity.isNotEmpty) return previewCity.toUpperCase();
    final city = _fixedAddress?.city.trim() ?? '';
    if (city.isNotEmpty) return city.toUpperCase();
    return '';
  }

  @override
  void initState() {
    super.initState();
    if (_hasSavedCoordinates) {
      _pinPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _initialZoom = _streetZoom;
    } else {
      _pinPosition = _usCenter;
      _initialZoom = _streetZoom;
      if (_isAdjustPin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerOnPreservedAddress();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerOnLastKnownSilently();
        });
      }
    }
    if (_isAdjustPin && _fixedAddress != null) {
      _previewAddress = _fixedAddress;
      _previewLine = _fixedAddress!.displayLine;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schedulePreviewGeocode(immediate: true);
    });
  }

  Future<void> _centerOnPreservedAddress() async {
    if (_hasSavedCoordinates) return;
    final fixed = _fixedAddress;
    if (fixed == null) return;

    final query = fixed.displaySummary.trim();
    if (query.isEmpty) return;

    try {
      final geocoded = await _placesService.geocodeAddress(query);
      if (!mounted || geocoded?.latitude == null || geocoded?.longitude == null) {
        return;
      }
      await _animateTo(
        LatLng(geocoded!.latitude!, geocoded.longitude!),
        zoom: _streetZoom,
      );
    } catch (_) {
      // User can still pan the map.
    }
  }

  CameraPosition get _initialCamera => CameraPosition(
        target: _pinPosition,
        zoom: _initialZoom,
      );

  Future<void> _centerOnLastKnownSilently() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null || !mounted) return;

      await _animateTo(
        LatLng(lastKnown.latitude, lastKnown.longitude),
        zoom: _streetZoom,
      );
      _schedulePreviewGeocode(immediate: true);
    } catch (_) {
      // Keep default center; user can pan or tap my location.
    }
  }

  Future<void> _animateTo(LatLng target, {double zoom = _streetZoom}) async {
    if (!mounted) return;
    setState(() => _pinPosition = target);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
    _schedulePreviewGeocode(immediate: true);
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

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          showAppErrorSnackbar('Turn on location services to use your position.');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          showAppErrorSnackbar('Location permission is required to use your position.');
        }
        return;
      }

      final position = await _readDevicePosition();
      if (position == null) {
        if (mounted) {
          showAppErrorSnackbar('Could not get your location. Move the map to set a pin.');
        }
        return;
      }

      await _animateTo(LatLng(position.latitude, position.longitude));
    } on TimeoutException {
      if (mounted) {
        showAppErrorSnackbar(
          'Location is taking too long. Move the map or try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        showAppErrorSnackbar('Could not get your location. Move the map to set a pin.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _pinPosition = position.target;
    if (_isAdjustPin) {
      _schedulePreviewGeocode();
    }
  }

  void _onCameraIdle() {
    _schedulePreviewGeocode(immediate: _isAdjustPin);
  }

  void _schedulePreviewGeocode({bool immediate = false}) {
    _geocodeDebounce?.cancel();
    if (immediate) {
      _updatePreviewForPin();
      return;
    }
    final delay = _isAdjustPin
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 350);
    _geocodeDebounce = Timer(delay, _updatePreviewForPin);
  }

  Future<void> _updatePreviewForPin() async {
    final generation = ++_geocodeGeneration;
    if (mounted) {
      setState(() => _previewLoading = true);
    }

    try {
      final parsed = await _placesService.reverseGeocode(
        _pinPosition.latitude,
        _pinPosition.longitude,
      );
      if (!mounted || generation != _geocodeGeneration) return;

      setState(() {
        _previewLoading = false;
        _previewAddress = parsed;
        if (parsed != null && parsed.displayLine.trim().isNotEmpty) {
          _previewLine = parsed.displayLine;
        } else {
          _previewLine = 'No address found here — try a nearby spot';
        }
      });
    } catch (_) {
      if (!mounted || generation != _geocodeGeneration) return;
      setState(() {
        _previewLoading = false;
        _previewAddress = null;
        _previewLine = 'Could not read this location';
      });
    }
  }

  bool _previewMatchesPin() {
    final preview = _previewAddress;
    if (preview == null || !preview.hasCoordinates) return false;
    const epsilon = 0.00015;
    return (preview.latitude! - _pinPosition.latitude).abs() < epsilon &&
        (preview.longitude! - _pinPosition.longitude).abs() < epsilon;
  }

  Future<void> _confirmPin() async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      if (_isAdjustPin) {
        final base = _fixedAddress;
        if (base == null) {
          showAppErrorSnackbar('Enter a street address before adjusting the pin.');
          return;
        }

        ParsedUsAddress? atPin;
        if (_previewMatchesPin()) {
          atPin = _previewAddress;
        } else {
          atPin = await _placesService.reverseGeocode(
            _pinPosition.latitude,
            _pinPosition.longitude,
          );
        }
        if (!mounted) return;
        if (atPin == null) {
          showAppErrorSnackbar(
            'Could not read an address for this spot. Try another location.',
          );
          return;
        }

        final merged = ParsedUsAddress(
          line1: atPin.line1.isNotEmpty ? atPin.line1 : base.line1,
          line2: base.line2,
          city: atPin.city.isNotEmpty ? atPin.city : base.city,
          state: atPin.hasState ? atPin.state : base.state,
          postalCode: atPin.hasPostalCode ? atPin.postalCode : base.postalCode,
          formattedAddress: atPin.formattedAddress.isNotEmpty
              ? atPin.formattedAddress
              : base.formattedAddress,
          latitude: _pinPosition.latitude,
          longitude: _pinPosition.longitude,
        );

        if (!merged.hasLine1) {
          showAppErrorSnackbar(
            'Could not read an address for this spot. Try another location.',
          );
          return;
        }

        Navigator.pop(context, merged);
        return;
      }

      ParsedUsAddress? parsed;
      if (_previewMatchesPin()) {
        parsed = _previewAddress;
      } else {
        parsed = await _placesService.reverseGeocode(
          _pinPosition.latitude,
          _pinPosition.longitude,
        );
      }
      if (!mounted) return;
      if (parsed == null) {
        showAppErrorSnackbar('Could not read an address for this spot. Try another location.');
        return;
      }

      Navigator.pop(context, parsed);
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  TextStyle _nunito({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.jebbyTextPrimary,
      height: height,
    );
  }

  Widget _headerIconButton({
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _themeSpinner({double size = 22, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? AppColors.jebbyBlue,
      ),
    );
  }

  Widget _buildAdjustPinScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerIconButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.jebbyTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust pin',
                          style: onboardingNunito(
                            size: 22,
                            weight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fine-tune the pickup location on the map.',
                          style: onboardingNunito(
                            size: 14,
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
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Fine-tune your pickup spot.',
                      style: onboardingNunito(size: 22, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Move the map to position the pin.',
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GoogleMap(
                              initialCameraPosition: _initialCamera,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              onMapCreated: (controller) =>
                                  _mapController = controller,
                              onCameraMove: _onCameraMove,
                              onCameraIdle: _onCameraIdle,
                            ),
                            if (_mapCityLabel.isNotEmpty)
                              Positioned(
                                left: 16,
                                top: 16,
                                child: Text(
                                  _mapCityLabel,
                                  style: onboardingNunito(
                                    size: 22,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 48,
                                  color: AppColors.jebbyBlue,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 10,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                            child: _previewLoading
                                ? Center(
                                    child: _themeSpinner(size: 20),
                                  )
                                : Icon(
                                    Icons.place_outlined,
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
                                  _pinCardLine1,
                                  style: onboardingNunito(
                                    size: 16,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                if (_pinCardCityLine.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _pinCardCityLine,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your street address stays the same.',
                      textAlign: TextAlign.center,
                      style: onboardingNunito(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: OnboardingPrimaryButton(
                label: 'Confirm pin',
                isLoading: _resolving,
                onPressed: _confirmPin,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdjustPin) {
      return _buildAdjustPinScaffold(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  _headerIconButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.jebbyTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Pick on map',
                        style: _nunito(
                          size: 18,
                          weight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  _headerIconButton(
                    onTap: _locating ? null : _goToCurrentLocation,
                    child: _locating
                        ? _themeSpinner(size: 20)
                        : Icon(
                            Icons.my_location,
                            size: 22,
                            color: AppColors.jebbyBlue,
                          ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.jebbyBlue,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: _previewLoading
                                    ? _themeSpinner(size: 18)
                                    : Icon(
                                        Icons.place_outlined,
                                        size: 22,
                                        color: AppColors.jebbyBlue,
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _previewLoading && _previewLine.isEmpty
                                      ? 'Finding address…'
                                      : (_previewLine.isEmpty
                                          ? 'Move the map to choose a location'
                                          : _previewLine),
                                  style: _nunito(
                                    size: 14,
                                    weight: FontWeight.w700,
                                    color: AppColors.jebbyTextPrimary
                                        .withValues(alpha: 0.9),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _resolving ? null : _confirmPin,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.jebbyBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _resolving
                              ? _themeSpinner(size: 22, color: Colors.white)
                              : Text(
                                  'Use this location',
                                  style: _nunito(
                                    size: 16,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
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
}
