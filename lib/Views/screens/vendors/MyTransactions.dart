import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/Views/screens/auth/stripe_onboarding.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';

class TransactionListScreen extends StatefulWidget {
  TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with WidgetsBindingObserver {
  static const Color _pageBg = Color(0xFFF3F3F5);
  static const Color _subtitleGrey = Color(0xFF72747A);

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;
  bool isAccountLoading = false;
  String? accountStatus;
  Map<String, dynamic>? accountDetails;

  getNewOrders() {
    ApiRepository.shared.getVenodorOrders(
      sourceId,
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isLoading = false;
              isEmpty = true;
              isError = false;
            });
          } else {
            setState(() {
              isLoading = false;
              isError = false;
              isEmpty = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      },
    );
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
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          getNewOrders();
          checkStripeAccountStatus();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  void checkStripeAccountStatus() {
    if (sourceId.isEmpty) {
      return; // Don't check if sourceId is not available yet
    }

    setState(() {
      isAccountLoading = true;
    });

    ApiRepository.shared.checkStripeAccountStatus(
      sourceId,
      (data) {
        if (this.mounted) {
          setState(() {
            isAccountLoading = false;
            accountStatus = data['status'];
            accountDetails = data['account'];
          });
        }
      },
      (error) {
        if (this.mounted) {
          setState(() {
            isAccountLoading = false;
            accountStatus = 'error';
          });
        }
      },
    );
  }

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
      getNewOrders();
      checkStripeAccountStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      Theme.of(context).textTheme.apply(
        bodyColor: const Color(0xFF1A1A1A),
        displayColor: const Color(0xFF1A1A1A),
      ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
            style: IconButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Transactions',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'View payout history and manage your Stripe Express account.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _subtitleGrey,
                ),
              ),
              const SizedBox(height: 20),
              accountSection(),
              const SizedBox(height: 20),
              Text(
                'Recent activity',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildTransactionBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionBody() {
    if (isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Could not load transactions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: _subtitleGrey),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  isError = false;
                  isEmpty = false;
                });
                getNewOrders();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _subtitleGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: _subtitleGrey),
            ),
          ],
        ),
      );
    }

    final raw = ApiRepository.shared.getAllOrdersByVenodrIdList?.data ?? [];
    final visible = raw.where((e) => e.cancelDate.toString().isEmpty).toList();

    if (visible.isEmpty) {
      return Center(
        child: Text(
          'No active transactions',
          style: GoogleFonts.inter(fontSize: 15, color: _subtitleGrey),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final data = visible[index];
        return _transactionCard(
          data.name.toString(),
          data.totalPrice.toString(),
          data.email.toString(),
          data.negoPrice.toString(),
        );
      },
    );
  }

  Widget _transactionCard(
    String name,
    String price,
    String email,
    String negoPrice,
  ) {
    final amount = negoPrice != '0' ? negoPrice : price;
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: AppColors.primaryColor.withValues(alpha: 0.85),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9A9AA1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '\$$amount',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget accountSection() {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Stripe Express account',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isAccountLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Checking account status…',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _subtitleGrey,
                      ),
                    ),
                  ],
                ),
              )
            else if (accountStatus == 'not_started' || accountStatus == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Account Not Set Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set up your Stripe Express account to receive payments and manage your business.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _subtitleGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Get.to(
                        () => StripeOnboardingScreen(
                          userId: sourceId,
                          isFromTransactions: true,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Set up account',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else if (accountStatus == 'pending')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Account Pending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your account is being reviewed. This usually takes 1-2 business days.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _subtitleGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Get.to(
                        () => StripeOnboardingScreen(
                          userId: sourceId,
                          isFromTransactions: true,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Complete setup',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else if (accountStatus == 'active')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Account Active',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (accountDetails != null) ...[
                    Text(
                      'Account ID: ${accountDetails!['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Charges Enabled: ${accountDetails!['charges_enabled'] ? 'Yes' : 'No'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Payouts Enabled: ${accountDetails!['payouts_enabled'] ? 'Yes' : 'No'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      _showAccountDetailsModal();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Manage account',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else if (accountStatus == 'failed')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Account Setup Failed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'There was an issue with your account setup. Please try again.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _subtitleGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Get.to(
                        () => StripeOnboardingScreen(
                          userId: sourceId,
                          isFromTransactions: true,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Try again',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showAccountDetailsModal() {
    final maxH = MediaQuery.of(context).size.height * 0.78;
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
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: AppColors.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Stripe account',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
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
                                color: _subtitleGrey,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              'Account status',
                              'Active',
                              Icons.verified_outlined,
                              valueGood: true,
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
                                Icons.account_balance_wallet_outlined,
                                valueGood:
                                    accountDetails!['payouts_enabled'] == true,
                                valueBad:
                                    accountDetails!['payouts_enabled'] != true,
                              ),
                              const SizedBox(height: 16),
                              _buildBalanceSection(),
                              const SizedBox(height: 16),
                            ],
                            if (accountDetails != null &&
                                accountDetails!['requirements'] != null) ...[
                              Text(
                                'Requirements',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _subtitleGrey,
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
                              'Express',
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
                      color: _subtitleGrey,
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
    final titleColor = isPastDue ? _modalValueBad : _subtitleGrey;

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
                                color: _subtitleGrey,
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

  Widget _buildBalanceSection() {
    // Extract balance data from accountDetails
    Map<String, dynamic>? balance = accountDetails?['balance'];
    List<dynamic>? available = balance?['available'];
    List<dynamic>? pending = balance?['pending'];

    // Calculate totals
    double availableTotal = 0.0;
    double pendingTotal = 0.0;
    String currency = 'USD';

    if (available != null) {
      for (var item in available) {
        availableTotal += (item['amount'] ?? 0) / 100.0; // Convert from cents
        currency = item['currency'] ?? 'USD';
      }
    }

    if (pending != null) {
      for (var item in pending) {
        pendingTotal += (item['amount'] ?? 0) / 100.0; // Convert from cents
      }
    }

    double totalBalance = availableTotal + pendingTotal;
    final currencyUpper = currency.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balances',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _subtitleGrey,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        'Available',
                        '\$${availableTotal.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBalanceItem(
                        'Pending',
                        '\$${pendingTotal.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        'Total',
                        '\$${totalBalance.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBalanceItem('Currency', currencyUpper),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _subtitleGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
