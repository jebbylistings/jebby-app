import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/get_all_orders_by_vendor_id_model.dart'
    as vendor_orders;
import 'package:jebby/models/stripe_transactions_model.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/vendors/stripe_requirements_modal.dart';
import 'package:provider/provider.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/order_status.dart';
import '../../../models/user_model.dart';
import '../../../view_models/user_view_model.dart';

class VendorMyTransactionsScreen extends StatefulWidget {
  const VendorMyTransactionsScreen({super.key});

  @override
  State<VendorMyTransactionsScreen> createState() => _VendorMyTransactionsScreenState();
}

class _VendorMyTransactionsScreenState extends State<VendorMyTransactionsScreen>
    with WidgetsBindingObserver {
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _refundGreen = Color(0xFF16A34A);
  static const Color _refundGreenSoft = Color(0xFFDCFCE7);

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;
  bool isAccountLoading = true;
  String? accountStatus;
  String? accountMessage;
  Map<String, dynamic>? accountDetails;
  bool _identityVerified = false;
  bool _payoutsEnabled = false;
  bool _payoutInReview = false;
  String? _stripeBankLast4;

  List<_EarnerTransactionRow> _transactions = [];

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

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  BoxDecoration _surfaceCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _cardBorder),
    );
  }

  List<_EarnerTransactionRow> get _displayTransactions {
    if (_transactions.isNotEmpty) return _transactions;
    final cached = ApiRepository.shared.stripeTransactionsModelList?.data;
    if (cached == null || cached.isEmpty) return const [];
    return cached.map(_rowFromStripe).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _hasNoVisibleTransactions() =>
      isEmpty || _displayTransactions.isEmpty;

  void getEarnerTransactions() {
    if (sourceId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isEmpty = true;
          _transactions = [];
        });
      }
      return;
    }

    var ordersLoaded = false;
    var stripeLoaded = false;
    var ordersFailed = false;
    var stripeFailed = false;
    List<_EarnerTransactionRow> fromOrders = [];
    List<_EarnerTransactionRow> fromStripe = [];

    void finishIfReady() {
      if (!ordersLoaded || !stripeLoaded || !mounted) return;

      final stripeRows =
          fromStripe.isNotEmpty ? fromStripe : _stripeRowsFromRepository();
      final merged = _mergeEarnerTransactionRows(stripeRows, fromOrders);
      merged.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        isLoading = false;
        isError = merged.isEmpty && ordersFailed && stripeFailed;
        isEmpty = merged.isEmpty;
        _transactions = merged;
      });
    }

    ApiRepository.shared.getVenodorOrders(
      sourceId,
      (list) {
        fromOrders = (list.data ?? [])
            .where((o) => _vendorOrderVisible(o.orderStatus))
            .map(_rowFromVendorOrder)
            .toList();
        ordersLoaded = true;
        finishIfReady();
      },
      (error) {
        ordersFailed = error != null;
        ordersLoaded = true;
        finishIfReady();
      },
    );

    ApiRepository.shared.getUserStripeTransactions(
      sourceId,
      (StripeTransactionsModel data) {
        fromStripe = _stripeRowsFromModel(data);
        stripeLoaded = true;
        finishIfReady();
      },
      (error) {
        stripeFailed = error != null;
        fromStripe = _stripeRowsFromRepository();
        stripeLoaded = true;
        finishIfReady();
      },
    );
  }

  List<_EarnerTransactionRow> _stripeRowsFromModel(StripeTransactionsModel data) {
    final rows = (data.data ?? []).map(_rowFromStripe).toList();
    if (rows.isNotEmpty) return rows;
    return _stripeRowsFromRepository();
  }

  List<_EarnerTransactionRow> _stripeRowsFromRepository() {
    final cached = ApiRepository.shared.stripeTransactionsModelList?.data ?? [];
    return cached.map(_rowFromStripe).toList();
  }

  bool _vendorOrderVisible(String? status) =>
      OrderStatus.showOnEarnerTransactionsList(status);

  DateTime? _orderDate(vendor_orders.Data order) {
    for (final raw in [
      order.completedAt,
      order.updatedAt,
      order.createdAt,
    ]) {
      if (raw == null || raw.trim().isEmpty) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return null;
  }

  _EarnerTransactionRow _rowFromVendorOrder(vendor_orders.Data order) {
    final title = order.productName?.trim().isNotEmpty == true
        ? order.productName!.trim()
        : 'Rental payment';
    final normalized = OrderStatus.normalize(order.orderStatus);
    final paid = normalized != OrderStatus.accepted &&
        normalized != OrderStatus.bookingRequested;
    return _EarnerTransactionRow(
      key: 'order-${order.id}',
      title: title,
      date: _orderDate(order) ?? DateTime.now(),
      amount: (order.totalPrice ?? 0).toDouble(),
      refunded: OrderStatus.isCancelled(order.orderStatus),
      paid: paid,
      paymentLabel: 'Card',
      orderId: order.id,
    );
  }

  _EarnerTransactionRow _rowFromStripe(StripeTransactionData tx) {
    final title = tx.productName?.trim().isNotEmpty == true
        ? tx.productName!.trim()
        : 'Rental payment';
    final orderPart = tx.orderId?.toString() ?? '';
    final idPart = tx.id?.trim() ?? '';
    final key = idPart.isNotEmpty
        ? 'stripe-$idPart'
        : orderPart.isNotEmpty
            ? 'stripe-order-$orderPart'
            : 'stripe-${title.hashCode}-${_transactionDate(tx)?.millisecondsSinceEpoch ?? 0}';

    return _EarnerTransactionRow(
      key: key,
      title: title,
      date: _transactionDate(tx) ?? DateTime.now(),
      amount: _transactionAmount(tx).abs(),
      refunded: _isRefunded(tx),
      paid: !_isRefunded(tx),
      paymentLabel: _paymentMethodLabel(tx),
      orderId: tx.orderId,
    );
  }

  List<_EarnerTransactionRow> _mergeEarnerTransactionRows(
    List<_EarnerTransactionRow> stripe,
    List<_EarnerTransactionRow> orders,
  ) {
    final merged = <_EarnerTransactionRow>[];
    final seenOrderIds = <int>{};
    final seenKeys = <String>{};

    void addRow(_EarnerTransactionRow row) {
      if (!seenKeys.add(row.key)) return;
      if (row.orderId != null) seenOrderIds.add(row.orderId!);
      merged.add(row);
    }

    for (final row in orders) {
      addRow(row);
    }
    for (final row in stripe) {
      if (row.orderId != null && seenOrderIds.contains(row.orderId)) continue;
      addRow(row);
    }

    return merged;
  }

  double _transactionAmount(StripeTransactionData tx) {
    if (tx.amount != null) return tx.amount!;
    if (tx.totalPrice != null) return tx.totalPrice!.toDouble();
    return 0;
  }

  DateTime? _transactionDate(StripeTransactionData tx) {
    if (tx.created != null) return tx.created;
    final raw = tx.createdAt?.trim();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool _isRefunded(StripeTransactionData tx) {
    final status = (tx.status ?? '').toLowerCase();
    if (status.contains('refund')) return true;
    return _transactionAmount(tx) < 0;
  }

  String _paymentMethodLabel(StripeTransactionData tx) {
    final types = tx.paymentMethodTypes;
    if (types == null || types.isEmpty) return 'Card';
    final type = types.first.toLowerCase();
    switch (type) {
      case 'card':
        return 'Card';
      case 'link':
        return 'Link';
      default:
        if (type.isEmpty) return 'Card';
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          if (!mounted) return;
          setState(() {
            isLoading = true;
            isAccountLoading = true;
          });
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          await _prepareOnboardingController();
          if (!mounted) return;
          getEarnerTransactions();
          checkStripeAccountStatus();
        })
        .onError((error, stackTrace) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            isAccountLoading = false;
            isError = true;
          });
          if (kDebugMode) {}
        });
  }

  void _applyStripeStatusResponse(Map<String, dynamic> data) {
    final rawStatus = data['status']?.toString().trim();
    accountStatus = (rawStatus == null || rawStatus.isEmpty) ? null : rawStatus;
    accountMessage = data['message']?.toString();

    Map<String, dynamic> account = {};
    if (data['account'] is Map) {
      account = Map<String, dynamic>.from(data['account'] as Map);
    } else {
      if (data['account_id'] != null) account['id'] = data['account_id'];
      if (data['charges_enabled'] != null) {
        account['charges_enabled'] = data['charges_enabled'];
      }
      if (data['payouts_enabled'] != null) {
        account['payouts_enabled'] = data['payouts_enabled'];
      }
      if (data['details_submitted'] != null) {
        account['details_submitted'] = data['details_submitted'];
      }
      if (data['type'] != null) account['type'] = data['type'];
      if (data['balance'] != null) account['balance'] = data['balance'];
    }

    if (data['requirements'] is Map) {
      account['requirements'] = data['requirements'];
    } else if (account['requirements'] == null &&
        data['account'] is Map &&
        (data['account'] as Map)['requirements'] is Map) {
      account['requirements'] = (data['account'] as Map)['requirements'];
    }

    accountDetails = account.isEmpty ? null : account;

    final dueKeys = StripeRequirementFields.collectDueKeys(
      data['requirements'] is Map
          ? Map<String, dynamic>.from(data['requirements'] as Map)
          : account['requirements'] is Map
              ? Map<String, dynamic>.from(account['requirements'] as Map)
              : null,
    );
    final requirementsForReview = data['requirements'] is Map
        ? Map<String, dynamic>.from(data['requirements'] as Map)
        : account['requirements'] is Map
            ? Map<String, dynamic>.from(account['requirements'] as Map)
            : null;
    if (!StripeRequirementFields.isIdentityPendingReview(requirementsForReview)) {
      _identityVerified = data['identity_verified'] == true ||
          rawStatus == 'active' ||
          (account['details_submitted'] == true &&
              rawStatus != 'requires_info') ||
          (rawStatus == 'requires_info' &&
              StripeRequirementFields.isBankOnlyRequirements(dueKeys));
    } else {
      _identityVerified = false;
    }
    _payoutsEnabled =
        StripeRequirementFields.payoutSetupCompleteForBookings(data);
    _payoutInReview = !_payoutsEnabled &&
        StripeRequirementFields.shouldShowPayoutInReview(data);
    final last4 = data['bank_last4']?.toString().trim();
    if (last4 != null && last4.isNotEmpty) {
      _stripeBankLast4 = last4;
    }
  }

  Future<void> _prepareOnboardingController() async {
    if (sourceId.isEmpty) return;
    final controller = ensureOnboardingController();
    if (controller.userId.isEmpty || controller.userId != sourceId) {
      await controller.loadAndReconcile(
        userId: sourceId,
        name: fullname,
        email: email,
      );
    } else {
      await controller.refreshStripeStatus();
    }
    if (!mounted) return;
    setState(() => _syncOnboardingFlagsFromController(controller));
  }

  void _syncOnboardingFlagsFromController(OnboardingController controller) {
    _payoutsEnabled = controller.payoutsEnabled;
    final lastResponse = controller.lastStripeStatusResponse;
    if (lastResponse != null) {
      _payoutInReview = !_payoutsEnabled &&
          StripeRequirementFields.shouldShowPayoutInReview(lastResponse);
    } else {
      _payoutInReview = false;
    }
    if (controller.state.isIdentityComplete) {
      _identityVerified = true;
    }
    final last4 = controller.bankLast4?.trim();
    if (last4 != null && last4.isNotEmpty) {
      _stripeBankLast4 = last4;
    }
  }

  Future<void> _showRequirementsModal() async {
    if (!_hasActionableRequirements() || _isPendingStripeReview()) return;

    if (_requirementsAreBankOnly()) {
      await _openPayoutSetupFromRequirements();
      return;
    }

    final requirements = _accountRequirements;
    if (requirements == null) return;

    await _prepareOnboardingController();
    if (!mounted) return;

    await StripeRequirementsModal.show(
      context,
      userId: sourceId,
      requirements: requirements,
      message: accountMessage,
      onSubmitted: checkStripeAccountStatus,
    );
  }

  Future<void> _openPayoutSetupFromRequirements() async {
    await _prepareOnboardingController();
    if (!mounted) return;
    final controller = ensureOnboardingController();
    controller.cacheStripeRequirements(_accountRequirements);
    controller.navigateToPayoutMethod(fromTransactions: true);
  }

  bool _requirementsAreBankOnly() {
    final dueKeys =
        StripeRequirementFields.collectDueKeys(_accountRequirements);
    return StripeRequirementFields.isBankOnlyRequirements(dueKeys);
  }

  Future<void> _openProviderOnboarding({bool openReview = false}) async {
    await _prepareOnboardingController();
    final controller = ensureOnboardingController();

    if (_payoutsEnabled && openReview) {
      _showAccountDetailsModal();
      return;
    }

    if (!_identityVerified ||
        accountStatus == 'not_started' ||
        accountStatus == null) {
      await controller.startOrResume();
      return;
    }

    if (accountStatus == 'requires_info' && !_payoutsEnabled) {
      if (controller.state.identityStatus == IdentityStatus.actionNeeded &&
          controller.shouldPromptIdentityActionScreen()) {
        controller.navigateToIdentityHub();
        return;
      }
      controller.navigateToPayoutMethod(fromTransactions: true);
      return;
    }

    if (!_payoutsEnabled) {
      controller.navigateToPayoutMethod(fromTransactions: true);
      return;
    }

    _showAccountDetailsModal();
  }

  Future<void> _openFinishPayoutSetup() async {
    await _prepareOnboardingController();
    if (!mounted) return;
    final controller = ensureOnboardingController();
    if (_accountRequirements != null) {
      controller.cacheStripeRequirements(_accountRequirements);
    }
    controller.navigateToPayoutMethod(fromTransactions: true);
  }

  String _accountStatusHeadline(String status) {
    switch (status) {
      case 'active':
        return 'Account active';
      case 'pending':
        return 'Account pending';
      case 'requires_info':
        return 'Action required';
      case 'not_started':
        return 'Account not set up';
      case 'failed':
      case 'failure':
        return 'Setup failed';
      case 'error':
        return 'Could not load account';
      default:
        return 'Account status';
    }
  }

  String _accountTypeLabel() {
    final type = accountDetails?['type']?.toString().toLowerCase() ?? '';
    if (type == 'custom') return 'Custom';
    if (type == 'express') return 'Express';
    if (type == 'standard') return 'Standard';
    return 'Connect';
  }

  bool _requirementListHasItems(dynamic value) {
    return value is List && value.isNotEmpty;
  }

  Map<String, dynamic>? get _accountRequirements {
    final requirements = accountDetails?['requirements'];
    return requirements is Map ? Map<String, dynamic>.from(requirements) : null;
  }

  bool _hasActionableRequirements() {
    final requirements = _accountRequirements;
    if (requirements == null) return false;

    if (_requirementListHasItems(requirements['currently_due']) ||
        _requirementListHasItems(requirements['past_due'])) {
      return true;
    }

    return requirements['disabled_reason'] != null;
  }

  bool _isPendingStripeReview() {
    if (accountStatus == 'pending') return true;

    final requirements = _accountRequirements;
    if (requirements == null) return false;

    return _requirementListHasItems(requirements['pending_verification']) &&
        !_hasActionableRequirements();
  }

  bool _hasOutstandingRequirements() => _hasActionableRequirements();

  Widget _buildAccountActionButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = AppColors.jebbyBlue,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: _nunito(size: 15, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  void checkStripeAccountStatus() {
    if (sourceId.isEmpty) {
      if (mounted) {
        setState(() => isAccountLoading = false);
      }
      return;
    }

    setState(() {
      isAccountLoading = true;
      accountMessage = null;
    });

    ApiRepository.shared.checkStripeAccountStatus(
      sourceId,
      (data) {
        if (this.mounted) {
          setState(() {
            isAccountLoading = false;
            if (data is Map<String, dynamic>) {
              _applyStripeStatusResponse(data);
              if (sourceId.isNotEmpty) {
                final controller = ensureOnboardingController();
                controller.userId = sourceId;
                controller.applyStripeAccountStatus(data);
                _syncOnboardingFlagsFromController(controller);
              }
            } else if (data is Map) {
              final map = Map<String, dynamic>.from(data);
              _applyStripeStatusResponse(map);
              if (sourceId.isNotEmpty) {
                final controller = ensureOnboardingController();
                controller.userId = sourceId;
                controller.applyStripeAccountStatus(map);
                _syncOnboardingFlagsFromController(controller);
              }
            } else {
              accountStatus = 'error';
              accountDetails = null;
            }
          });
        }
      },
      (error) {
        if (this.mounted) {
          setState(() {
            isAccountLoading = false;
            accountStatus = 'error';
            accountMessage = error?.toString();
            accountDetails = null;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getData();
    profileData(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app becomes active (e.g., returning from onboarding)
    if (state == AppLifecycleState.resumed && sourceId.isNotEmpty) {
      setState(() {
        isLoading = true;
        isAccountLoading = true;
      });
      getEarnerTransactions();
      checkStripeAccountStatus();
    }
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep track of your earnings and transactions.',
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

  Widget _backButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleBack,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyTransactionsState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                constraints.maxHeight * 0.08,
                24,
                24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.jebbySoftBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 32,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No transactions yet',
                    textAlign: TextAlign.center,
                    style: _nunito(
                      size: 18,
                      weight: FontWeight.w800,
                      color: AppColors.jebbyTextPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your rentals and payouts will appear here after setup is complete.',
                    textAlign: TextAlign.center,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pageHeader(),
                    const SizedBox(height: 20),
                    accountSection(),
                    if (_showPublishedListingsInfoBelowCards()) ...[
                      const SizedBox(height: 12),
                      _buildListingsVisibleInfo(),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: _buildTransactionSliver(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSliver() {
    if (isError) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Could not load transactions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 15, color: AppColors.jebbyTextMuted),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      isError = false;
                      isEmpty = false;
                    });
                    getEarnerTransactions();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.jebbyBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: _nunito(size: 15, weight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.jebbyBlue,
              strokeWidth: 2.4,
            ),
          ),
        ),
      );
    }
    if (_hasNoVisibleTransactions()) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 320,
          child: _emptyTransactionsState(),
        ),
      );
    }

    final items = List<_EarnerTransactionRow>.from(_displayTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <DateTime, List<_EarnerTransactionRow>>{};
    for (final tx in items) {
      final key = DateTime(tx.date.year, tx.date.month);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final monthKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final monthKey = monthKeys[index];
          final monthLabel = DateFormat('MMMM yyyy').format(monthKey);
          final monthItems = grouped[monthKey]!;
          return _monthTransactionSection(monthLabel, monthItems);
        },
        childCount: monthKeys.length,
      ),
    );
  }

  Widget _monthTransactionSection(
    String monthLabel,
    List<_EarnerTransactionRow> items,
  ) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              monthLabel,
              style: _nunito(size: 17, weight: FontWeight.w800, height: 1.2),
            ),
          ),
          Container(
            decoration: _surfaceCardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: _cardBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                  _earnerTransactionRow(items[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
    );
  }

  Widget _earnerTransactionRow(_EarnerTransactionRow tx) {
    final refunded = tx.refunded;
    final date = tx.date;
    final amount = tx.amount;
    final title = tx.title;
    final subtitle =
        '${DateFormat('MMM d').format(date)} · ${tx.paymentLabel}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: refunded ? _refundGreenSoft : AppColors.jebbySoftBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              refunded ? Icons.replay_rounded : Icons.receipt_long_outlined,
              color: refunded ? _refundGreen : AppColors.jebbyBlue,
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
                  style: _nunito(size: 16, weight: FontWeight.w800, height: 1.25),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: _nunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: _nunito(size: 16, weight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                refunded
                    ? 'Refunded'
                    : tx.paid
                        ? 'Paid'
                        : 'Pending',
                style: _nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: refunded
                      ? _refundGreen
                      : tx.paid
                          ? AppColors.jebbyBlue
                          : AppColors.jebbyTextMuted,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _showPublishedListingsInfoBelowCards() =>
      _identityVerified && !_payoutsEnabled && !_payoutInReview;

  bool _bankAccountOnFile() {
    final last4 = _stripeBankLast4?.trim();
    if (last4 != null && last4.isNotEmpty) return true;
    if (!Get.isRegistered<OnboardingController>()) return false;
    final last4Cached = Get.find<OnboardingController>().bankLast4?.trim();
    return last4Cached != null && last4Cached.isNotEmpty;
  }

  Map<String, dynamic> _stripeStatusPayload() {
    return {
      'status': accountStatus ?? '',
      'payouts_enabled': accountDetails?['payouts_enabled'] == true,
      if (_stripeBankLast4 != null) 'bank_last4': _stripeBankLast4,
      if (accountDetails != null) 'account': accountDetails,
      if (_accountRequirements != null) 'requirements': _accountRequirements,
    };
  }

  bool _isPayoutInReview() {
    if (_payoutsEnabled) return false;
    if (_isPendingStripeReview()) return true;
    return _payoutInReview;
  }

  bool _shouldShowFinishPayoutSetupCard() {
    if (_payoutsEnabled || _isPayoutInReview()) return false;
    if (!_identityVerified) {
      return _hasOutstandingRequirements() && _requirementsAreBankOnly();
    }
    if (!_bankAccountOnFile()) return true;
    return _hasOutstandingRequirements() && _requirementsAreBankOnly();
  }

  Widget _buildListingsVisibleInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: AppColors.jebbyBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your published listings are visible. Complete payout setup so renters can book your items.',
            style: _nunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutInReviewCard() {
    final ending = _stripeBankLast4?.trim();
    final bankLine = ending != null && ending.isNotEmpty
        ? 'Account ending in $ending'
        : 'Bank account on file';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.jebbyBlue.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
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
                      'Payout setup in review',
                      style: _nunito(size: 17, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bankLine,
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Stripe is reviewing your bank details. Bookings open once payouts are enabled—we\'ll update this screen when that happens.',
            style: _nunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishPayoutSetupCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.jebbyBlue.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
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
                      'Lets finish your payouts setup',
                      style: _nunito(size: 17, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set up payouts.',
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _openFinishPayoutSetup,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.jebbyBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Finish payout setup',
                style: _nunito(
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget accountSection() {
    if (isAccountLoading) return const SizedBox.shrink();

    final children = <Widget>[];

    if (!_identityVerified &&
        (accountStatus == 'not_started' || accountStatus == null)) {
      children.add(
        _buildAccountActionButton(
          label: 'Verify identity to earn',
          onPressed: () => _openProviderOnboarding(),
        ),
      );
    }
    if (_shouldShowFinishPayoutSetupCard()) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));
      children.add(_buildFinishPayoutSetupCard());
    }
    if (_isPayoutInReview()) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));
      children.add(_buildPayoutInReviewCard());
    }
    if (_hasOutstandingRequirements() &&
        !_isPendingStripeReview() &&
        !_requirementsAreBankOnly()) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));
      children.add(
        _buildAccountActionButton(
          label: 'Submit required info',
          onPressed: _showRequirementsModal,
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _showAccountDetailsModal() {
    final maxH = MediaQuery.of(context).size.height * 0.78;
    final status = accountStatus ?? 'unknown';
    final statusLabel = _accountStatusHeadline(status);
    final statusGood = status == 'active';
    final statusBad =
        status == 'failed' ||
        status == 'failure' ||
        status == 'error' ||
        status == 'requires_info';
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 28,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: BoxConstraints(maxHeight: maxH, maxWidth: 400),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 8, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.jebbySoftBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: AppColors.jebbyBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Stripe account',
                            style: _nunito(
                              size: 22,
                              weight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  Flexible(
                    child: Container(
                      color: const Color(0xFFF3F3F5),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Details',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.jebbyTextMuted,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              'Account status',
                              statusLabel,
                              Icons.verified_outlined,
                              valueGood: statusGood,
                              valueBad: statusBad,
                            ),
                            const SizedBox(height: 10),
                            if (accountDetails != null) ...[
                              _buildDetailRow(
                                'Account ID',
                                accountDetails!['id'] ?? 'N/A',
                                Icons.tag_outlined,
                                isMonospace: true,
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                'Charges enabled',
                                accountDetails!['charges_enabled'] == true
                                    ? 'Yes'
                                    : 'No',
                                Icons.credit_card_outlined,
                                valueGood:
                                    accountDetails!['charges_enabled'] == true,
                                valueBad:
                                    accountDetails!['charges_enabled'] != true,
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                'Payouts enabled',
                                accountDetails!['payouts_enabled'] == true
                                    ? 'Yes'
                                    : 'No',
                                Icons.account_balance_outlined,
                                valueGood:
                                    accountDetails!['payouts_enabled'] == true,
                                valueBad:
                                    accountDetails!['payouts_enabled'] != true,
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (accountDetails != null &&
                                accountDetails!['requirements'] != null) ...[
                              Text(
                                'Requirements',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.jebbyTextMuted,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildRequirementsSection(
                                accountDetails!['requirements'],
                              ),
                              const SizedBox(height: 10),
                            ],
                            _buildDetailRow(
                              'Account type',
                              _accountTypeLabel(),
                              Icons.storefront_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const Color _modalValueGood = Color(0xFF2E7D32);
  static const Color _modalValueBad = Color(0xFFC62828);

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isMonospace = false,
    bool valueGood = false,
    bool valueBad = false,
  }) {
    final Color valueColor =
        valueBad
            ? _modalValueBad
            : valueGood
            ? _modalValueGood
            : Colors.black;

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF72747A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.jebbyTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style:
                        isMonospace
                            ? TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: valueColor,
                              fontFamily: 'monospace',
                            )
                            : GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: valueColor,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsSection(Map<String, dynamic> requirements) {
    List<Widget> requirementWidgets = [];

    if (requirements['currently_due'] != null) {
      requirementWidgets.add(
        _buildRequirementItem('Currently Due', requirements['currently_due']),
      );
    }
    if (requirements['eventually_due'] != null) {
      requirementWidgets.add(
        _buildRequirementItem('Eventually Due', requirements['eventually_due']),
      );
    }
    if (requirements['past_due'] != null) {
      requirementWidgets.add(
        _buildRequirementItem('Past Due', requirements['past_due']),
      );
    }
    if (requirements['pending_verification'] != null) {
      requirementWidgets.add(
        _buildRequirementItem(
          'Pending verification',
          requirements['pending_verification'],
        ),
      );
    }
    if (requirements['disabled_reason'] != null) {
      requirementWidgets.add(
        _buildRequirementItem(
          'Disabled Reason',
          requirements['disabled_reason'],
        ),
      );
    }

    return Column(children: requirementWidgets);
  }

  Widget _buildRequirementItem(String title, dynamic requirements) {
    if (requirements is List && requirements.isEmpty) {
      return const SizedBox.shrink();
    }

    final isPastDue = title == 'Past Due';
    final borderColor =
        isPastDue ? const Color(0xFFFFCDD2) : Colors.grey.shade300;
    final titleColor = isPastDue ? _modalValueBad : AppColors.jebbyTextMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              if (requirements is List)
                ...requirements
                    .map(
                      (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.jebbyTextMuted,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                req.toString().replaceAll('_', ' '),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF2A2A2E),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList()
              else
                Text(
                  requirements.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF2A2A2E),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

class _EarnerTransactionRow {
  const _EarnerTransactionRow({
    required this.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.refunded,
    required this.paid,
    required this.paymentLabel,
    this.orderId,
  });

  final String key;
  final String title;
  final DateTime date;
  final double amount;
  final bool refunded;
  final bool paid;
  final String paymentLabel;
  final int? orderId;
}
