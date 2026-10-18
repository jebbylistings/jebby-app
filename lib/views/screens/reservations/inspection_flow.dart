import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/inspection.dart';
import '../../../models/reservation.dart';
import '../../../constants/app_url.dart';
import '../../../constants/color.dart';
import '../../../utils/api_headers.dart';
import '../../../utils/inspection_roles.dart';
import '../../../utils/order_status.dart';
import '../../../utils/profile_image.dart';
import '../../../utils/api_datetime.dart';
import '../../../utils/rental_date.dart';
import '../../../utils/show_snackbar.dart';
import '../../../view_models/reservation_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../widgets/jebby_flow_back_button.dart';
import '../onboarding/onboarding_kit.dart';
import '../support/contact_support.dart';
import 'report_issue.dart';
import 'reservation_flow_theme.dart';

enum _FlowStep { inspect, review, confirm, waiting, waitingForInitiator, success }

TextStyle _inspectNunito({
  double? fontSize,
  double? size,
  FontWeight? fontWeight,
  FontWeight? weight,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSize ?? size,
    fontWeight: fontWeight ?? weight,
    color: color ?? AppColors.jebbyTextPrimary,
    height: height,
  );
}

TextStyle _inspectListingHeaderTitle() {
  return onboardingNunito(size: 22, weight: FontWeight.w800, height: 1.15);
}

TextStyle _inspectListingHeaderSubtitle() {
  return onboardingNunito(
    size: 14,
    weight: FontWeight.w600,
    color: AppColors.jebbyTextMuted,
    height: 1.35,
  );
}

/// Scrolls only when [children] exceed the viewport (unlike [ListView] in [Expanded]).
Widget _inspectionStepScroll({
  required EdgeInsetsGeometry padding,
  required List<Widget> children,
}) {
  return SingleChildScrollView(
    padding: padding,
    physics: const ClampingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

class InspectionFlowScreen extends StatefulWidget {
  final int orderId;
  final String phase;

  const InspectionFlowScreen({super.key, required this.orderId, required this.phase});

  @override
  State<InspectionFlowScreen> createState() => _InspectionFlowScreenState();
}

class _InspectionFlowScreenState extends State<InspectionFlowScreen> {
  static const _titleDark = Color(0xFF1A1A1A);
  static const _labelGrey = Color(0xFF6B7280);
  static const _cardBorder = Color(0xFFE8E8EC);
  static const _maxInspectionPhotos = 3;
  static const _statusWaitingAsset = 'assets/images/status-waiting.png';
  static const _confirmConditionAsset = 'assets/images/confirm-condition.png';
  static const _waitingOtherPartyPickupAsset = 'assets/images/waiting-other-party.png';
  static const _waitingOtherPartyReturnAsset = 'assets/images/waiting-other-party-2.png';
  static const _listingSuccessAsset = 'assets/images/listing-success.png';

  late ReservationFlowTheme _theme;
  _FlowStep _step = _FlowStep.inspect;
  bool _ready = false;
  final List<File> _pendingPhotos = [];
  final Map<String, bool> _checked = {};
  bool _busy = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _theme = ReservationFlowTheme(widget.phase);
    final vm = context.read<ReservationViewModel>();
    if (vm.reservation?.id != widget.orderId) {
      vm.beginOrderLoad(widget.orderId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final vm = context.read<ReservationViewModel>();
    if (vm.reservation?.id != widget.orderId) {
      await vm.loadReservation(widget.orderId);
    } else {
      await vm.refreshProductDescription();
    }
    if (!mounted) return;
    await vm.prefetchTrust(widget.orderId, phase: widget.phase);
    if (!mounted) return;
    final role = vm.reservation?.role ?? vm.trustStatus?.role;
    final reservationAfterTrust = vm.reservation;
    if (reservationAfterTrust != null &&
        !OrderStatus.handoffReadyForInspection(
          orderStatus: reservationAfterTrust.orderStatus,
          handoffStatus: reservationAfterTrust.handoffStatus,
          phase: widget.phase,
        ) &&
        vm.trustStatus?.inspection == null) {
      final message = InspectionRoles.isInitiator(widget.phase, role)
          ? 'Confirm arrival on the reservation screen first.'
          : OrderStatus.handoffWaitingMessage(transportType: reservationAfterTrust.transportType);
      showAppErrorSnackbar(message);
      if (mounted) Get.back();
      return;
    }
    var step = _resolveStep(vm.trustStatus, role);
    if (step == _FlowStep.inspect &&
        vm.trustStatus?.inspection == null &&
        InspectionRoles.isInitiator(widget.phase, role)) {
      await vm.startInspection(widget.orderId, widget.phase);
      await vm.prefetchTrust(widget.orderId, phase: widget.phase);
      step = _resolveStep(vm.trustStatus, role);
    } else if (step == _FlowStep.review) {
      await vm.prefetchTrust(widget.orderId, phase: widget.phase);
    }
    if (!mounted) return;
    if (step == _FlowStep.success) {
      await vm.refreshProductDescription();
    }
    if (!mounted) return;
    _seedChecklist(vm.trustStatus);
    setState(() {
      _step = step;
      _ready = true;
    });
  }

  int _photoCount() => _pendingPhotos.length;

  bool get _canAddPhoto => _photoCount() < _maxInspectionPhotos;

  /// Pop first so navigation feels instant; refresh reservation + home card in background.
  void _popAndRefreshReservation(ReservationViewModel vm) {
    Get.back();
    vm.loadReservation(widget.orderId);
    vm.loadActionRequired();
  }

  bool _checklistSubmitted(TrustStatus? trust) {
    if (trust == null || trust.inspection == null) {
      return false;
    }
    return trust.inspectionChecklistItems.every(
      (item) => trust.responses.any((r) => r.itemKey == item.key && r.response == 'yes'),
    );
  }

  _FlowStep _resolveStep(TrustStatus? trust, String? role) {
    if (trust?.bothConfirmed == true) return _FlowStep.success;
    if (trust?.myConfirmation != null && trust?.otherConfirmation == null) {
      return _FlowStep.waiting;
    }

    final initiator = InspectionRoles.isInitiator(widget.phase, role);

    if (!initiator) {
      if (trust?.inspection == null || !_checklistSubmitted(trust)) {
        return _FlowStep.waitingForInitiator;
      }
      if (trust?.otherConfirmation?.isConfirmed != true) {
        return _FlowStep.waitingForInitiator;
      }
      if (trust?.myConfirmation == null) {
        return _FlowStep.review;
      }
      return _FlowStep.waiting;
    }

    if (trust?.inspection != null) {
      if (_checklistSubmitted(trust) && trust?.myConfirmation == null) {
        return _FlowStep.confirm;
      }
      return _FlowStep.inspect;
    }

    return _FlowStep.inspect;
  }

  void _seedChecklist(TrustStatus? trust) {
    if (trust == null) return;
    for (final item in trust.inspectionChecklistItems) {
      OrderInspectionChecklistResponse? existing;
      for (final response in trust.responses) {
        if (response.itemKey == item.key) {
          existing = response;
          break;
        }
      }
      _checked[item.key] = existing?.response == 'yes';
    }
  }

  @override
  Widget build(BuildContext context) {
    const usesFlowHeader = true;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      appBar: null,
      body: SafeArea(
        child: Consumer<ReservationViewModel>(
        builder: (context, vm, _) {
          final forThisOrder = vm.reservation?.id == widget.orderId;
          if (!_ready || !forThisOrder) {
            return Center(child: CircularProgressIndicator(color: _theme.accent));
          }
          final reservation = vm.reservation;
          if (reservation == null) {
            return Center(
              child: Text(
                vm.error ?? 'Unable to load reservation',
                style: _inspectListingHeaderSubtitle(),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usesFlowHeader) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: _step == _FlowStep.success
                      ? _rentalSuccessPageHeader(isReturn: widget.phase == 'return')
                      : _inspectionFlowPageHeader(),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: _cardBorder),
              ],
              Expanded(child: _buildStepBody(context, vm, reservation)),
              if (_step == _FlowStep.waiting)
                _waitingForOtherPartyBottomBar(vm)
              else if (_step == _FlowStep.success)
                _rentalSuccessBottomBar(vm)
              else if (_step != _FlowStep.waitingForInitiator)
                _buildBottomBar(context, vm, reservation),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildStepBody(BuildContext context, ReservationViewModel vm, Reservation reservation) {
    switch (_step) {
      case _FlowStep.inspect:
        return _inspectStep(vm, readOnly: false);
      case _FlowStep.review:
        return _inspectStep(vm, readOnly: true);
      case _FlowStep.confirm:
        return _confirmStep(reservation);
      case _FlowStep.waiting:
        return _waitingStep(vm, reservation);
      case _FlowStep.waitingForInitiator:
        return _waitingForInitiatorStep(vm);
      case _FlowStep.success:
        return _successStep(reservation, vm);
    }
  }

  Widget _rentalSuccessPageHeader({required bool isReturn}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReturn ? 'Rental Complete' : 'Pickup is complete',
          style: _inspectListingHeaderTitle(),
        ),
        const SizedBox(height: 4),
        Text(
          isReturn
              ? 'Both of you have confirmed the return.'
              : 'Your rental period has officially begun.',
          style: _inspectListingHeaderSubtitle(),
        ),
      ],
    );
  }

  Widget _inspectionFlowPageHeader() {
    final String title;
    final String subtitle;
    if (_step == _FlowStep.waiting) {
      title = 'Waiting for Other Party';
      subtitle = widget.phase == 'return'
          ? 'Waiting for the other party to confirm return.'
          : 'Waiting for the other party to confirm pickup.';
    } else if (_step == _FlowStep.review) {
      title = widget.phase == 'return' ? 'Review Return' : 'Review Pickup';
      subtitle = InspectionRoles.reviewSubtitle(widget.phase);
    } else if (_step == _FlowStep.confirm) {
      title = widget.phase == 'return'
          ? 'Confirm Return Condition'
          : 'Confirm Item Condition';
      subtitle = widget.phase == 'return'
          ? 'Confirm the item\'s condition after the rental.'
          : 'Confirm the item matches the listed condition.';
    } else {
      title = widget.phase == 'return' ? 'Return inspection' : 'Pickup inspection';
      subtitle = widget.phase == 'return'
          ? "Check the item's condition upon return."
          : "Check the item's condition before accepting.";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JebbyFlowBackButton(onTap: Get.back),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _inspectListingHeaderTitle()),
                const SizedBox(height: 4),
                Text(subtitle, style: _inspectListingHeaderSubtitle()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inspectionWaitingStatusCard({
    required String headline,
    required String body,
  }) {
    const headlineColor = Color(0xFF1A1C1E);
    const bodyColor = Color(0xFF707781);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.jebbySoftBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.jebbyBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  headline,
                  style: onboardingNunito(
                    size: 21,
                    weight: FontWeight.w800,
                    color: headlineColor,
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w400,
                    color: bodyColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            _statusWaitingAsset,
            width: 172,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshInspectionStatus(ReservationViewModel vm) async {
    if (_busy) return;
    setState(() => _busy = true);
    await vm.prefetchTrust(widget.orderId, phase: widget.phase);
    if (!mounted) return;
    final role = vm.reservation?.role ?? vm.trustStatus?.role;
    setState(() {
      _busy = false;
      _step = _resolveStep(vm.trustStatus, role);
    });
    _seedChecklist(vm.trustStatus);
  }

  Widget _waitingForInitiatorStep(ReservationViewModel vm) {
    final trust = vm.trustStatus;
    final checklistReady = trust != null && _checklistSubmitted(trust);
    final waitingForInitiatorConfirm =
        checklistReady && trust.otherConfirmation?.isConfirmed != true;

    final headline = waitingForInitiatorConfirm
        ? InspectionRoles.waitingForInitiatorConfirmationMessage(widget.phase)
        : InspectionRoles.waitingForInitiatorMessage(widget.phase);
    final body = waitingForInitiatorConfirm
        ? 'You’ll be notified when you can review and confirm.'
        : 'You’ll be notified when it’s ready to review.';

    return _inspectionStepScroll(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _inspectionWaitingStatusCard(headline: headline, body: body),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: _theme.primaryButton(),
            onPressed: _busy ? null : () => _refreshInspectionStatus(vm),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Refresh status'),
          ),
        ),
      ],
    );
  }

  int _checklistCompletedCount(List<InspectionChecklistItem> items) {
    var count = 0;
    for (final item in items) {
      if (_checked[item.key] == true) count++;
    }
    return count;
  }

  Widget _inspectStep(ReservationViewModel vm, {required bool readOnly}) {
    final trust = vm.trustStatus;
    final isReturn = widget.phase == 'return';
    final items = trust?.inspectionChecklistItems ??
        InspectionChecklistItem.templateForPhase(widget.phase);
    final completed = _checklistCompletedCount(items);
    final total = items.length;

    return _inspectionStepScroll(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Text(
          isReturn ? 'Check before you finish' : 'Inspection Checklist',
          style: onboardingNunito(
            size: 22,
            weight: FontWeight.w800,
            height: 1.15,
            color: isReturn ? AppColors.jebbyNavy : AppColors.jebbyTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          total == 0
              ? 'No checklist items'
              : completed == total
                  ? '$completed of $total completed successfully'
                  : '$completed of $total completed',
          style: onboardingNunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _checklistTile(item, readOnly: readOnly)),
        if (readOnly) ...[
          if ((trust?.media ?? []).isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Add photos (optional)',
              style: onboardingNunito(size: 16, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _SubmittedPhotoStrip(media: trust!.media),
          ],
        ] else ...[
          const SizedBox(height: 24),
          Text(
            'Add photos (optional)',
            style: onboardingNunito(size: 16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _inspectPhotoGrid(vm),
          const SizedBox(height: 16),
          _inspectPhotosInfoBanner(),
        ],
      ],
    );
  }

  Widget _inspectPhotosInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.jebbySoftBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: AppColors.jebbyBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Capture the items condition, including any existing damage',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistTile(InspectionChecklistItem item, {required bool readOnly}) {
    final checked = _checked[item.key] == true;
    const checkmarkGreen = Color(0xFF4DBB8E);
    const checkmarkCircleFill = Color(0xFFE6F4EA);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: readOnly ? null : () => setState(() => _checked[item.key] = !checked),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.displayLabel,
                style: onboardingNunito(
                  size: 15,
                  weight: FontWeight.w600,
                  color: widget.phase == 'return'
                      ? AppColors.jebbyNavy
                      : AppColors.jebbyTextPrimary,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (checked)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: checkmarkCircleFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: checkmarkGreen, size: 20),
              )
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _inspectPhotoGrid(ReservationViewModel vm) {
    const slotHeight = 104.0;
    const gap = 10.0;
    final children = <Widget>[];

    for (var i = 0; i < _pendingPhotos.length; i++) {
      final file = _pendingPhotos[i];
      children.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _maxInspectionPhotos - 1 ? gap : 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: _busy ? null : () => setState(() => _pendingPhotos.remove(file)),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_canAddPhoto) {
      children.add(
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _busy ? null : _pickPhoto,
              borderRadius: BorderRadius.circular(14),
              child: DottedBorder(
                color: AppColors.jebbyBlue,
                strokeWidth: 2,
                dashPattern: const [7, 5],
                borderType: BorderType.RRect,
                radius: const Radius.circular(14),
                child: Container(
                  height: slotHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.earnerInfoBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.jebbyBlue,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return SizedBox(
        height: slotHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : _pickPhoto,
            borderRadius: BorderRadius.circular(14),
            child: DottedBorder(
              color: AppColors.jebbyBlue,
              strokeWidth: 2,
              dashPattern: const [7, 5],
              borderType: BorderType.RRect,
              radius: const Radius.circular(14),
              child: Container(
                width: double.infinity,
                height: slotHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.earnerInfoBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.jebbyBlue,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: slotHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _confirmProductImage(String? productImagePath) {
    final imageUrl = reservationImageUrl(productImagePath);
    const successGreen = Color(0xFF22C55E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 2.15,
              child: imageUrl.isEmpty
                  ? ColoredBox(
                      color: const Color(0xFFF0F2F5),
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 48),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: const Color(0xFFF0F2F5),
                        child: Icon(Icons.chair_outlined, color: Colors.grey.shade500, size: 48),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: -22,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: successGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmStep(Reservation reservation) {
    return _inspectionStepScroll(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        _confirmProductImage(reservation.productImage),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              children: [
                Text(
                  'Everything look good?',
                  textAlign: TextAlign.center,
                  style: onboardingNunito(size: 22, weight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.phase == 'return'
                      ? "The item is in the same condition as at pickup and is fully working."
                      : "Confirm you're happy to accept the item in its current condition",
                  textAlign: TextAlign.center,
                  style: onboardingNunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Image.asset(
            _confirmConditionAsset,
            width: 280,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _waitingStep(ReservationViewModel vm, Reservation reservation) {
    final trust = vm.trustStatus;
    final myRole = trust?.role ?? reservation.role ?? 'renter';
    final myConfirmed = trust?.myConfirmation?.isConfirmed == true;
    final otherConfirmed = trust?.otherConfirmation?.isConfirmed == true;
    final user = context.watch<UserViewModel>();
    final isRenter = myRole == 'renter';
    final waitingPartyLabel = isRenter ? 'earner' : 'renter';
    final waitingHint = "You'll be notified when the $waitingPartyLabel confirms.";

    return _inspectionStepScroll(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Text(
          widget.phase == 'return' ? 'Awaiting Signoff' : 'Waiting for confirmation',
          style: onboardingNunito(
            size: 22,
            weight: FontWeight.w800,
            height: 1.15,
            color: widget.phase == 'return' ? AppColors.jebbyNavy : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.phase == 'return'
              ? 'The contract remains open until both parties sign off.'
              : 'Both parties must confirm to start the rental.',
          style: onboardingNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        _partyStatusCard(
          roleLabel: 'Renter',
          subtitle: isRenter ? '(You)' : _partyName(reservation.counterpartyName, fallback: 'Renter'),
          imagePath: isRenter ? user.profileImage : reservation.counterpartyImage,
          confirmed: isRenter ? myConfirmed : otherConfirmed,
        ),
        const SizedBox(height: 12),
        _partyStatusCard(
          roleLabel: 'Earner',
          subtitle: !isRenter ? '(You)' : _partyName(reservation.counterpartyName, fallback: 'Earner'),
          imagePath: !isRenter ? user.profileImage : reservation.counterpartyImage,
          confirmed: !isRenter ? myConfirmed : otherConfirmed,
        ),
        if (!otherConfirmed) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.earnerInfoBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.jebbySoftBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.jebbyBlue, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    waitingHint,
                    style: onboardingNunito(
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Center(
          child: Image.asset(
            widget.phase == 'return'
                ? _waitingOtherPartyReturnAsset
                : _waitingOtherPartyPickupAsset,
            width: 320,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _waitingForOtherPartyBottomBar(ReservationViewModel vm) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: _theme.primaryButton(),
            onPressed: () => _popAndRefreshReservation(vm),
            child: const Text('View Reservation'),
          ),
        ),
      ),
    );
  }

  Widget _partyStatusCard({
    required String roleLabel,
    required String subtitle,
    required String? imagePath,
    required bool confirmed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _partyProfileRow(
        roleLabel: roleLabel,
        subtitle: subtitle,
        imagePath: imagePath,
        confirmed: confirmed,
      ),
    );
  }

  String _partyName(String? name, {required String fallback}) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return fallback;
    return trimmed;
  }

  Widget _partyProfileRow({
    required String roleLabel,
    required String subtitle,
    required String? imagePath,
    required bool confirmed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ProfileImage.circularAvatar(
            radius: 24,
            baseUrl: AppUrl.baseUrlM,
            imagePath: imagePath,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabel,
                  style: _inspectNunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _titleDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: _inspectNunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _labelGrey,
                  ),
                ),
              ],
            ),
          ),
          if (confirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Confirmed',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pending...',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyAccentOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _successStep(Reservation reservation, ReservationViewModel vm) {
    final isReturn = widget.phase == 'return';
    final isEarner = reservation.role?.trim().toLowerCase() == 'earner';
    final heroTitle = isReturn ? 'Rental Complete!' : "You're all set";
    final heroSubtitle = isReturn
        ? (isEarner ? 'Thanks for hosting on Jebby!' : 'Thanks for renting from Jebby!')
        : 'Enjoy your rental!';
    final returnDateLabel = _formatReturnDateForSuccess(reservation);
    final locationLabel = _successLocationLabel(reservation);
    final productName = reservation.productName?.trim().isNotEmpty == true
        ? reservation.productName!.trim()
        : 'Rental item';
    final productMeta = _successProductMeta(reservation, vm);

    return _inspectionStepScroll(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Center(
          child: Image.asset(_listingSuccessAsset, width: 320, fit: BoxFit.contain),
        ),
        const SizedBox(height: 12),
        Text(
          heroTitle,
          textAlign: TextAlign.center,
          style: onboardingNunito(size: 22, weight: FontWeight.w800, height: 1.15),
        ),
        const SizedBox(height: 8),
        Text(
          heroSubtitle,
          textAlign: TextAlign.center,
          style: onboardingNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        _RentalSuccessDetailsCard(
          reservation: reservation,
          isReturn: isReturn,
          returnDateLabel: returnDateLabel,
          locationLabel: locationLabel,
          productName: productName,
          productMeta: productMeta,
        ),
        const SizedBox(height: 12),
        _rentalSuccessSupportCard(),
      ],
    );
  }

  String? _successProductMeta(Reservation reservation, ReservationViewModel vm) {
    final fromVm = vm.productDescription?.trim() ?? '';
    if (fromVm.isNotEmpty) return fromVm;
    final fromOrder = reservation.productDescription?.trim() ?? '';
    if (fromOrder.isNotEmpty) return fromOrder;
    return null;
  }

  String _successLocationLabel(Reservation reservation) {
    final loc = reservation.location?.trim() ?? '';
    if (loc.isNotEmpty && loc.toLowerCase() != 'null') {
      return loc;
    }
    return reservation.addressRevealed ? 'Address on file' : 'Location shared after booking';
  }

  Widget _rentalSuccessSupportCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => const ContactSupportScreen()),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.jebbySoftBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic_outlined, color: AppColors.jebbyBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need help?', style: onboardingNunito(size: 16, weight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        'Contact Jebby Support',
                        style: onboardingNunito(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rentalSuccessBottomBar(ReservationViewModel vm) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: _theme.primaryButton(),
            onPressed: () => _popAndRefreshReservation(vm),
            child: const Text('View Reservation'),
          ),
        ),
      ),
    );
  }

  String _formatReturnDateForSuccess(Reservation reservation) {
    final end = reservation.returnWindowEnd?.trim();
    if (end != null && end.isNotEmpty) {
      final dt = parseApiDateTime(end);
      if (dt != null) {
        return '${DateFormat('MMMM d, yyyy').format(dt)} at ${DateFormat('h:mm a').format(dt)}';
      }
    }
    final fallback = formatRentalDateForDisplay(reservation.rentalEndDate, pattern: 'MMMM d, yyyy');
    return fallback == '—' ? '—' : fallback;
  }

  Widget _buildBottomBar(BuildContext context, ReservationViewModel vm, Reservation reservation) {
    String label;
    VoidCallback? onPressed;

    switch (_step) {
      case _FlowStep.inspect:
        label = 'Continue';
        onPressed = _busy ? null : () => _continueFromInspect(vm);
        break;
      case _FlowStep.review:
        return _buildConfirmationActions(vm);
      case _FlowStep.confirm:
        return _buildConfirmationActions(vm);
      default:
        return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: _theme.primaryButton(),
            onPressed: onPressed,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationActions(ReservationViewModel vm) {
    final primaryLabel =
        _step == _FlowStep.confirm ? 'Confirm and Continue' : _theme.confirmButtonLabel;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: _theme.primaryButton(),
                onPressed: _busy ? null : () => _confirmCondition(vm),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(primaryLabel),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Material(
                color: AppColors.jebbySoftBlue,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _busy
                      ? null
                      : () => Get.to(
                            () => ReportIssueScreen(orderId: widget.orderId, phase: widget.phase),
                          ),
                  child: Center(
                    child: Text(
                      'Report an issue',
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (!_canAddPhoto) {
      showAppErrorSnackbar('You can add up to $_maxInspectionPhotos photos.');
      return;
    }

    const source = ImageSource.camera;
    XFile? image;
    try {
      image = await _picker.pickImage(source: source, imageQuality: 85);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final cameraUnavailable = e.code == 'camera_access_denied' ||
          e.code == 'camera_unavailable' ||
          e.message?.toLowerCase().contains('camera') == true;
      if (cameraUnavailable) {
        showAppErrorSnackbar('Camera unavailable. Please check camera permissions and try again.');
      } else {
        showAppErrorSnackbar('Unable to add photo. Please try again.');
      }
      return;
    }

    if (image == null || !mounted) return;
    final picked = File(image.path);
    setState(() => _pendingPhotos.add(picked));
  }

  Future<void> _continueFromInspect(ReservationViewModel vm) async {
    final trust = vm.trustStatus;
    if (trust == null) return;
    final allChecked =
        trust.inspectionChecklistItems.every((item) => _checked[item.key] == true);
    if (!allChecked) {
      showAppErrorSnackbar(
        'Please review every checklist item.',
        title: 'Required',
      );
      return;
    }

    setState(() => _busy = true);
    for (final file in List<File>.from(_pendingPhotos)) {
      final uploaded = await vm.uploadInspectionPhoto(widget.orderId, widget.phase, file);
      if (!uploaded) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      _pendingPhotos.remove(file);
    }
    final responses = trust.inspectionChecklistItems
        .map(
          (item) => InspectionResponse(
            itemKey: item.key,
            response: _checked[item.key] == true ? 'yes' : 'no',
          ),
        )
        .toList();
    final saved = await vm.saveChecklist(widget.orderId, widget.phase, responses);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (saved) {
        _step = _FlowStep.confirm;
      }
    });
  }

  Future<void> _confirmCondition(ReservationViewModel vm) async {
    if (_busy) return;
    setState(() => _busy = true);
    await WidgetsBinding.instance.endOfFrame;

    final ok = await vm.confirmInspection(widget.orderId, widget.phase);
    if (!mounted) return;

    if (!ok) {
      setState(() => _busy = false);
      final message = vm.error?.replaceFirst('Exception: ', '').trim();
      showAppErrorSnackbar(
        (message != null && message.isNotEmpty)
            ? message
            : 'Unable to confirm condition. Please try again.',
      );
      return;
    }

    final role = vm.reservation?.role ?? vm.trustStatus?.role;
    setState(() {
      _busy = false;
      _step = _resolveStep(vm.trustStatus, role);
    });
  }
}

String _inspectionMediaUrl(OrderInspectionMedia item) {
  final signed = item.signedUrl?.trim() ?? '';
  if (signed.isNotEmpty) {
    if (signed.toLowerCase().startsWith('http')) return signed;
    return reservationImageUrl(signed);
  }
  return reservationImageUrl(item.filePath);
}

class _SubmittedPhotoStrip extends StatefulWidget {
  final List<OrderInspectionMedia> media;

  const _SubmittedPhotoStrip({required this.media});

  @override
  State<_SubmittedPhotoStrip> createState() => _SubmittedPhotoStripState();
}

class _SubmittedPhotoStripState extends State<_SubmittedPhotoStrip> {
  Map<String, String>? _headers;

  @override
  void initState() {
    super.initState();
    ApiHeaders.authOnly().then((headers) {
      if (mounted) setState(() => _headers = headers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: widget.media.map((item) {
            final url = _inspectionMediaUrl(item);
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildThumb(url),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildThumb(String url) {
    if (url.isEmpty) {
      return _thumbPlaceholder(Icons.image_not_supported_outlined);
    }
    if (_headers == null) {
      return _thumbPlaceholder(null, loading: true);
    }
    return Image.network(
      url,
      width: 88,
      height: 88,
      fit: BoxFit.cover,
      headers: _headers,
      errorBuilder: (_, __, ___) => _thumbPlaceholder(Icons.broken_image_outlined),
    );
  }

  Widget _thumbPlaceholder(IconData? icon, {bool loading = false}) {
    return Container(
      width: 88,
      height: 88,
      color: Colors.grey.shade200,
      child: loading
          ? const Padding(
              padding: EdgeInsets.all(28),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: const Color(0xFF6B7280)),
    );
  }
}

class _RentalSuccessDetailsCard extends StatelessWidget {
  final Reservation reservation;
  final bool isReturn;
  final String returnDateLabel;
  final String locationLabel;
  final String productName;
  final String? productMeta;

  const _RentalSuccessDetailsCard({
    required this.reservation,
    required this.isReturn,
    required this.returnDateLabel,
    required this.locationLabel,
    required this.productName,
    this.productMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isReturn)
            Text(
              'Rental Details',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.jebbyTextMuted,
              ).copyWith(letterSpacing: 0.6),
            ),
          if (!isReturn) const SizedBox(height: 14),
          _productSummaryRow(),
          if (isReturn) ...[
            _returnCompleteStatusRow(
              'Security hold',
              _securityHoldSuccessLabel(reservation),
            ),
            _returnCompleteStatusRow(
              'Payout',
              _payoutSuccessLabel(reservation),
            ),
          ] else ...[
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SuccessDetailIcon(icon: Icons.calendar_today_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Return date:', style: onboardingNunito(size: 14, weight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        returnDateLabel,
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
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SuccessDetailIcon(icon: Icons.location_on_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: onboardingNunito(
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _productThumb() {
    final path = reservation.productImage?.trim() ?? '';
    final url = ProfileImage.resolveUrl(AppUrl.baseUrlM, path);
    if (url == null) {
      return ColoredBox(
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 28),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => ColoredBox(
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 28),
      ),
    );
  }

  Widget _productSummaryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 56, height: 56, child: _productThumb()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: onboardingNunito(size: 16, weight: FontWeight.w800, height: 1.25),
              ),
              if (productMeta != null && productMeta!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  productMeta!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _securityHoldSuccessLabel(Reservation reservation) {
    final status = reservation.depositRefundStatus?.trim().toLowerCase() ?? '';
    switch (status) {
      case 'refunded':
        return 'Released';
      case 'withheld':
        return 'Under review';
      case 'failed':
        return 'Processing';
      default:
        return 'Released';
    }
  }

  static String _payoutSuccessLabel(Reservation reservation) {
    final role = reservation.role?.trim().toLowerCase();
    final status = reservation.payoutStatus?.trim().toLowerCase() ?? '';
    if (status == 'released' || status == 'paid' || status == 'completed') {
      return role == 'earner' ? 'Sent to you' : 'Sent to Earner';
    }
    if (status == 'pending' || status.isEmpty) {
      return role == 'earner' ? 'Processing' : 'Sent to Earner';
    }
    return role == 'earner' ? 'Sent to you' : 'Sent to Earner';
  }

  static const _returnStatusPillWidth = 132.0;

  Widget _returnCompleteStatusRow(String label, String pillText) {
    const pillBg = Color(0xFFDCFCE7);
    const pillFg = Color(0xFF16A34A);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: onboardingNunito(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
          ),
          Container(
            width: _returnStatusPillWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pillText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: onboardingNunito(size: 13, weight: FontWeight.w700, color: pillFg),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDetailIcon extends StatelessWidget {
  final IconData icon;

  const _SuccessDetailIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.jebbySoftBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.jebbyBlue, size: 20),
    );
  }
}
