import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/home/RentNow.dart';
import 'package:jebby/view_model/apiServices.dart';

import '../../../model/getProductsByProductId.dart';
import '../../../model/getUserCredentialModel.dart';
import '../../../res/app_url.dart';

class NegotiationScreen extends StatefulWidget {
  final dynamic prodId;
  final dynamic status;
  final dynamic price;
  final dynamic negoId;
  final dynamic userId;

  NegotiationScreen({
    this.prodId,
    this.status,
    this.price,
    this.negoId,
    this.userId,
  });

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  String originalPrice = '';
  String negMargin = '';
  String image = '';
  String name = '';

  String vendorId = '';
  String delivery_charges = '';
  String security_deposit = '';
  String vendorName = '';
  String vendorAddress = '';
  String cell = '';
  String vendorImage = '';
  String vendorBackImage = '';
  String pastart = '';
  String paend = '';
  String vendorAccountId = '';
  String vendorPPEmail = '';

  bool userLoader = true;
  bool userError = false;
  bool userEmpty = false;

  bool rentVisibility = false;

  static const Color _titleDark = Color(0xFF1B1B1F);
  static const Color _labelGrey = Color(0xFF72747A);

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  String _imagePathFromProduct(GetProductsByProductId list) {
    try {
      final data = list.data;
      if (data == null || data.isEmpty) return '';
      if (data.length > 1 &&
          data[1].images != null &&
          data[1].images!.isNotEmpty) {
        return data[1].images![0].path?.toString() ?? '';
      }
      if (data[0].images != null && data[0].images!.isNotEmpty) {
        return data[0].images![0].path?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  void getProduct() {
    ApiRepository.shared.getProductsById(
      (GetProductsByProductId list) {
        if (!mounted) return;
        if (list.data == null || list.data!.isEmpty) {
          setState(() {
            isLoading = false;
            isError = false;
            isEmpty = true;
          });
          return;
        }
        final d0 = list.data![0];
        final path = _imagePathFromProduct(list);
        setState(() {
          isLoading = false;
          isError = false;
          isEmpty = false;
          image = path;
          name = d0.name?.toString() ?? '';
          originalPrice = d0.price2?.toString() ?? '';
          negMargin = d0.negotiation?.toString() ?? '';
          pastart = d0.pastart?.toString() ?? '';
          paend = d0.paend?.toString() ?? '';
          vendorId = d0.userId?.toString() ?? '';
          delivery_charges = d0.delivery_charges?.toString() ?? '';
          security_deposit = d0.security_deposit?.toString() ?? '';
          rentVisibility = true;
        });
        getUserData(vendorId);
      },
      (error) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isError = true;
          isEmpty = false;
        });
      },
      widget.prodId.toString(),
    );
  }

  void getUserData(String id) {
    if (id.isEmpty) {
      setState(() {
        userLoader = false;
        userError = false;
        userEmpty = true;
        vendorName = 'Vendor';
      });
      return;
    }
    ApiRepository.shared.userCredential(
      (GetUserCredentialModel list) {
        if (!mounted) return;
        if (list.data == null || list.data!.isEmpty) {
          setState(() {
            userLoader = false;
            userError = false;
            userEmpty = true;
            vendorName = 'Vendor';
            vendorAddress = '';
            cell = '';
            vendorImage = '';
            vendorBackImage = '';
          });
          return;
        }
        final v = list.data![0];
        setState(() {
          userError = false;
          userLoader = false;
          userEmpty = false;
          vendorName = v.name?.toString() ?? 'Vendor';
          vendorAddress = v.address?.toString() ?? '';
          cell = v.number?.toString() ?? '';
          vendorImage = v.image?.toString() ?? '';
          vendorBackImage = v.backImage?.toString() ?? '';
          vendorAccountId = v.accountId?.toString() ?? '';
          vendorPPEmail = v.paypalEmail?.toString() ?? '';
        });
      },
      (error) {
        if (!mounted) return;
        setState(() {
          userError = true;
          userLoader = false;
          userEmpty = false;
          vendorName = 'Vendor';
          vendorAddress = '';
          cell = '';
          vendorImage = '';
          vendorBackImage = '';
        });
      },
      id,
    );
  }

  void _retry() {
    setState(() {
      isLoading = true;
      isError = false;
      isEmpty = false;
      userLoader = true;
      userError = false;
      userEmpty = false;
      rentVisibility = false;
    });
    getProduct();
  }

  bool get _statusApproved => widget.status == 1 || widget.status == '1';

  bool get _canOpenRent =>
      _statusApproved && rentVisibility && !userLoader && widget.prodId != null;

  TextStyle _appBarTitleStyle() {
    return GoogleFonts.inter(
      color: Colors.black87,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    );
  }

  void _openRentNow() {
    if (!_canOpenRent) return;
    Get.to(
      () => RentnowScreen(
        vendorName,
        vendorAddress,
        cell,
        vendorImage,
        vendorId,
        widget.prodId,
        pastart,
        paend,
        widget.price,
        vendorAccountId,
        vendorPPEmail,
        'nego',
        delivery_charges,
        security_deposit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text('Discount request', style: _appBarTitleStyle()),
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(50),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: kprimaryColor, strokeWidth: 2),
      );
    }
    if (isError) {
      return _messageState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: 'We could not load this request.',
        actionLabel: 'Try again',
        onAction: _retry,
      );
    }
    if (isEmpty) {
      return _messageState(
        icon: Icons.inventory_2_outlined,
        title: 'No product data',
        subtitle: 'This listing may have been removed.',
        actionLabel: 'Go back',
        onAction: () => Get.back(),
      );
    }

    final imageUrl = image.isNotEmpty ? AppUrl.baseUrlM + image : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child:
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => ColoredBox(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: kprimaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (_, __, ___) => ColoredBox(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                          )
                          : ColoredBox(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Text(
                    name.isEmpty ? 'Product' : name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _titleDark,
                      height: 1.25,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      _infoRow(
                        'Original price',
                        originalPrice.isEmpty ? '—' : '\$$originalPrice',
                      ),
                      _divider(),
                      _infoRow(
                        'Discount margin',
                        negMargin.isEmpty ? '—' : '$negMargin%',
                      ),
                      _divider(),
                      _infoRow('Your requested price', '\$${widget.price}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                  child: _buildStatusSection(),
                ),
                if (_statusApproved) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    child: _buildRentSection(),
                  ),
                ] else
                  const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    if (_statusApproved) {
      return _statusBanner(
        icon: Icons.check_circle_outline,
        text: 'This discount request was approved. You can continue to rent.',
        background: const Color(0xFFE8F5E9),
        foreground: const Color(0xFF2E7D32),
      );
    }
    return _statusBanner(
      icon: Icons.cancel_outlined,
      text: 'This discount request was not approved.',
      background: const Color(0xFFFFEBEE),
      foreground: const Color(0xFFC62828),
    );
  }

  Widget _buildRentSection() {
    if (userLoader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: kprimaryColor,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Loading vendor details…',
                style: GoogleFonts.inter(fontSize: 14, color: _labelGrey),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (userError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Vendor profile could not be loaded. You can still try to rent with default vendor info.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _labelGrey,
                height: 1.35,
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _canOpenRent ? _openRentNow : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Rent now',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _labelGrey,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _titleDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade200);
  }

  Widget _statusBanner({
    required IconData icon,
    required String text,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foreground,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _titleDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _labelGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
