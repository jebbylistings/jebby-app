import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/get_all_products_by_vendor_id_model.dart' as vendor_products;
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';
import 'package:jebby/views/screens/vendors/product_details.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/utils/listing_publish_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user_model.dart';
import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/order_status.dart';
import '../../../view_models/user_view_model.dart';

enum _ListingFilter { all, rented, drafts }

class _DraftListingPreview {
  const _DraftListingPreview({
    required this.name,
    required this.price,
    this.imagePath,
  });

  final String name;
  final String price;
  final String? imagePath;
}

class MyProductsScreen extends StatefulWidget {
  final side;
  const MyProductsScreen({Key? key, required this.side}) : super(key: key);

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  _ListingFilter _selectedFilter = _ListingFilter.all;

  bool emptyData = false;
  bool isLoading = true;
  bool isError = false;

  Set<int> _rentedProductIds = {};
  _DraftListingPreview? _draftListing;

  String? id;
  var profile = <dynamic>[];

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

  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData(BuildContext context) {
    getUserDate()
        .then((value) async {
          final userId = value.id.toString();
          id = userId;
          getVendorProducts(userId);
          getProductsApi(userId);
          loadRentedProductIds(userId);
          await _loadDraftListing();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  Future<void> getProductsApi(String userId) async {
    final body = await ApiRepository.shared.fetchUserProfileBody(userId);
    if (body == null) return;
    if (mounted) {
      setState(() {
        profile = body['data'] ?? [];
      });
    }
  }

  void getVendorProducts(String? userId) {
    if (userId == null || userId.isEmpty) return;
    ApiRepository.shared.getAllVendorProductsByID(
      (list) {
        if (!mounted) return;
        setState(() {
          emptyData = list.data == null || list.data!.isEmpty;
          isLoading = false;
          isError = false;
        });
      },
      (error) {
        if (error != null && mounted) {
          setState(() {
            isLoading = true;
            isError = true;
          });
        }
      },
      userId,
    );
  }

  void loadRentedProductIds(String userId) {
    ApiRepository.shared.getVenodorOrders(
      userId,
      (list) {
        if (!mounted) return;
        final rented = <int>{};
        for (final order in list.data ?? []) {
          if (OrderStatus.isListingRented(order.orderStatus)) {
            final productId = order.productId;
            if (productId != null) rented.add(productId);
          }
        }
        setState(() => _rentedProductIds = rented);
      },
      (error) {},
    );
  }

  Future<void> _loadDraftListing() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('listing_draft_active') != true) {
      if (mounted) setState(() => _draftListing = null);
      return;
    }

    final name = prefs.getString('listing_draft_product')?.trim() ?? 'Untitled draft';
    final price = prefs.getString('listing_draft_rent')?.trim() ?? '0';
    final paths = prefs.getStringList('listing_draft_images') ?? [];
    final imagePath = paths.isNotEmpty ? paths.first : null;

    if (!mounted) return;
    setState(() {
      _draftListing = _DraftListingPreview(
        name: name,
        price: price,
        imagePath: imagePath,
      );
    });
  }

  List<vendor_products.Data> get _allProducts {
    final products =
        ApiRepository.shared.vendorProductsByIdList?.data ?? <vendor_products.Data>[];
    final sorted = List<vendor_products.Data>.from(products);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  bool _isRented(vendor_products.Data product) {
    return _rentedProductIds.contains(product.id);
  }

  List<vendor_products.Data> get _visibleProducts {
    Iterable<vendor_products.Data> items = _allProducts;

    switch (_selectedFilter) {
      case _ListingFilter.rented:
        items = items.where(_isRented);
        break;
      case _ListingFilter.drafts:
        items = items.where(ListingPublishState.isDraftListing);
        break;
      case _ListingFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((product) {
        final name = (product.name ?? '').toString().toLowerCase();
        return name.contains(_searchQuery);
      });
    }

    return items.toList();
  }

  int get _localDraftCount => _draftListing == null ? 0 : 1;

  int get _allCount => _allProducts.length + _localDraftCount;
  int get _rentedCount => _allProducts.where(_isRented).length;
  int get _serverDraftCount =>
      _allProducts.where(ListingPublishState.isDraftListing).length;

  int get _draftCount => _localDraftCount + _serverDraftCount;

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  void _openDraftListing() {
    Get.to(() => const CreateListingScreen(popToProductsOnBack: true));
  }

  int _gridItemCount({
    required bool showDraftOnly,
    required List<vendor_products.Data> products,
  }) {
    if (showDraftOnly) return _draftCount;
    return products.length +
        (_selectedFilter == _ListingFilter.all ? _localDraftCount : 0);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final showDraftOnly = _selectedFilter == _ListingFilter.drafts;
    final visibleProducts = _visibleProducts;
    final gridItemCount = _gridItemCount(
      showDraftOnly: showDraftOnly,
      products: visibleProducts,
    );
    final showEmpty = !isLoading && !isError && gridItemCount == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _pageHeader(),
              const SizedBox(height: 20),
              _searchBar(),
              const SizedBox(height: 14),
              _filterChips(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Newest first',
                      style: _nunito(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.jebbyTextMuted.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isError
                    ? Center(
                        child: Text(
                          'Error loading data',
                          style: _nunito(
                            size: 15,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                          ),
                        ),
                      )
                    : isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.jebbyBlue,
                          strokeWidth: 2.4,
                        ),
                      )
                    : showEmpty
                    ? Center(
                        child: Text(
                          showDraftOnly ? 'No drafts yet' : 'No listings found',
                          style: _nunito(
                            size: 15,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                          ),
                        ),
                      )
                    : _buildGrid(
                        showDraftOnly: showDraftOnly,
                        products: visibleProducts,
                        bottomInset: bottomInset,
                        itemCount: gridItemCount,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  'My listings',
                  style: _nunito(
                    size: 28,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage and edit your items.',
                  style: _nunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.2,
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

  Widget _searchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 22, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              style: _nunito(size: 15, weight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search your listings',
                hintStyle: _nunito(
                  size: 15,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted.withValues(alpha: 0.75),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Row(
      children: [
        Expanded(
          child: _filterChip(
            label: 'All ($_allCount)',
            selected: _selectedFilter == _ListingFilter.all,
            onTap: () => setState(() => _selectedFilter = _ListingFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterChip(
            label: 'Rented ($_rentedCount)',
            selected: _selectedFilter == _ListingFilter.rented,
            onTap: () => setState(() => _selectedFilter = _ListingFilter.rented),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterChip(
            label: 'Drafts ($_draftCount)',
            selected: _selectedFilter == _ListingFilter.drafts,
            onTap: () => setState(() => _selectedFilter = _ListingFilter.drafts),
          ),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.jebbyBlue : AppColors.jebbySoftBlue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _nunito(
                size: 14,
                weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.jebbyTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid({
    required bool showDraftOnly,
    required List<vendor_products.Data> products,
    required double bottomInset,
    required int itemCount,
  }) {
    return GridView.builder(
      padding: EdgeInsets.only(bottom: bottomInset + 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        mainAxisExtent: _listingCardHeight,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final showLocalDraftFirst = _draftListing != null &&
            (showDraftOnly || _selectedFilter == _ListingFilter.all);
        if (showLocalDraftFirst && index == 0) {
          return _draftListingCard(_draftListing!);
        }

        final productIndex = showLocalDraftFirst ? index - 1 : index;
        final product = products[productIndex];
        return _listingCard(product);
      },
    );
  }

  static const double _cardImageHeight = 118;
  static const double _listingCardHeight = 236;

  Widget _listingCard(vendor_products.Data product) {
    final rented = _isRented(product);
    final isDraft = ListingPublishState.isDraftListing(product);
    final imageUrl = AppUrl.baseUrlM + (product.image ?? '').toString();

    void openListing() {
      if (isDraft) {
        Get.to(
          () => CreateListingScreen(
            editProductId: product.id?.toString(),
            popToProductsOnBack: true,
          ),
        );
        return;
      }
      Get.to(() => VendorProductDetailScreen(id: product.id));
    }

    return _listingCardShell(
      onTap: openListing,
      image: _listingImage(
        imageUrl: imageUrl,
        badge: _statusBadge(rented: rented, product: product),
      ),
      name: product.name?.toString() ?? 'Listing',
      price: '${product.price ?? 0}',
      onEdit: openListing,
    );
  }

  Widget _draftListingCard(_DraftListingPreview draft) {
    return _listingCardShell(
      onTap: _openDraftListing,
      image: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: draft.imagePath != null &&
                    draft.imagePath!.isNotEmpty &&
                    File(draft.imagePath!).existsSync()
                ? Image.file(
                    File(draft.imagePath!),
                    height: _cardImageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _draftImagePlaceholder(),
                  )
                : _draftImagePlaceholder(),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: _statusBadge(rented: false, isDraft: true),
          ),
        ],
      ),
      name: draft.name,
      price: draft.price,
      onEdit: _openDraftListing,
    );
  }

  Widget _listingCardShell({
    required VoidCallback onTap,
    required Widget image,
    required String name,
    required String price,
    required VoidCallback onEdit,
  }) {
    return SizedBox(
      height: _listingCardHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
          highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.04),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8EAEE)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _nunito(
                          size: 16,
                          weight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: _nunito(
                            size: 16,
                            weight: FontWeight.w800,
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(text: '\$$price'),
                            TextSpan(
                              text: '/day',
                              style: _nunito(
                                size: 13,
                                weight: FontWeight.w600,
                                color: AppColors.jebbyTextMuted,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _editListingButton(onTap: onEdit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listingImage({
    required String imageUrl,
    required Widget badge,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: _cardImageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: _cardImageHeight,
              color: AppColors.jebbySoftBlue,
            ),
            errorWidget: (_, __, ___) => Container(
              height: _cardImageHeight,
              color: AppColors.jebbySoftBlue,
              child: const Icon(Icons.image_outlined, color: AppColors.jebbyBlue),
            ),
          ),
        ),
        Positioned(left: 8, bottom: 8, child: badge),
      ],
    );
  }

  Widget _draftImagePlaceholder() {
    return Container(
      height: _cardImageHeight,
      width: double.infinity,
      color: AppColors.jebbySoftBlue,
      child: const Icon(Icons.image_outlined, color: AppColors.jebbyBlue),
    );
  }

  Widget _statusBadge({
    required bool rented,
    bool isDraft = false,
    vendor_products.Data? product,
  }) {
    final label = isDraft
        ? 'Draft'
        : (rented
            ? 'Rented'
            : (product != null
                ? ListingPublishState.badgeLabel(product)
                : 'Live'));
    final dotColor = isDraft
        ? AppColors.jebbyTextMuted
        : (rented ? AppColors.jebbyAccentOrange : AppColors.jebbyBlue);
    final background = rented && !isDraft
        ? AppColors.earnerOrangeSoft
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: _nunito(size: 12, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _editListingButton({required VoidCallback onTap}) {
    return Material(
      color: AppColors.jebbySoftBlue,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.14),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
        child: SizedBox(
          width: double.infinity,
          height: 36,
          child: Center(
            child: Text(
              'Edit listing',
              style: _nunito(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.jebbyBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
