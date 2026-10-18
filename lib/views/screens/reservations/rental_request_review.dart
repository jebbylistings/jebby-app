import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_url.dart';
import '../../../constants/color.dart';
import '../../../models/product_chat_context.dart';
import '../../../models/reservation.dart';
import '../../../utils/api_datetime.dart';
import '../../../utils/profile_image.dart';
import '../../../utils/public_location.dart';
import '../../../utils/rental_date.dart';
import '../../../view_models/reservation_view_model.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../widgets/jebby_flow_back_button.dart';
import '../home/messages.dart';
import '../profile/user_profile.dart';
import 'reservation_detail.dart';
import 'reservation_flow_theme.dart';

const _titleDark = Color(0xFF1B1B1F);
const _bodyGrey = Color(0xFF6D6D75);
const _labelGrey = Color(0xFF72747A);
const _cardBorder = Color(0xFFE3E6EC);

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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _cardBorder),
  );
}

String _formatMoney(num? value) {
  if (value == null) return '—';
  final amount = value.toDouble();
  if (amount == amount.roundToDouble()) {
    return '\$${amount.toStringAsFixed(0)}';
  }
  return '\$${amount.toStringAsFixed(2)}';
}

int _rentalDayCount(Reservation reservation) {
  final start = rentalDateToDateTime(reservation.rentalStartDate);
  final end = rentalDateToDateTime(reservation.rentalEndDate);
  if (start == null || end == null) return 1;
  final days = end.difference(start).inDays;
  return days < 0 ? 1 : days + 1;
}

int _jebbyFeePercent(Reservation reservation) {
  final policy = reservation.policy;
  if (policy != null) {
    final raw = policy['vendor_fee_percent'] ?? policy['platform_fee_percent'];
    if (raw != null) {
      final parsed = int.tryParse('$raw');
      if (parsed != null && parsed > 0) return parsed;
    }
  }
  return 10;
}

(String rental, String fee, String estimated) _earningsBreakdown(Reservation r) {
  final rentalAmount = r.totalPrice ?? 0;
  var fee = r.paymentApplicationFees ?? 0;
  var estimated = r.vendorPayoutAmount;
  if (estimated == null && rentalAmount > 0) {
    if (fee <= 0) {
      fee = rentalAmount * _jebbyFeePercent(r) / 100;
    }
    estimated = rentalAmount - fee;
  } else if (fee <= 0 && estimated != null && rentalAmount > 0) {
    fee = rentalAmount - estimated;
  }
  return (
    _formatMoney(rentalAmount),
    fee <= 0 ? '—' : '-${_formatMoney(fee)}',
    _formatMoney(estimated),
  );
}

String _handoffSlotSummary(String? begin, String? end) {
  final b = parseApiDateTime(begin?.trim() ?? '');
  final e = parseApiDateTime(end?.trim() ?? '');
  if (b == null) return '—';
  final datePart = DateFormat('EEE, MMM d').format(b);
  if (e == null) return datePart;
  final startPeriod = DateFormat('a').format(b);
  final endPeriod = DateFormat('a').format(e);
  if (startPeriod == endPeriod) {
    return '$datePart · ${DateFormat('h').format(b)}–${DateFormat('h').format(e)} $startPeriod';
  }
  return '$datePart · ${DateFormat('h a').format(b)} – ${DateFormat('h a').format(e)}';
}

String _pickupLocationTitle(Reservation reservation) {
  if (reservation.transportType == 'delivery') {
    return 'Delivery to renter';
  }
  return 'Pickup at your location';
}

bool _isMaskedLocation(String? location) {
  final text = location?.trim().toLowerCase() ?? '';
  return text.contains('address hidden') || text.contains('hidden until');
}

String _pickupPublicLocationLine(
  Reservation reservation, {
  String? productPublicLocation,
}) {
  final raw = reservation.location?.trim() ?? '';
  if (reservation.addressRevealed &&
      raw.isNotEmpty &&
      !_isMaskedLocation(raw)) {
    return PublicLocation.cityStateLine(raw) ?? raw;
  }
  if (productPublicLocation?.trim().isNotEmpty == true) {
    return productPublicLocation!.trim();
  }
  if (raw.isNotEmpty && !_isMaskedLocation(raw)) {
    return PublicLocation.cityStateLineOr(raw, raw);
  }
  return PublicLocation.cityStateLineOr(productPublicLocation, 'City not available');
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
        orderId: reservation.id.toString(),
        rentalStartDate: reservation.rentalStartDate ?? '',
        rentalEndDate: reservation.rentalEndDate ?? '',
        orderStatus: reservation.orderStatus,
      ),
    ),
  );
}

/// Earner review of a pending rental request (accept / decline).
class RentalRequestReviewScreen extends StatefulWidget {
  const RentalRequestReviewScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<RentalRequestReviewScreen> createState() =>
      _RentalRequestReviewScreenState();
}

class _RentalRequestReviewScreenState extends State<RentalRequestReviewScreen> {
  String? _productPublicLocation;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ReservationViewModel>();
    if (vm.reservation?.id != widget.orderId) {
      vm.beginOrderLoad(widget.orderId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loadedVm = context.read<ReservationViewModel>();
      await loadedVm.loadReservation(widget.orderId);
      await _loadProductPublicLocation(loadedVm);
    });
  }

  Future<void> _loadProductPublicLocation(ReservationViewModel vm) async {
    final reservation = vm.reservation;
    if (reservation == null || reservation.id != widget.orderId) return;
    if (reservation.addressRevealed && !_isMaskedLocation(reservation.location)) {
      return;
    }
    try {
      final raw = await ApiRepository.shared.fetchProductDetailRaw(
        '${reservation.productId}',
      );
      final address = raw?['address']?.toString().trim() ?? '';
      final public = PublicLocation.cityStateLine(address);
      if (!mounted || public == null || public.isEmpty) return;
      setState(() => _productPublicLocation = public);
    } catch (_) {}
  }

  Future<void> _accept(ReservationViewModel vm, Reservation reservation) async {
    final ok = await vm.acceptOrder(reservation.id);
    if (!ok || !mounted) return;
    Get.off(() => ReservationDetailScreen(orderId: reservation.id));
  }

  Future<void> _decline(ReservationViewModel vm, Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Decline request?',
          style: _nunito(size: 18, weight: FontWeight.w800, color: _titleDark),
        ),
        content: Text(
          'The renter will be notified that this request was declined.',
          style: _nunito(size: 14, weight: FontWeight.w600, color: _bodyGrey, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: _nunito(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD15B57),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Decline',
              style: _nunito(
                size: 15,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await vm.declineOrder(reservation.id, reason: 'Order declined');
    if (ok && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Consumer<ReservationViewModel>(
          builder: (context, vm, _) {
            final reservation = vm.reservation;
            final forOrder = reservation?.id == widget.orderId;

            if (!forOrder || vm.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.jebbyBlue,
                  strokeWidth: 2.4,
                ),
              );
            }
            if (reservation == null) {
              return Center(
                child: Text(
                  vm.error ?? 'Request unavailable',
                  style: _nunito(size: 15, weight: FontWeight.w600, color: _bodyGrey),
                ),
              );
            }

            final renterName = reservation.counterpartyName?.trim().isNotEmpty == true
                ? reservation.counterpartyName!.trim()
                : 'Renter';
            final days = _rentalDayCount(reservation);
            final rentalTotal = reservation.totalPrice ?? 0;
            final dailyRate = days > 0 ? rentalTotal / days : rentalTotal;
            final earnings = _earningsBreakdown(reservation);
            final feePercent = _jebbyFeePercent(reservation);
            final accepting = vm.bookingActionLoading == 'accept';
            final declining = vm.bookingActionLoading == 'decline';
            final busy = vm.bookingActionLoading != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JebbyFlowBackButton(onTap: () => Get.back()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rental request',
                                style: _nunito(
                                  size: 22,
                                  weight: FontWeight.w800,
                                  color: _titleDark,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Review the request details below.',
                                style: _nunito(
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: _labelGrey,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _statusBadge(),
                      const SizedBox(height: 16),
                      Text(
                        '$renterName would like to rent your item.',
                        style: _nunito(
                          size: 28,
                          weight: FontWeight.w800,
                          color: _titleDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Review the details below, then accept or decline.',
                        style: _nunito(
                          size: 15,
                          weight: FontWeight.w600,
                          color: _bodyGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _itemCard(
                        reservation: reservation,
                        dailyRate: dailyRate,
                      ),
                      const SizedBox(height: 12),
                      _renterCard(reservation: reservation, renterName: renterName),
                      const SizedBox(height: 20),
                      Text(
                        'Pickup & return',
                        style: _nunito(
                          size: 18,
                          weight: FontWeight.w800,
                          color: _titleDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _locationCard(
                        reservation,
                        productPublicLocation: _productPublicLocation,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _scheduleTile(
                              label: 'Pickup',
                              value: _handoffSlotSummary(
                                reservation.pickupWindowBegin,
                                reservation.pickupWindowEnd,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _scheduleTile(
                              label: 'Return',
                              value: _handoffSlotSummary(
                                reservation.returnWindowBegin,
                                reservation.returnWindowEnd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your earnings',
                        style: _nunito(
                          size: 18,
                          weight: FontWeight.w800,
                          color: _titleDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _earningsCard(
                        reservation: reservation,
                        earnings: earnings,
                        feePercent: feePercent,
                        days: days,
                        dailyRate: dailyRate,
                      ),
                      if ((reservation.securityDeposit ?? 0) > 0) ...[
                        const SizedBox(height: 12),
                        _securityHoldBanner(reservation),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Accepting starts the renter\'s payment.',
                          style: _nunito(
                            size: 13,
                            weight: FontWeight.w600,
                            color: _labelGrey,
                            height: 1.35,
                          ),
                        ),
                        Text(
                          'Booking is confirmed once payment succeeds.',
                          style: _nunito(
                            size: 13,
                            weight: FontWeight.w600,
                            color: _labelGrey,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: busy ? null : () => _accept(vm, reservation),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.jebbyBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: accepting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Accept request',
                                    style: _nunito(
                                      size: 16,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: busy ? null : () => _decline(vm, reservation),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.jebbySoftBlue,
                              foregroundColor: AppColors.jebbyBlue,
                              disabledBackgroundColor:
                                  AppColors.jebbySoftBlue.withValues(alpha: 0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: declining
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.jebbyBlue,
                                    ),
                                  )
                                : Text(
                                    'Decline request',
                                    style: _nunito(
                                      size: 16,
                                      weight: FontWeight.w800,
                                      color: AppColors.jebbyBlue,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _statusBadge() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColorLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: AppColors.jebbyAccentOrange),
          const SizedBox(width: 6),
          Text(
            'Awaiting your response',
            style: _nunito(
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.jebbyAccentOrange,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _itemCard({
  required Reservation reservation,
  required num dailyRate,
}) {
  final imageUrl = reservationImageUrl(reservation.productImage);
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            height: 72,
            child: imageUrl.isEmpty
                ? ColoredBox(
                    color: const Color(0xFFF0F2F5),
                    child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                  )
                : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.productName?.trim().isNotEmpty == true
                    ? reservation.productName!.trim()
                    : 'Listing',
                style: _nunito(size: 20, weight: FontWeight.w800, color: _titleDark),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _formatMoney(dailyRate),
                      style: _nunito(
                        size: 24,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyBlue,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: ' / day',
                      style: _nunito(
                        size: 16,
                        weight: FontWeight.w600,
                        color: _labelGrey,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _renterCard({
  required Reservation reservation,
  required String renterName,
}) {
  void openProfile() {
    Get.to(
      () => UserProfileScreen(
        vendorID: reservation.counterpartyId.toString(),
        vendorName: renterName,
        vendorImage: reservation.counterpartyImage,
        showBackButton: true,
      ),
      preventDuplicates: false,
    );
  }

  return Container(
    decoration: _cardDecoration(),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        Padding(
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
                    Text(
                      'Renter',
                      style: _nunito(
                        size: 13,
                        weight: FontWeight.w600,
                        color: _labelGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      renterName,
                      style: _nunito(
                        size: 17,
                        weight: FontWeight.w800,
                        color: _titleDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: openProfile,
                      child: Text(
                        'View profile',
                        style: _nunito(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.jebbyBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 52),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: Material(
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
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _locationCard(
  Reservation reservation, {
  String? productPublicLocation,
}) {
  const locationIconSize = 22.0;
  const locationRowGap = 10.0;
  const locationTextInset = locationIconSize + locationRowGap;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.jebbyBlue, size: locationIconSize),
            const SizedBox(width: locationRowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickupLocationTitle(reservation),
                    style: _nunito(size: 15, weight: FontWeight.w800, color: _titleDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pickupPublicLocationLine(
                      reservation,
                      productPublicLocation: productPublicLocation,
                    ),
                    style: _nunito(size: 14, weight: FontWeight.w600, color: _bodyGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!reservation.addressRevealed) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: locationTextInset),
            child: Text(
              'Your exact address is shared after booking is confirmed.',
              style: _nunito(
                size: 13,
                weight: FontWeight.w500,
                color: _labelGrey,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _scheduleTile({required String label, required String value}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.jebbyBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: _nunito(
                size: 13,
                weight: FontWeight.w700,
                color: _labelGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: _nunito(
            size: 14,
            weight: FontWeight.w700,
            color: _titleDark,
            height: 1.3,
          ),
        ),
      ],
    ),
  );
}

Widget _earningsCard({
  required Reservation reservation,
  required (String, String, String) earnings,
  required int feePercent,
  required int days,
  required num dailyRate,
}) {
  final (rentalLine, feeLine, estimatedLine) = earnings;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _earningsRow(
          label: 'Rental amount',
          value: rentalLine,
          subtitle: '${_formatMoney(dailyRate)} x $days days',
        ),
        const SizedBox(height: 12),
        _earningsRow(
          label: 'Jebby fee ($feePercent%)',
          value: feeLine,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, color: _cardBorder),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Estimated earnings',
                style: _nunito(size: 16, weight: FontWeight.w800, color: _titleDark),
              ),
            ),
            Text(
              estimatedLine,
              style: _nunito(size: 18, weight: FontWeight.w800, color: _titleDark),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'The $feePercent% fee applies to the rental amount.',
          style: _nunito(
            size: 13,
            weight: FontWeight.w600,
            color: _labelGrey,
            height: 1.35,
          ),
        ),
        Text(
          'Renter service fees and tax are excluded.',
          style: _nunito(
            size: 13,
            weight: FontWeight.w600,
            color: _labelGrey,
            height: 1.35,
          ),
        )
      ],
    ),
  );
}

Widget _earningsRow({
  required String label,
  required String value,
  String? subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: _nunito(size: 15, weight: FontWeight.w600, color: _bodyGrey),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: _nunito(size: 13, weight: FontWeight.w600, color: _labelGrey),
              ),
            ],
          ],
        ),
      ),
      Text(
        value,
        style: _nunito(size: 16, weight: FontWeight.w700, color: _titleDark),
      ),
    ],
  );
}

Widget _securityHoldBanner(Reservation reservation) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.jebbySoftBlue,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: AppColors.jebbyBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Security hold',
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w800,
                        color: _titleDark,
                      ),
                    ),
                  ),
                  Text(
                    _formatMoney(reservation.securityDeposit),
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w800,
                      color: _titleDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Placed at handoff. Not included in your earnings.',
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: _bodyGrey,
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
