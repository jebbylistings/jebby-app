import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/views/widgets/address_map_picker_screen.dart';

TextStyle _addressNunito({
  double size = 15,
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

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final ParsedUsAddress? resolvedAddress;
  final Future<void> Function(ParsedUsAddress address) onAddressSelected;
  final VoidCallback? onEditingStarted;
  final InputDecoration? decoration;
  final String hint;
  final bool showConfirmationChip;
  final bool promptForMissingFields;
  final bool enableMapPicker;
  final double? mapPickerInitialLatitude;
  final double? mapPickerInitialLongitude;
  final int maxLines;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.onAddressSelected,
    this.resolvedAddress,
    this.onEditingStarted,
    this.decoration,
    this.hint = 'Start typing your address',
    this.showConfirmationChip = true,
    this.promptForMissingFields = true,
    this.enableMapPicker = false,
    this.mapPickerInitialLatitude,
    this.mapPickerInitialLongitude,
    this.maxLines = 1,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final GooglePlacesAddressService _placesService = GooglePlacesAddressService();
  List<Map<String, dynamic>> _predictions = [];
  bool _loadingDetails = false;
  bool _suppressEditingCallback = false;

  Future<void> _onQueryChanged(String value) async {
    if (_suppressEditingCallback) return;
    widget.onEditingStarted?.call();
    if (value.trim().length < 3) {
      if (mounted) setState(() => _predictions = []);
      return;
    }

    try {
      final results = await _placesService.fetchPredictions(value);
      if (mounted) setState(() => _predictions = results.take(5).toList());
    } catch (_) {
      if (mounted) setState(() => _predictions = []);
    }
  }

  Future<void> _selectPrediction(Map<String, dynamic> prediction) async {
    final description = prediction['description']?.toString() ?? '';
    final placeId = prediction['place_id']?.toString() ?? '';
    if (placeId.isEmpty) return;

    setState(() {
      _loadingDetails = true;
      _predictions = [];
    });
    _suppressEditingCallback = true;
    widget.controller.text = description;
    _suppressEditingCallback = false;

    try {
      final parsed = await _placesService.resolvePlace(placeId);
      if (!mounted || parsed == null) return;

      if (parsed.isComplete) {
        await widget.onAddressSelected(parsed);
        return;
      }

      if (!widget.promptForMissingFields) {
        await widget.onAddressSelected(parsed);
        return;
      }

      final completed = await showMissingAddressDialog(
        context,
        initial: parsed,
      );
      if (!mounted) return;
      if (completed != null) {
        await widget.onAddressSelected(completed);
      }
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  Future<void> _openMapPicker() async {
    final lat =
        widget.resolvedAddress?.latitude ?? widget.mapPickerInitialLatitude;
    final lng =
        widget.resolvedAddress?.longitude ?? widget.mapPickerInitialLongitude;
    final picked = await showAddressMapPicker(
      context,
      initialLatitude: lat,
      initialLongitude: lng,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _loadingDetails = true;
      _predictions = [];
    });
    _suppressEditingCallback = true;
    widget.controller.text = picked.displayLine;
    _suppressEditingCallback = false;

    try {
      if (picked.isComplete) {
        await widget.onAddressSelected(picked);
        return;
      }

      if (!widget.promptForMissingFields) {
        await widget.onAddressSelected(picked);
        return;
      }

      final completed = await showMissingAddressDialog(
        context,
        initial: picked,
      );
      if (!mounted) return;
      if (completed != null) {
        await widget.onAddressSelected(completed);
      }
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  Widget? _buildSuffixIcon() {
    if (_loadingDetails) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.jebbyBlue,
          ),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.enableMapPicker) {
      children.add(
        IconButton(
          icon: Icon(Icons.map_outlined, color: AppColors.jebbyBlue),
          tooltip: 'Pick on map',
          onPressed: _openMapPicker,
        ),
      );
    }

    final custom = widget.decoration?.suffixIcon;
    if (custom != null) children.add(custom);

    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.resolvedAddress;
    final customDecoration = widget.decoration;
    final fieldDecoration = (customDecoration ??
            InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F7F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ))
        .copyWith(
      hintText: customDecoration?.hintText ?? widget.hint,
      hintStyle: customDecoration?.hintStyle ??
          _addressNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
          ),
      suffixIcon: _buildSuffixIcon(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          onChanged: _onQueryChanged,
          style: _addressNunito(size: 15, weight: FontWeight.w600),
          decoration: fieldDecoration,
        ),
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_predictions.length, (index) {
                  final prediction = _predictions[index];
                  final description =
                      prediction['description']?.toString() ?? '';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                      InkWell(
                        onTap: () => _selectPrediction(prediction),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                color: AppColors.jebbyBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  description,
                                  style: _addressNunito(
                                    size: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        if (widget.showConfirmationChip &&
            resolved != null &&
            resolved.displayLine.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF6EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB8D4B8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  resolved.hasResolvedMapLocation
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 18,
                  color: resolved.hasResolvedMapLocation
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resolved.displayLine,
                    style: _addressNunito(
                      size: 13,
                      weight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Future<ParsedUsAddress?> showMissingAddressDialog(
  BuildContext context, {
  required ParsedUsAddress initial,
}) {
  return showDialog<ParsedUsAddress>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _MissingAddressDialog(initial: initial),
  );
}

class _MissingAddressDialog extends StatefulWidget {
  final ParsedUsAddress initial;

  const _MissingAddressDialog({required this.initial});

  @override
  State<_MissingAddressDialog> createState() => _MissingAddressDialogState();
}

class _MissingAddressDialogState extends State<_MissingAddressDialog> {
  late final TextEditingController _line1Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalController;
  late String _stateCode;

  ParsedUsAddress get initial => widget.initial;

  @override
  void initState() {
    super.initState();
    _line1Controller = TextEditingController(text: initial.line1);
    _cityController = TextEditingController(text: initial.city);
    _postalController = TextEditingController(text: initial.postalCode);
    _stateCode = initial.state.toUpperCase();
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = ParsedUsAddress(
      line1: initial.hasLine1 ? initial.line1 : _line1Controller.text.trim(),
      city: initial.hasCity ? initial.city : _cityController.text.trim(),
      state: initial.hasState ? initial.state : _stateCode.toUpperCase(),
      postalCode: initial.hasPostalCode
          ? initial.postalCode
          : _postalController.text.trim(),
      formattedAddress: initial.formattedAddress,
      latitude: initial.latitude,
      longitude: initial.longitude,
    );
    if (!updated.isComplete) return;
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Complete your address',
        style: _addressNunito(
          size: 18,
          weight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We could not read every part of that address. Please fill in the missing details.',
              style: _addressNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (!initial.hasLine1) ...[
              _dialogLabel('Street address'),
              _dialogField(_line1Controller, '123 Main St'),
              const SizedBox(height: 12),
            ],
            if (!initial.hasCity) ...[
              _dialogLabel('City'),
              _dialogField(_cityController, 'City'),
              const SizedBox(height: 12),
            ],
            if (!initial.hasState) ...[
              _dialogLabel('State'),
              _AddressStateDropdown(
                value: _stateCode,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _stateCode = value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (!initial.hasPostalCode) ...[
              _dialogLabel('ZIP code'),
              _dialogField(
                _postalController,
                '94102',
                keyboardType: TextInputType.number,
                maxLength: 10,
                digitsOnly: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: _addressNunito(
              weight: FontWeight.w700,
              color: AppColors.jebbyTextMuted,
            ),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            'Save',
            style: _addressNunito(
              weight: FontWeight.w800,
              color: AppColors.jebbyBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: _addressNunito(
          size: 14,
          weight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int? maxLength,
    bool digitsOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: _addressNunito(size: 15, weight: FontWeight.w600),
      inputFormatters:
          digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _addressNunito(
          size: 15,
          weight: FontWeight.w600,
          color: AppColors.jebbyTextMuted,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _AddressStateDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?>? onChanged;

  const _AddressStateDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = ProviderOnboardingData.usStates
        .map((state) => state['code']!)
        .toList();
    final effectiveValue = items.contains(value) ? value : null;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isExpanded: true,
          hint: Text(
            'Select state',
            style: _addressNunito(
              size: 15,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: onChanged == null
                ? const Color(0xFFBDBEC6)
                : AppColors.jebbyTextMuted,
          ),
          onChanged: onChanged,
          style: _addressNunito(
            size: 14,
            weight: FontWeight.w600,
          ),
          items: items
              .map(
                (code) => DropdownMenuItem<String>(
                  value: code,
                  child: Text(
                    ProviderOnboardingData.stateName(code),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
