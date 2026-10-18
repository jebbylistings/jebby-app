import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/product_chat_context.dart';
import '../../../models/reservation.dart';
import '../../../constants/app_url.dart';
import '../../../constants/color.dart';
import '../../../utils/inspection_roles.dart';
import '../../../utils/order_status.dart';
import '../../../utils/api_datetime.dart';
import '../../../utils/profile_image.dart';
import '../../../utils/public_location.dart';
import '../../../utils/rental_date.dart';
import '../../../view_models/reservation_view_model.dart';
import '../../../utils/earner_navigation.dart';
import '../../../utils/google_places_address.dart';
import 'inspection_flow.dart';
import 'report_issue.dart';
import 'rental_request_review.dart';
import 'reservation_flow_theme.dart';
import '../home/messages.dart';
import '../profile/user_profile.dart';
import '../vendors/listing/listing_kit.dart';
import '../../widgets/jebby_flow_back_button.dart';
import '../agreements/insurance_and_indemnifications.dart';

const _titleDark = Color(0xFF1B1B1F);
const _labelGrey = Color(0xFF72747A);
const _bodyGrey = Color(0xFF6D6D75);
const _cardBorder = Color(0xFFE3E6EC);
const _activeRentalBg = Color(0xFFE6F7F5);
const _activeRentalFg = Color(0xFF0D9488);
const _completedBadgeBg = Color(0xFFDCFCE7);
const _completedBadgeFg = Color(0xFF16A34A);
const _scheduledBg = AppColors.primaryColorLight;
const _scheduledFg = AppColors.jebbyAccentOrange;
const _declineRed = Color(0xFFD15B57);
const _declinePinkBg = Color(0xFFFBE7E7);

TextStyle _nunito({
  double? size,
  FontWeight? weight,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

TextStyle _titleStyle({double size = 16}) {
  return _nunito(size: size, weight: FontWeight.w800, color: _titleDark);
}

TextStyle _sectionHeaderStyle() {
  return _nunito(
    size: 14,
    weight: FontWeight.w600,
    color: AppColors.jebbyTextMuted,
  );
}

TextStyle _bodyStyle({double size = 14}) {
  return _nunito(size: size, weight: FontWeight.w600, color: _bodyGrey, height: 1.45);
}

TextStyle _valueStyle({double size = 15}) {
  return _nunito(size: size, weight: FontWeight.w600, color: _titleDark, height: 1.35);
}

ButtonStyle _primaryButton({double height = 52}) {
  return FilledButton.styleFrom(
    backgroundColor: AppColors.jebbyBlue,
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.grey.shade300,
    disabledForegroundColor: Colors.grey.shade600,
    elevation: 0,
    minimumSize: Size.fromHeight(height),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: _nunito(size: 16, weight: FontWeight.w800, color: Colors.white),
  );
}

ButtonStyle _secondaryButton(Color accent, {double height = 48}) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    disabledForegroundColor: accent.withValues(alpha: 0.55),
    side: BorderSide(color: accent),
    disabledBackgroundColor: Colors.transparent,
    minimumSize: Size.fromHeight(height),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: _nunito(size: 15, weight: FontWeight.w700, color: accent),
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _cardBorder),
  );
}

Widget _handoffInfoRow({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.jebbySoftBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.jebbyBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: _valueStyle(),
          ),
        ),
      ],
    ),
  );
}

Widget _rentalStatusBadge(String label, {required String? orderStatus}) {
  final normalized = OrderStatus.normalize(orderStatus);
  late final Color bg;
  late final Color fg;
  IconData? icon;
  var text = label;

  if (normalized == OrderStatus.active) {
    bg = _activeRentalBg;
    fg = _activeRentalFg;
    text = '• $label';
  } else if (OrderStatus.isCompleted(normalized)) {
    bg = _completedBadgeBg;
    fg = _completedBadgeFg;
    icon = Icons.check_circle_outline_rounded;
  } else {
    bg = AppColors.jebbySoftBlue;
    fg = AppColors.jebbyBlue;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: _nunito(size: 12, weight: FontWeight.w700, color: fg),
        ),
      ],
    ),
  );
}

Widget _arrivalStatusBadge(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: _scheduledBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: _nunito(size: 12, weight: FontWeight.w700, color: _scheduledFg),
    ),
  );
}

ButtonStyle _handoffOutlineButton(Color accent, {double height = 52}) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    disabledForegroundColor: accent.withValues(alpha: 0.55),
    side: BorderSide(color: accent),
    disabledBackgroundColor: Colors.transparent,
    minimumSize: Size.fromHeight(height),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: _nunito(size: 16, weight: FontWeight.w700, color: accent),
  );
}

ButtonStyle _handoffPrimaryButton({double height = 52}) {
  return FilledButton.styleFrom(
    backgroundColor: AppColors.jebbyBlue,
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.grey.shade300,
    disabledForegroundColor: Colors.grey.shade600,
    elevation: 0,
    minimumSize: Size.fromHeight(height),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: _nunito(size: 16, weight: FontWeight.w700, color: Colors.white),
  );
}

({String primary, String secondary}) _handoffAddressLines(String address) {
  final trimmed = address.trim();
  if (trimmed.isEmpty || trimmed == '—' || trimmed.toLowerCase().contains('hidden')) {
    return (primary: trimmed.isEmpty ? '—' : trimmed, secondary: '');
  }
  final parts = trimmed.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  if (parts.length == 1) {
    return (primary: parts[0], secondary: '');
  }
  final primary = parts.first;
  final secondary = parts.sublist(1).join(', ');
  return (primary: primary, secondary: secondary);
}

/// Map preview — same layout as listing [`_LocationMapPreview`].
class _HandoffPickupMapPreview extends StatelessWidget {
  final LatLng target;

  const _HandoffPickupMapPreview({required this.target});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
                zoom: 16,
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
              liteModeEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _HandoffLocationMapPreview extends StatefulWidget {
  final String address;
  final bool addressRevealed;
  final double? latitude;
  final double? longitude;

  const _HandoffLocationMapPreview({
    required this.address,
    required this.addressRevealed,
    this.latitude,
    this.longitude,
  });

  @override
  State<_HandoffLocationMapPreview> createState() => _HandoffLocationMapPreviewState();
}

class _HandoffLocationMapPreviewState extends State<_HandoffLocationMapPreview> {
  LatLng? _target;
  bool _loading = true;
  final _places = GooglePlacesAddressService();

  static bool _plausibleUsCoordinates(double lat, double lng) {
    return lat >= 17 && lat <= 72 && lng >= -170 && lng <= -50;
  }

  static LatLng? _normalizeCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null || lat.isNaN || lng.isNaN) return null;
    if (lat == 0 && lng == 0) return null;

    var latitude = lat;
    var longitude = lng;
    if (!_plausibleUsCoordinates(latitude, longitude) &&
        _plausibleUsCoordinates(longitude, latitude)) {
      latitude = lng;
      longitude = lat;
    }
    if (!_plausibleUsCoordinates(latitude, longitude)) return null;
    return LatLng(latitude, longitude);
  }

  Iterable<String> _addressGeocodeQueries(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return const [];
    final parts = trimmed.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return {
      trimmed,
      if (parts.length >= 2) parts.sublist(1).join(', '),
    };
  }

  Future<LatLng?> _geocodeForMap(String address) async {
    for (final query in _addressGeocodeQueries(address)) {
      try {
        final parsed = await _places.geocodeAddress(query);
        final fromPlaces = _normalizeCoordinates(parsed?.latitude, parsed?.longitude);
        if (fromPlaces != null) return fromPlaces;
      } catch (_) {}
    }

    for (final query in _addressGeocodeQueries(address)) {
      try {
        final locations = await locationFromAddress(query);
        if (locations.isEmpty) continue;
        final fromDevice = _normalizeCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        if (fromDevice != null) return fromDevice;
      } catch (_) {}
    }

    return null;
  }

  static double _metersBetween(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  LatLng? _pickMapTarget(LatLng? geocoded, LatLng? fromApi) {
    if (geocoded == null) return fromApi;
    if (fromApi == null) return geocoded;
    // Order API coords are often wrong; keep listing pin when it matches geocode.
    if (_metersBetween(geocoded, fromApi) <= 400) return fromApi;
    return geocoded;
  }

  @override
  void initState() {
    super.initState();
    _resolveTarget();
  }

  @override
  void didUpdateWidget(covariant _HandoffLocationMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.address != widget.address ||
        oldWidget.addressRevealed != widget.addressRevealed) {
      _resolveTarget();
    }
  }

  Future<void> _resolveTarget() async {
    if (!widget.addressRevealed) {
      if (mounted) {
        setState(() {
          _target = null;
          _loading = false;
        });
      }
      return;
    }

    final addr = widget.address.trim();
    if (addr.isEmpty || addr.contains('hidden') || addr == '—') {
      if (mounted) {
        setState(() {
          _target = null;
          _loading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _loading = true);

    final geocoded = await _geocodeForMap(addr);
    final fromApi = _normalizeCoordinates(widget.latitude, widget.longitude);
    final target = _pickMapTarget(geocoded, fromApi);

    if (!mounted) return;
    setState(() {
      _target = target;
      _loading = false;
    });
  }

  Widget _mapPlaceholder(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: const Color(0xFFE8EDF3),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade500),
                )
              : Icon(icon, size: 40, color: Colors.grey.shade400),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: _target != null
          ? _HandoffPickupMapPreview(target: _target!)
          : _mapPlaceholder(
              widget.addressRevealed ? Icons.map_outlined : Icons.location_off_outlined,
            ),
    );
  }
}

bool _isHandoffTraveler(Reservation reservation) {
  return reservation.canUpdateHandoff ||
      OrderStatus.canUpdateHandoffStatus(
        transportType: reservation.transportType,
        role: reservation.role,
      );
}

String _handoffArrivedConfirmMessage(Reservation reservation) {
  final role = reservation.role?.trim().toLowerCase();
  if (role == 'earner') return 'Are you sure you have found the renter?';
  if (role == 'renter') return 'Are you sure you have found the earner?';
  return 'Are you sure you are at the location with the other party?';
}

Future<void> _confirmHandoffArrival(
  BuildContext context,
  Reservation reservation,
  ReservationViewModel vm, {
  VoidCallback? onStart,
  VoidCallback? onEnd,
}) async {
  final phase = OrderStatus.handoffPhaseForOrder(
    reservation.orderStatus,
    handoffPhase: reservation.handoffPhase,
  );
  final theme = ReservationFlowTheme(phase);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Confirm arrival', style: _titleStyle(size: 18)),
      content: Text(
        _handoffArrivedConfirmMessage(reservation),
        style: _bodyStyle(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            'Cancel',
            style: _nunito(size: 15, weight: FontWeight.w600, color: _labelGrey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            "Yes, I'm here",
            style: _nunito(size: 15, weight: FontWeight.w800, color: theme.accent),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  onStart?.call();
  await vm.markArrived(reservation.id);
  if (context.mounted) onEnd?.call();
}

String _formatMoney(num? value) {
  if (value == null) return '—';
  final amount = value.toDouble();
  if (amount == amount.roundToDouble()) {
    return '\$${amount.toStringAsFixed(0)}';
  }
  return '\$${amount.toStringAsFixed(2)}';
}

String _depositStatusMessage(Reservation reservation) {
  final status = reservation.depositRefundStatus?.trim().toLowerCase() ?? 'pending';
  switch (status) {
    case 'refunded':
      final when = formatApiDate(reservation.depositRefundedAt, pattern: 'M/d/yyyy');
      return when.isEmpty
          ? 'Refunded to your original payment method.'
          : 'Refunded to your original payment method on $when.';
    case 'withheld':
      return 'Held while a reported issue is reviewed.';
    case 'failed':
      return 'Refund is processing. We will retry automatically.';
    case 'skipped':
      return '';
    default:
      if (reservation.orderStatus == 'DISPUTE_WINDOW_24H') {
        return 'Held until the dispute window ends, then refunded if no issue is filed.';
      }
      if (OrderStatus.isTerminal(reservation.orderStatus)) {
        return 'Refund to your original payment method is processing.';
      }
      return 'Held until the return is complete, then refunded if no issue is reported.';
  }
}

({String label, Color bg, Color fg}) _depositStatusPill(Reservation reservation) {
  final status = reservation.depositRefundStatus?.trim().toLowerCase() ?? 'pending';
  switch (status) {
    case 'refunded':
      return (label: 'Refunded', bg: _activeRentalBg, fg: _activeRentalFg);
    case 'withheld':
      return (label: 'Under review', bg: _declinePinkBg, fg: _declineRed);
    case 'failed':
      return (label: 'Processing', bg: const Color(0xFFF0F1F4), fg: _labelGrey);
    default:
      if (reservation.orderStatus == 'DISPUTE_WINDOW_24H') {
        return (label: 'Dispute window', bg: _scheduledBg, fg: _scheduledFg);
      }
      return (label: 'Held', bg: _scheduledBg, fg: _scheduledFg);
  }
}

Widget _depositStatusBadge(Reservation reservation) {
  final pill = _depositStatusPill(reservation);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: pill.bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      pill.label,
      style: _nunito(size: 13, weight: FontWeight.w700, color: pill.fg),
    ),
  );
}

class ReservationDetailScreen extends StatefulWidget {
  final int orderId;

  const ReservationDetailScreen({super.key, required this.orderId});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JebbyFlowBackButton(onTap: _handleBack),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Details',
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reservation #${widget.orderId}',
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final vm = context.read<ReservationViewModel>();
    if (vm.reservation?.id != widget.orderId) {
      vm.beginOrderLoad(widget.orderId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await vm.loadReservation(widget.orderId);
      if (!mounted) return;
      final loaded = vm.reservation;
      if (loaded != null &&
          loaded.id == widget.orderId &&
          loaded.role == 'earner' &&
          loaded.nextAction.type == 'accept_booking') {
        Get.off(() => RentalRequestReviewScreen(orderId: widget.orderId));
        return;
      }
      _prefetchTrustIfNeeded(vm);
    });
  }

  void _prefetchTrustIfNeeded(ReservationViewModel vm) {
    final reservation = vm.reservation;
    if (reservation == null || OrderStatus.isTerminal(reservation.orderStatus)) return;
    final phase = _inspectionPhaseFor(reservation);
    if (phase == null) return;
    final status = OrderStatus.normalize(reservation.orderStatus);
    final handoffReady = OrderStatus.handoffReadyForInspection(
      orderStatus: reservation.orderStatus,
      handoffStatus: reservation.handoffStatus,
      phase: phase,
    );
    final needsTrust = handoffReady ||
        status == OrderStatus.pickupInProgress ||
        status == OrderStatus.returnInProgress ||
        status == OrderStatus.waitingPickupConfirmation ||
        status == OrderStatus.waitingReturnConfirmation;
    if (needsTrust) {
      vm.prefetchTrust(widget.orderId, phase: phase);
    }
  }

  String? _inspectionPhaseFor(Reservation reservation) {
    final action = reservation.nextAction.type;
    if (action.contains('return') || reservation.orderStatus.contains('RETURN')) {
      return 'return';
    }
    if (action.contains('inspection') ||
        action.startsWith('handoff') ||
        reservation.orderStatus.contains('PICKUP') ||
        reservation.orderStatus == 'SCHEDULED_HANDOFF' ||
        reservation.orderStatus == 'PAYMENT_CONFIRMED') {
      return 'pickup';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _pageHeader(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ReservationViewModel>(
                builder: (context, vm, _) {
                  final reservation = vm.reservation;
                  final forThisOrder = reservation?.id == widget.orderId;

                  if (!forThisOrder) {
                    if (vm.loading || reservation != null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.jebbyBlue,
                          strokeWidth: 2.4,
                        ),
                      );
                    }
                    return Center(
                      child: Text(vm.error ?? 'Reservation unavailable', style: _bodyStyle()),
                    );
                  }
                  if (reservation == null) {
                    return Center(
                      child: Text(vm.error ?? 'Reservation unavailable', style: _bodyStyle()),
                    );
                  }
                  final terminal = OrderStatus.isTerminal(reservation.orderStatus);
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.jebbyBlue,
                          backgroundColor: AppColors.jebbySoftBlue,
                          onRefresh: () async {
                            await vm.loadReservation(widget.orderId);
                            await vm.loadActionRequired();
                            if (!OrderStatus.isTerminal(vm.reservation?.orderStatus)) {
                              _prefetchTrustIfNeeded(vm);
                            }
                          },
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              _ProductDetailsCard(
                                reservation: reservation,
                                productDescription: vm.productDescription,
                              ),
                              const SizedBox(height: 12),
                              _EarnerInfoCard(reservation: reservation),
                              if (reservation.role == 'renter' &&
                                  (reservation.securityDeposit ?? 0) > 0 &&
                                  _depositStatusMessage(reservation).isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _DepositStatusCard(reservation: reservation),
                              ],
                              if (terminal) ...[
                                const SizedBox(height: 12),
                                _TerminalStatusCard(reservation: reservation),
                              ] else ...[
                                const SizedBox(height: 12),
                                _HandoffInfoCard(reservation: reservation),
                                if (OrderStatus.showHandoffActionsOnReservation(
                                  orderStatus: reservation.orderStatus,
                                  handoffStatus: reservation.handoffStatus,
                                  transportType: reservation.transportType,
                                  role: reservation.role,
                                  canUpdateHandoff: reservation.canUpdateHandoff,
                                )) ...[
                                  const SizedBox(height: 12),
                                  _HandoffActionsCard(reservation: reservation),
                                ] else if (OrderStatus.showHandoffWaitingOnReservation(
                                  orderStatus: reservation.orderStatus,
                                  handoffStatus: reservation.handoffStatus,
                                  transportType: reservation.transportType,
                                  role: reservation.role,
                                  canUpdateHandoff: reservation.canUpdateHandoff,
                                )) ...[
                                  const SizedBox(height: 12),
                                  _HandoffWaitingCard(reservation: reservation),
                                ],
                                if (_showTrustModule(reservation)) ...[
                                  const SizedBox(height: 12),
                                  _TrustInfoCard(reservation: reservation),
                                ],
                                if (_needsInlineAction(reservation)) ...[
                                  const SizedBox(height: 12),
                                  _PrimaryAction(reservation: reservation, vm: vm),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (!terminal)
                        _ReservationBottomBar(
                          reservation: reservation,
                          vm: vm,
                          orderId: widget.orderId,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _needsInlineAction(Reservation reservation) {
    final action = reservation.nextAction.type;
    return action == 'wait_acceptance' || action == 'wait_payment';
  }

  bool _showTrustModule(Reservation reservation) {
    if (OrderStatus.isTerminal(reservation.orderStatus)) return false;
    const hiddenActions = {
      'pay',
      'wait_payment',
      'wait_acceptance',
      'accept_booking',
      'active_rental',
    };
    return !hiddenActions.contains(reservation.nextAction.type);
  }
}

class _TerminalStatusCard extends StatelessWidget {
  final Reservation reservation;
  const _TerminalStatusCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final message = OrderStatus.terminalStatusMessage(reservation.orderStatus);
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Text(message, style: _bodyStyle()),
    );
  }
}

class _ProductDetailsCard extends StatelessWidget {
  final Reservation reservation;
  final String? productDescription;

  const _ProductDetailsCard({
    required this.reservation,
    this.productDescription,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = reservationImageUrl(reservation.productImage);
    final statusLabel = OrderStatus.displayLabel(reservation.orderStatus);
    final description =
        productDescription?.trim() ??
        reservation.productDescription?.trim() ??
        '';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 2.05,
                child: imageUrl.isEmpty
                    ? ColoredBox(
                        color: const Color(0xFFF0F2F5),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 48,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: const Color(0xFFF0F2F5),
                          child: Icon(
                            Icons.chair_outlined,
                            color: Colors.grey.shade500,
                            size: 48,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reservation.productName ?? 'Reservation',
                    style: _titleStyle(size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                _rentalStatusBadge(
                  statusLabel,
                  orderStatus: reservation.orderStatus,
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(description, style: _bodyStyle(size: 15)),
            ],
          ],
        ),
      ),
    );
  }
}

String _chatSummaryFromReservation(Reservation reservation) {
  final desc = reservation.productDescription?.trim() ?? '';
  if (desc.isEmpty) return '';
  final firstLine = desc.split(RegExp(r'\r?\n')).first.trim();
  if (firstLine.length <= 72) return firstLine;
  return '${firstLine.substring(0, 69)}…';
}

String _chatLocationLineFromReservation(Reservation reservation) {
  final loc = reservation.location?.trim() ?? '';
  if (loc.isEmpty) return '';
  final city = PublicLocation.cityStateLine(loc) ?? loc;
  return '$city · Available for pickup today';
}

void _openCounterpartyChat(Reservation reservation) {
  final targetId = reservation.counterpartyId;
  Get.to(
    () => Chat(
      targetId,
      productContext: ProductChatContext(
        productId: reservation.productId.toString(),
        name: reservation.productName ?? '',
        price: reservation.totalPrice?.toString() ?? '',
        image: reservation.productImage ?? '',
        vendorUserId: reservation.vendorId.toString(),
        recipientId: targetId.toString(),
        description: _chatSummaryFromReservation(reservation),
        locationLine: _chatLocationLineFromReservation(reservation),
        orderId: reservation.id.toString(),
        rentalStartDate: reservation.rentalStartDate ?? '',
        rentalEndDate: reservation.rentalEndDate ?? '',
        orderStatus: reservation.orderStatus,
      ),
    ),
  );
}

Widget _counterpartyChatButton(Reservation reservation) {
  return Material(
    color: AppColors.jebbySoftBlue,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => _openCounterpartyChat(reservation),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.chat_outlined, color: AppColors.jebbyBlue, size: 18),
      ),
    ),
  );
}

class _EarnerInfoCard extends StatelessWidget {
  final Reservation reservation;
  const _EarnerInfoCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final label = reservation.counterpartyLabel?.trim().isNotEmpty == true
        ? reservation.counterpartyLabel!
        : (reservation.role == 'earner' ? 'Renter' : 'Earner');
    final name = reservation.counterpartyName?.trim().isNotEmpty == true
        ? reservation.counterpartyName!.trim()
        : label;

    void openProfile() {
      Get.to(
        () => UserProfileScreen(
          vendorID: reservation.counterpartyId.toString(),
          vendorName: name,
          vendorImage: reservation.counterpartyImage,
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: openProfile,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ProfileImage.circularAvatar(
                      radius: 28,
                      baseUrl: AppUrl.baseUrlM,
                      imagePath: reservation.counterpartyImage,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: _titleStyle(size: 16)),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: _nunito(
                              size: 15,
                              weight: FontWeight.w600,
                              color: _bodyGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(child: _counterpartyChatButton(reservation)),
          ),
        ],
      ),
    );
  }
}

class _DepositStatusCard extends StatelessWidget {
  final Reservation reservation;
  const _DepositStatusCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final message = _depositStatusMessage(reservation);
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Security deposit', style: _sectionHeaderStyle()),
                    const SizedBox(height: 6),
                    Text(
                      _formatMoney(reservation.securityDeposit),
                      style: _titleStyle(size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _depositStatusBadge(reservation),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.lock_outline, size: 20, color: _labelGrey),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(message, style: _bodyStyle())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HandoffInfoCard extends StatelessWidget {
  final Reservation reservation;
  const _HandoffInfoCard({required this.reservation});

  bool get _isReturnPhase {
    return OrderStatus.handoffPhaseForOrder(
          reservation.orderStatus,
          handoffPhase: reservation.handoffPhase,
        ) ==
        'return';
  }

  static String _transportLabel(String? type) {
    if (type == 'delivery') return 'Delivery & Retrieval';
    return 'Pickup & Return';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReservationFlowTheme(_isReturnPhase ? 'return' : 'pickup');
    final address = reservation.addressRevealed
        ? (reservation.location?.trim().isNotEmpty == true ? reservation.location! : '—')
        : 'Address hidden until payment is confirmed';

    final dateTime = _isReturnPhase
        ? formatHandoffWindowRange(
            reservation.returnWindowBegin,
            reservation.returnWindowEnd,
          )
        : formatHandoffWindowRange(
            reservation.pickupWindowBegin,
            reservation.pickupWindowEnd,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(theme.handoffInfoTitle, style: _sectionHeaderStyle()),
          const SizedBox(height: 14),
          if (dateTime.isNotEmpty)
            _handoffInfoRow(icon: Icons.calendar_today_outlined, text: dateTime),
          _handoffInfoRow(icon: Icons.location_on_outlined, text: address),
          _handoffInfoRow(
            icon: Icons.local_shipping_outlined,
            text: _transportLabel(reservation.transportType),
          ),
        ],
      ),
    );
  }
}

class _HandoffWaitingCard extends StatelessWidget {
  final Reservation reservation;
  const _HandoffWaitingCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final status = reservation.handoffStatus;
    final message = OrderStatus.handoffWaitingStatusMessage(
      transportType: reservation.transportType,
      handoffStatus: status,
    );

    final statusLabel = OrderStatus.handoffStatusLabel(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('Arrival Status', style: _sectionHeaderStyle()),
              ),
              const SizedBox(width: 12),
              _arrivalStatusBadge(statusLabel),
            ],
          ),
          if (status == 'ON_THE_WAY' && reservation.handoffEtaMinutes != null) ...[
            const SizedBox(height: 10),
            Text(
              'ETA: ${reservation.handoffEtaMinutes} minutes',
              style: _valueStyle(size: 14),
            ),
          ],
          SizedBox(height: status == 'ON_THE_WAY' && reservation.handoffEtaMinutes != null ? 10 : 12),
          Text(message, style: _bodyStyle(size: 15)),
        ],
      ),
    );
  }
}

class _HandoffActionsCard extends StatefulWidget {
  final Reservation reservation;
  const _HandoffActionsCard({required this.reservation});

  @override
  State<_HandoffActionsCard> createState() => _HandoffActionsCardState();
}

class _HandoffActionsCardState extends State<_HandoffActionsCard> {
  bool _busy = false;

  Reservation get reservation => widget.reservation;

  String get _phase => OrderStatus.handoffPhaseForOrder(
        reservation.orderStatus,
        handoffPhase: reservation.handoffPhase,
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ReservationViewModel>();
    final status = reservation.handoffStatus;
    final isDelayed = status == 'DELAYED';
    final address = reservation.addressRevealed
        ? (reservation.location?.trim().isNotEmpty == true ? reservation.location! : '—')
        : 'Address hidden until payment is confirmed';

    final accent = AppColors.jebbyBlue;
    final addressLines = _handoffAddressLines(address);
    final showOnMyWay = !isDelayed && status != 'ARRIVED' && status != 'ON_THE_WAY';

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reservation.handoffEtaMinutes != null && status == 'ON_THE_WAY')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'ETA: ${reservation.handoffEtaMinutes} minutes',
                style: _valueStyle(size: 14),
              ),
            ),
          _HandoffLocationMapPreview(
            address: address,
            addressRevealed: reservation.addressRevealed,
            latitude: reservation.latitude,
            longitude: reservation.longitude,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.jebbySoftBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
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
                            addressLines.primary,
                            style: _nunito(
                              size: 16,
                              weight: FontWeight.w800,
                              color: _titleDark,
                              height: 1.3,
                            ),
                          ),
                          if (addressLines.secondary.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              addressLines.secondary,
                              style: _nunito(
                                size: 14,
                                weight: FontWeight.w600,
                                color: _labelGrey,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (reservation.addressRevealed) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: _handoffPrimaryButton(),
                    onPressed: () => _openDirections(address),
                    icon: const Icon(Icons.near_me_outlined, size: 20),
                    label: const Text('Get directions'),
                  ),
                ],
                if (showOnMyWay) ...[
                  SizedBox(height: reservation.addressRevealed ? 12 : 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: _handoffOutlineButton(accent),
                      onPressed: _busy ? null : () => _showEtaPicker(vm),
                      child: _busy
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent.withValues(alpha: 0.55),
                              ),
                            )
                          : const Text("I'm On My Way"),
                    ),
                  ),
                ],
                if (isDelayed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: _handoffOutlineButton(accent),
                      onPressed: () => Get.to(
                        () => ReportIssueScreen(orderId: reservation.id, phase: _phase),
                      ),
                      child: const Text('Report a problem'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(String address) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showEtaPicker(ReservationViewModel vm) async {
    const options = ['15 minutes', '30 minutes', '45 minutes', '60 minutes'];
    final picked = await showListingChoiceSheet(
      context,
      title: 'Estimated arrival',
      options: options,
    );
    if (picked == null || !mounted) return;

    final minutes = int.tryParse(picked.split(' ').first);
    if (minutes == null) return;

    setState(() => _busy = true);
    await vm.markOnTheWay(reservation.id, minutes);
    if (mounted) setState(() => _busy = false);
  }
}

class _HandoffArrivalButton extends StatefulWidget {
  final Reservation reservation;
  final ReservationViewModel vm;
  final double height;

  const _HandoffArrivalButton({
    required this.reservation,
    required this.vm,
    this.height = 52,
  });

  @override
  State<_HandoffArrivalButton> createState() => _HandoffArrivalButtonState();
}

class _HandoffArrivalButtonState extends State<_HandoffArrivalButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final phase = OrderStatus.handoffPhaseForOrder(
      widget.reservation.orderStatus,
      handoffPhase: widget.reservation.handoffPhase,
    );
    final theme = ReservationFlowTheme(phase);

    return FilledButton(
      style: theme.primaryButton(height: widget.height),
      onPressed: _busy
          ? null
          : () => _confirmHandoffArrival(
                context,
                widget.reservation,
                widget.vm,
                onStart: () => setState(() => _busy = true),
                onEnd: () => setState(() => _busy = false),
              ),
      child: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(theme.arrivalButtonLabel),
    );
  }
}

class _TrustInfoCard extends StatelessWidget {
  final Reservation reservation;
  const _TrustInfoCard({required this.reservation});

  bool get _isReturnPhase {
    final action = reservation.nextAction.type;
    if (action.contains('return')) return true;
    final status = OrderStatus.normalize(reservation.orderStatus);
    return status == OrderStatus.scheduledReturn ||
        status == OrderStatus.returnInProgress ||
        status == OrderStatus.waitingReturnConfirmation;
  }

  String get _bodyCopy {
    if (_isReturnPhase) {
      return 'Both parties will inspect this item and confirm its condition is returned in working order.';
    }
    return InspectionRoles.isInitiator('pickup', reservation.role)
        ? 'You will complete the pickup inspection. The provider will review and confirm.'
        : 'The renter will complete the pickup inspection. You will review and confirm.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.jebbySoftBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.jebbyBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Trust & Security',
                style: _nunito(
                  size: 16,
                  weight: FontWeight.w800,
                  color: AppColors.jebbyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _bodyCopy,
            style: _nunito(
              size: 14,
              weight: FontWeight.w600,
              color: const Color(0xFF4A4A4A),
              height: 1.45,
            ),
          ),
          if (_isReturnPhase) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Get.to(() => const InsuranceAndIndemnificationsScreen()),
              borderRadius: BorderRadius.circular(4),
              child: Text(
                'Learn more about safety',
                style: _nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyBlue,
                  height: 1.35,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.jebbyBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReservationBottomBar extends StatelessWidget {
  final Reservation reservation;
  final ReservationViewModel vm;
  final int orderId;

  const _ReservationBottomBar({
    required this.reservation,
    required this.vm,
    required this.orderId,
  });

  String? _inspectionPhase() {
    final action = reservation.nextAction.type;
    if (action.contains('return') || reservation.orderStatus.contains('RETURN')) {
      return 'return';
    }
    if (action.contains('inspection') ||
        action.startsWith('handoff') ||
        reservation.orderStatus.contains('PICKUP') ||
        reservation.orderStatus == 'SCHEDULED_HANDOFF' ||
        reservation.orderStatus == 'PAYMENT_CONFIRMED') {
      return 'pickup';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final action = reservation.nextAction.type;
    final phase = _inspectionPhase();
    final theme = ReservationFlowTheme(phase ?? 'pickup');

    Widget? child;
    if (action == 'pay') {
      child = FilledButton(
        style: _primaryButton(height: 52),
        onPressed: vm.paymentLoading ? null : () => vm.payForAcceptedOrder(reservation),
        child: vm.paymentLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                reservation.paymentAmountDue == null
                    ? 'Complete payment'
                    : 'Complete payment · \$${reservation.paymentAmountDue}',
                textAlign: TextAlign.center,
              ),
      );
    } else if (phase != null &&
        (action.startsWith('inspection') ||
            action.startsWith('handoff') ||
            reservation.orderStatus == 'PICKUP_IN_PROGRESS' ||
            reservation.orderStatus == 'RETURN_IN_PROGRESS' ||
            reservation.orderStatus == 'WAITING_PICKUP_CONFIRMATION' ||
            reservation.orderStatus == 'WAITING_RETURN_CONFIRMATION')) {
      final isInitiator = InspectionRoles.isInitiator(phase, reservation.role);
      final handoffReady = OrderStatus.handoffReadyForInspection(
        orderStatus: reservation.orderStatus,
        handoffStatus: reservation.handoffStatus,
        phase: phase,
      );
      final isTraveler = _isHandoffTraveler(reservation);
      final arrivalAvailable = OrderStatus.showHandoffActionsOnReservation(
            orderStatus: reservation.orderStatus,
            handoffStatus: reservation.handoffStatus,
            transportType: reservation.transportType,
            role: reservation.role,
            canUpdateHandoff: reservation.canUpdateHandoff,
          ) &&
          reservation.handoffStatus != 'DELAYED';
      final showTravelerArrivalInBottom =
          isTraveler && !isInitiator && !handoffReady && arrivalAvailable;
      final showInitiatorArrivalInBottom = isInitiator &&
          !handoffReady &&
          arrivalAvailable &&
          reservation.handoffStatus != 'DELAYED';
      final showArrivalInBottom = showTravelerArrivalInBottom || showInitiatorArrivalInBottom;
      final canOpenInspection = handoffReady;
      final showContinueInspection = OrderStatus.showContinueInspectionLabel(
        orderStatus: reservation.orderStatus,
        hasStartedInspection: vm.trustStatus?.inspection != null,
      );
      if (showArrivalInBottom) {
        child = _HandoffArrivalButton(reservation: reservation, vm: vm, height: 52);
      } else {
        final label = isInitiator
            ? (showContinueInspection ? theme.continueInspectionLabel : theme.beginInspectionLabel)
            : theme.reviewConfirmLabel;
        child = FilledButton(
          style: theme.primaryButton(height: 52),
          onPressed: canOpenInspection
              ? () => Get.to(() => InspectionFlowScreen(orderId: orderId, phase: phase))
              : null,
          child: Text(label),
        );
      }
    } else if (OrderStatus.canReportIssueOrNoShow(reservation.orderStatus) &&
        reservation.openDispute == null) {
      child = OutlinedButton(
        style: _secondaryButton(AppColors.jebbyBlue, height: 48),
        onPressed: () => Get.to(() => ReportIssueScreen(orderId: orderId)),
        child: const Text('Report issue or no-show'),
      );
    }

    if (child == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.jebbyBackground,
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final Reservation reservation;
  final ReservationViewModel vm;
  const _PrimaryAction({required this.reservation, required this.vm});

  @override
  Widget build(BuildContext context) {
    final action = reservation.nextAction.type;
    if (action == 'wait_acceptance' || action == 'wait_payment') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Text(
          reservation.nextAction.label,
          textAlign: TextAlign.center,
          style: _bodyStyle(),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
