import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/agreements/insuranceAndIndemnifications.dart';
import 'package:jebby/Views/screens/agreements/rentalAgreement.dart';
import 'package:jebby/Views/screens/agreements/termsAndConditions.dart';
import 'package:jebby/Views/screens/agreements/transportAndInstallationPolicy.dart';
import 'package:jebby/Views/screens/vendors/EditProduct.dart';
import 'package:jebby/Views/screens/vendors/reveiew.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/res/app_url.dart';

import '../../../view_model/apiServices.dart';

class ProductDetail2Screen extends StatefulWidget {
  final dynamic id;

  ProductDetail2Screen({this.id});

  @override
  State<ProductDetail2Screen> createState() => _ProductDetail2ScreenState();
}

class _ProductDetail2ScreenState extends State<ProductDetail2Screen> {
  static const Color _accent = Color(0xFFF6AE02);
  static const Color _pageBg = Color(0xFFF3F3F5);
  static const Color _labelGrey = Color(0xFF72747A);
  static const Color _bodyGrey = Color(0xFF6D6D75);
  static const Color _titleDark = Color(0xFF1B1B1F);

  final PageController _pageController = PageController();
  int _carouselIndex = 0;

  String dropdownValue = 'One';
  bool isLoading = true;
  bool isError = false;
  bool emptyProdData = false;
  bool relloading = true;
  bool relError = false;
  late var prodID;
  List imagesList = [];
  List imagesListID = [];
  List relProdArray = [];
  var categoryID = null;
  var subCategoryID = null;
  var name = null;
  var price = null;
  var specifications = null;
  var description = null;
  var negotiation = null;
  var product_id = null;
  var images = null;
  var imageID = null;
  var message = null;
  bool editVisibility = false;
  var length = "";
  var stars = "";
  var delivery_charges = null;

  @override
  void initState() {
    super.initState();
    getProducts(widget.id.toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void getProducts(id) {
    setState(() {
      isLoading = true;
      isError = false;
      emptyProdData = false;
      relloading = true;
      relError = false;
      imagesList = [];
      imagesListID = [];
      relProdArray = [];
    });

    ApiRepository.shared.getProductsById(
      (list) => {
        if (this.mounted)
          {
            if (list.data!.length == 0)
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  prodID =
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data![0]
                          .productId
                          .toString();
                }),
              }
            else
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  prodID =
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data![0]
                          .productId
                          .toString();
                }),
                for (
                  int i = 0;
                  i <
                      ApiRepository
                          .shared
                          .getProductsByIdList!
                          .data![1]
                          .images!
                          .length;
                  i++
                )
                  {
                    imagesList.add(
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data?[1]
                          .images?[i]
                          .path,
                    ),
                    imagesListID.add(
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data?[1]
                          .images?[i]
                          .id,
                    ),
                  },
                categoryID =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .categoryId,
                subCategoryID =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .subcategoryId,
                name = ApiRepository.shared.getProductsByIdList?.data![0].name,
                price =
                    ApiRepository.shared.getProductsByIdList!.data![0].price2
                        .toString(),
                specifications =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .specifications,
                description =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .serviceAgreements,
                negotiation =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .negotiation,
                product_id =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .productId,
                message =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .isMessage,
                length =
                    ApiRepository.shared.getProductsByIdList!.data![0].length
                        .toString(),
                stars =
                    ApiRepository.shared.getProductsByIdList!.data![0].stars
                        .toString(),
                delivery_charges =
                    ApiRepository
                        .shared
                        .getProductsByIdList!
                        .data![0]
                        .delivery_charges
                        .toString(),
                getRelProducts(),
                images = imagesList,
                imageID = imagesListID,
                setState(() {
                  editVisibility = true;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              isLoading = false;
              isError = true;
            }),
          },
      },
      id,
    );
  }

  void getRelProducts() {
    ApiRepository.shared.getRelatedProducts(
      (List) => {
        if (this.mounted)
          {
            if (List.data?.length == 0)
              {
                setState(() {
                  relloading = false;
                  relError = false;
                }),
              }
            else
              {
                setState(() {
                  relloading = false;
                  relError = false;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              isLoading = false;
              isError = true;
            }),
          },
      },
      ApiRepository.shared.getProductsByIdList?.data![0].productId.toString(),
    );
  }

  double get _avgRating =>
      double.tryParse(stars.toString())?.clamp(0, 5) ?? 0;

  int get _reviewCount => int.tryParse(length.toString()) ?? 0;

  List<MapEntry<String, String>> _parsedSpecs() {
    final raw = specifications?.toString() ?? '';
    final out = <MapEntry<String, String>>[];
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final idx = t.indexOf(':');
      if (idx > 0) {
        out.add(MapEntry(
          t.substring(0, idx).trim(),
          t.substring(idx + 1).trim(),
        ));
      }
    }
    if (out.isEmpty) {
      return const [
        MapEntry('Material', 'Wooden'),
        MapEntry('Condition', 'New'),
        MapEntry('Finish', 'Simple Finish'),
        MapEntry('Style', 'Minimal'),
      ];
    }
    return out;
  }

  List<double> _starBarWeights() {
    final r = _avgRating;
    return List.generate(5, (i) {
      final star = 5 - i;
      final d = (r - star).abs();
      return (1.0 - d / 4.5).clamp(0.12, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final specs = _parsedSpecs();
    final barWeights = _starBarWeights();
    final carouselCount = imagesList.isEmpty ? 1 : imagesList.length;

    return Scaffold(
      backgroundColor: _pageBg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Text(
                    'Error Loading Product',
                    style: GoogleFonts.inter(),
                  ),
                )
              : Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildImageHeader(height, carouselCount),
                        ),
                        SliverToBoxAdapter(
                          child: Transform.translate(
                            offset: const Offset(0, -22),
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 28, 20, 120),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: _titleDark,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: _avgRating,
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star_rounded,
                                            color: _accent,
                                          ),
                                          itemCount: 5,
                                          itemSize: 22,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rental Price',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: _labelGrey,
                                          ),
                                        ),
                                        Text(
                                          '€ $price',
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: _accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      description.toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: _bodyGrey,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade200),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Product Specifications',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: _titleDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...specs.map(
                                        (e) => _specDividerRow(e.key, e.value)),
                                    const SizedBox(height: 8),
                                    Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade200),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        initiallyExpanded: false,
                                        title: Text(
                                          'Service Agreements',
                                          style: GoogleFonts.inter(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: _titleDark,
                                          ),
                                        ),
                                        iconColor: _titleDark,
                                        collapsedIconColor: _titleDark,
                                        children: [
                                          _agreementRow(
                                            'Rental Agreement',
                                            () => Get.to(
                                                () => RentalAgreement()),
                                          ),
                                          _agreementRow(
                                            'Terms & Conditions',
                                            () => Get.to(
                                                () => TermsAndCondition()),
                                          ),
                                          _agreementRow(
                                            'Insurance & Indemnifications Policy',
                                            () => Get.to(() =>
                                                InsuranceAndIndemnification()),
                                          ),
                                          _agreementRow(
                                            'Transportation & Installation Policy',
                                            () => Get.to(() =>
                                                TransportAndInstallationPolicy()),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade200),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        initiallyExpanded: true,
                                        controlAffinity:
                                            ListTileControlAffinity.trailing,
                                        title: Text(
                                          'Ratings & Reviews',
                                          style: GoogleFonts.inter(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: _titleDark,
                                          ),
                                        ),
                                        iconColor: const Color(0xFFC4C4CC),
                                        collapsedIconColor:
                                            const Color(0xFFC4C4CC),
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            color: Colors.white,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 108,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            _avgRating
                                                                .toStringAsFixed(
                                                              _avgRating ==
                                                                      _avgRating
                                                                          .roundToDouble()
                                                                  ? 0
                                                                  : 2,
                                                            ),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 40,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  _titleDark,
                                                              height: 1,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            '$_reviewCount Reviews',
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  _labelGrey,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          RatingBarIndicator(
                                                            rating:
                                                                _avgRating,
                                                            itemCount: 5,
                                                            itemSize: 16,
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    const Icon(
                                                              Icons
                                                                  .star_rounded,
                                                              color: _accent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        children:
                                                            List.generate(
                                                                5, (i) {
                                                          final star = 5 - i;
                                                          final w =
                                                              barWeights[i];
                                                          final pct = (w * 100)
                                                              .round();
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                        8),
                                                            child: Row(
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      '$star',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color:
                                                                            _titleDark,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
                                                                    Icon(
                                                                      Icons
                                                                          .star_rounded,
                                                                      size:
                                                                          14,
                                                                      color:
                                                                          _accent,
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Expanded(
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            999),
                                                                    child:
                                                                        LinearProgressIndicator(
                                                                      value: w,
                                                                      minHeight:
                                                                          8,
                                                                      backgroundColor:
                                                                          Colors.grey.shade200,
                                                                      valueColor:
                                                                          const AlwaysStoppedAnimation<Color>(
                                                                        _accent,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                SizedBox(
                                                                  width: 38,
                                                                  child: Text(
                                                                    '$pct%',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight.w400,
                                                                      color:
                                                                          _labelGrey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: TextButton(
                                                    style:
                                                        TextButton.styleFrom(
                                                      backgroundColor:
                                                          _accent,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 28,
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(28),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (prodID != null &&
                                                          stars
                                                              .toString()
                                                              .isNotEmpty) {
                                                        Get.to(
                                                          () =>
                                                              VendorReviewScreen(
                                                            stars: stars,
                                                            reviewsLenght: length
                                                                .toString(),
                                                            prodID: prodID,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      'Read More',
                                                      style:
                                                          GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Material(
                        elevation: 12,
                        shadowColor: Colors.black26,
                        color: Colors.white,
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      ApiRepository.shared
                                          .deleteProductsById(prodID);
                                    },
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kprimaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => EditProductScreen(
                                          category_id: categoryID,
                                          sub_category_id: subCategoryID,
                                          name: name,
                                          price: price,
                                          specifications: specifications,
                                          description: description,
                                          negotiation: negotiation,
                                          product_id: product_id,
                                          relProd: [],
                                          images: images,
                                          imageID: imageID,
                                          messageStatus: message,
                                          delivery_charges: delivery_charges,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Edit Product',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildImageHeader(double screenHeight, int carouselCount) {
    final h = screenHeight * 0.36;
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemCount: carouselCount,
            itemBuilder: (context, index) {
              if (imagesList.isEmpty) {
                return ColoredBox(
                  color: Colors.grey.shade300,
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Colors.grey.shade600),
                );
              }
              return CachedNetworkImage(
                imageUrl: AppUrl.baseUrlM + imagesList[index].toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: h,
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.white.withOpacity(0.92),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 22),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(carouselCount, (i) {
                final active = _carouselIndex == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? _accent
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _specDividerRow(String title, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _labelGrey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _titleDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _agreementRow(String title, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _titleDark,
        ),
      ),
      trailing:
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade500),
      onTap: onTap,
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   double res_width = MediaQuery.of(context).size.width;
  //   double res_height = MediaQuery.of(context).size.height;
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       leading: InkWell(
  //         onTap: () {
  //           Get.back();
  //         },
  //         borderRadius: BorderRadius.circular(50),
  //         child: Icon(Icons.arrow_back, color: Colors.black),
  //       ),
  //     ),
  //     body:
  //         isLoading
  //             ? Center(child: CircularProgressIndicator())
  //             : isError
  //             ? Center(child: Text("Error In LoadingData"))
  //             : Center(
  //               child: Container(
  //                 width: double.infinity,
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         width: res_width * 0.9,
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             ApiRepository
  //                                         .shared
  //                                         .getProductsByIdList!
  //                                         .data![1]
  //                                         .images!
  //                                         .length >
  //                                     0
  //                                 ? SizedBox(
  //                                   height: 150,
  //                                   child: ListView.separated(
  //                                     scrollDirection: Axis.horizontal,
  //                                     shrinkWrap: true,
  //                                     separatorBuilder:
  //                                         (context, index) =>
  //                                             SizedBox(width: 10),
  //                                     // physics: NeverScrollableScrollPhysics(),
  //                                     itemCount:
  //                                         ApiRepository
  //                                             .shared
  //                                             .getProductsByIdList!
  //                                             .data![1]
  //                                             .images!
  //                                             .length,
  //                                     itemBuilder: (context, int index) {
  //                                       var img =
  //                                           ApiRepository
  //                                               .shared
  //                                               .getProductsByIdList
  //                                               ?.data?[1]
  //                                               .images?[index]
  //                                               .path;
  //                                       return Container(
  //                                         child: CachedNetworkImage(
  //                                           imageUrl:
  //                                               AppUrl.baseUrlM +
  //                                               img.toString(),
  //                                           fit: BoxFit.cover,
  //                                           placeholder:
  //                                               (context, url) => Center(
  //                                                 child:
  //                                                     CircularProgressIndicator(),
  //                                               ),
  //                                           errorWidget:
  //                                               (context, url, error) => Center(
  //                                                 child: Icon(
  //                                                   Icons.error,
  //                                                   color: Colors.red,
  //                                                 ),
  //                                               ),
  //                                         ),
  //                                       );
  //                                     },
  //                                   ),
  //                                 )
  //                                 : Text("No Images"),
  //
  //                             SizedBox(height: res_height * 0.03),
  //                             Container(
  //                               child: Column(
  //                                 children: [
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Text(
  //                                         ApiRepository
  //                                             .shared
  //                                             .getProductsByIdList!
  //                                             .data![0]
  //                                             .name
  //                                             .toString(),
  //                                         style: TextStyle(fontSize: 20),
  //                                       ),
  //                                       GestureDetector(
  //                                         onTap: () {
  //                                           if (length != "" &&
  //                                               prodID != null &&
  //                                               stars != "") {
  //                                             Get.to(
  //                                               () => VendorReviewScreen(
  //                                                 stars: stars,
  //                                                 reviewsLenght: length,
  //                                                 prodID: prodID,
  //                                               ),
  //                                             );
  //                                           }
  //                                         },
  //                                         child: Row(
  //                                           children: [
  //                                             RatingBarIndicator(
  //                                               rating: double.parse(
  //                                                 ApiRepository
  //                                                     .shared
  //                                                     .getProductsByIdList!
  //                                                     .data![0]
  //                                                     .stars
  //                                                     .toString(),
  //                                               ),
  //                                               itemBuilder:
  //                                                   (context, index) => Icon(
  //                                                     Icons.star,
  //                                                     color: Colors.amber,
  //                                                   ),
  //                                               itemCount: 5,
  //                                               itemSize: 15,
  //                                               direction: Axis.horizontal,
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Text(
  //                                         'Rental Price',
  //                                         style: TextStyle(fontSize: 15),
  //                                       ),
  //                                       Text(
  //                                         ApiRepository
  //                                             .shared
  //                                             .getProductsByIdList!
  //                                             .data![0]
  //                                             .price2
  //                                             .toString(),
  //                                         style: TextStyle(
  //                                           fontSize: 18,
  //                                           fontWeight: FontWeight.bold,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             Divider(color: Colors.grey, thickness: 0.5),
  //                             // GestureDetector(
  //                             //   // onTap: () {
  //                             //   //   Get.to(() => RenterScreen());
  //                             //   // },
  //                             //   child: Row(
  //                             //     children: [
  //                             //       Container(
  //                             //         height: res_height * 0.05,
  //                             //         width: res_width * 0.125,
  //                             //         child: Image.asset('assets/slicing/apple.png'),
  //                             //       ),
  //                             //       SizedBox(
  //                             //         width: 4,
  //                             //       ),
  //                             //       Text(
  //                             //         'Iphone Organization',
  //                             //         style: TextStyle(
  //                             //           fontSize: 17,
  //                             //           fontWeight: FontWeight.normal,
  //                             //         ),
  //                             //       ),
  //                             //     ],
  //                             //   ),
  //                             // ),
  //                             // Divider(
  //                             //   color: Colors.grey,
  //                             //   thickness: 0.5,
  //                             // ),
  //                             GFAccordion(
  //                               // titleBorderRadius: BorderRadius.circular(10),
  //                               contentBackgroundColor: Colors.transparent,
  //                               expandedTitleBackgroundColor:
  //                                   Colors.transparent,
  //                               // margin: EdgeInsets.zero,
  //                               // contentPadding: EdgeInsets.symmetric(vertical: 15),
  //                               collapsedTitleBackgroundColor:
  //                                   Colors.transparent,
  //                               showAccordion: false,
  //                               titleChild: Row(
  //                                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   // Image.asset(
  //                                   //   "assets/images/Icon feather-settings.png",
  //                                   //   scale: 5,
  //                                   // ),
  //                                   // SizedBox(
  //                                   //   width: 28,
  //                                   // ),
  //                                   Text(
  //                                     "Product Specifications",
  //                                     style: TextStyle(
  //                                       fontSize: 14,
  //                                       color: Colors.black,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //
  //                               // textStyle: TextStyle(color: Colors.amber, fontSize: 16),
  //                               collapsedIcon: Icon(
  //                                 Icons.arrow_drop_down_outlined,
  //                                 color: Colors.black,
  //                               ),
  //                               expandedIcon: Icon(
  //                                 Icons.arrow_drop_up_outlined,
  //                                 color: Colors.black,
  //                               ),
  //                               contentChild: Column(
  //                                 children: [
  //                                   Container(
  //                                     child: Text(
  //                                       ApiRepository
  //                                           .shared
  //                                           .getProductsByIdList!
  //                                           .data![0]
  //                                           .specifications
  //                                           .toString(),
  //                                       // "Dimensions: 146.7 x 71.5 x 7.7 mm 5.78 x 2.81 x 0.30 in\n\nWeight:     174 g 6.14 oz\n\nBuild:      Glass front (Corning-made glass)\n\nSIM:        Nano-SIM",
  //                                       style: TextStyle(
  //                                         color: Colors.grey,
  //                                         fontSize: 11,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //
  //                             // ),
  //                             Divider(color: Colors.grey, thickness: 0.5),
  //                             GFAccordion(
  //                               contentBackgroundColor: Colors.transparent,
  //                               expandedTitleBackgroundColor:
  //                                   Colors.transparent,
  //                               // margin: EdgeInsets.zero,
  //                               // contentPadding: EdgeInsets.symmetric(vertical: 15),
  //                               collapsedTitleBackgroundColor:
  //                                   Colors.transparent,
  //                               // collapsedTitleBackgroundColor: Color(0xffA0A1D6),
  //                               showAccordion: false,
  //
  //                               titleChild: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   // Image.asset(
  //                                   //   "assets/images/Icon feather-settings.png",
  //                                   //   scale: 5,
  //                                   // ),
  //                                   // SizedBox(
  //                                   //   width: 28,
  //                                   // ),
  //                                   Text(
  //                                     "Service & Agreements",
  //                                     style: TextStyle(
  //                                       fontSize: 14,
  //                                       color: Colors.black,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //
  //                               // textStyle: TextStyle(color: Colors.amber, fontSize: 16),
  //                               collapsedIcon: Icon(
  //                                 Icons.arrow_drop_down_outlined,
  //                                 color: Colors.black,
  //                               ),
  //
  //                               expandedIcon: Icon(
  //                                 Icons.arrow_drop_up_outlined,
  //                                 color: Colors.black,
  //                               ),
  //                               contentChild: Column(
  //                                 children: [
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       Get.to(() => RentalAgreement());
  //                                     },
  //                                     child: Container(
  //                                       width: 389,
  //                                       height: 50,
  //                                       // decoration: BoxDecoration(
  //                                       //   borderRadius: BorderRadius.circular(5),
  //                                       //   color: Color(0xffD2D2F1),
  //                                       // ),
  //                                       child: Padding(
  //                                         padding: const EdgeInsets.symmetric(
  //                                           horizontal: 20,
  //                                         ),
  //                                         child: Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.spaceBetween,
  //                                           children: [
  //                                             Text(
  //                                               "Rental Agreement",
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 color: Colors.blue,
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 389,
  //                                     height: 50,
  //                                     // decoration: BoxDecoration(
  //                                     //   borderRadius: BorderRadius.circular(5),
  //                                     //   color: Color(0xffD2D2F1),
  //                                     // ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                         horizontal: 20,
  //                                       ),
  //                                       child: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               Get.to(
  //                                                 () => TermsAndCondition(),
  //                                               );
  //                                             },
  //                                             child: Text(
  //                                               "Terms & Conditions",
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 color: Colors.blue,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 389,
  //                                     height: 50,
  //                                     // decoration: BoxDecoration(
  //                                     //   borderRadius: BorderRadius.circular(5),
  //                                     //   color: Color(0xffD2D2F1),
  //                                     // ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                         horizontal: 20,
  //                                       ),
  //                                       child: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               Get.to(
  //                                                 () =>
  //                                                     InsuranceAndIndemnification(),
  //                                               );
  //                                             },
  //                                             child: Text(
  //                                               "Insurance & Indemnifications Policy",
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 color: Colors.blue,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 389,
  //                                     height: 50,
  //                                     // decoration: BoxDecoration(
  //                                     //   borderRadius: BorderRadius.circular(5),
  //                                     //   color: Color(0xffD2D2F1),
  //                                     // ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(
  //                                         horizontal: 20,
  //                                       ),
  //                                       child: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           GestureDetector(
  //                                             onTap: () {
  //                                               Get.to(
  //                                                 () =>
  //                                                     TransportAndInstallationPolicy(),
  //                                               );
  //                                             },
  //                                             child: Text(
  //                                               "Transportation & Installation Policy",
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 color: Colors.blue,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //
  //                             Divider(color: Colors.grey, thickness: 0.5),
  //                             SizedBox(height: 7),
  //                             // Row(
  //                             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             //   children: [
  //                             //     Text(
  //                             //       'Question about this products (3)',
  //                             //       style: TextStyle(fontSize: 13, color: Colors.grey),
  //                             //     ),
  //                             //     Text(
  //                             //       'View all',
  //                             //       style: TextStyle(fontSize: 13, color: Colors.grey),
  //                             //     )
  //                             //   ],
  //                             // ),
  //                             // SizedBox(
  //                             //   height: 7,
  //                             // ),
  //                             // Row(
  //                             //   children: [
  //                             //     ImageIcon(
  //                             //       AssetImage('assets/slicing/questions.png'),
  //                             //     ),
  //                             //     SizedBox(
  //                             //       width: 10,
  //                             //     ),
  //                             //     Text(
  //                             //       'How soon can i get this products ?',
  //                             //       style: TextStyle(fontSize: 12.5, color: Colors.grey),
  //                             //     ),
  //                             //   ],
  //                             // ),
  //                             // SizedBox(
  //                             //   height: 7,
  //                             // ),
  //                             // Row(
  //                             //   children: [
  //                             //     ImageIcon(
  //                             //       AssetImage('assets/slicing/questions.png'),
  //                             //     ),
  //                             //     SizedBox(
  //                             //       width: 10,
  //                             //     ),
  //                             //     Text(
  //                             //       'verv soon',
  //                             //       style: TextStyle(fontSize: 12.5, color: Colors.grey),
  //                             //     ),
  //                             //   ],
  //                             // ),
  //                             SizedBox(height: res_height * 0.02),
  //                             Container(
  //                               width: res_width * 0.9,
  //                               child: Text(
  //                                 'Products Description',
  //                                 style: TextStyle(fontSize: 15),
  //                               ),
  //                             ),
  //                             SizedBox(height: res_height * 0.01),
  //                             Container(
  //                               width: res_width * 0.9,
  //                               child: Text(
  //                                 ApiRepository
  //                                     .shared
  //                                     .getProductsByIdList!
  //                                     .data![0]
  //                                     .serviceAgreements
  //                                     .toString(),
  //                                 // 'Lorem Ipsum is simply dummy text of the printing and type-setting industry.Lorem Ipsum is simply dummy text of the printing and typesetting industry',
  //                                 style: TextStyle(
  //                                   fontSize: 12,
  //                                   color: Colors.grey,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //
  //                       SizedBox(height: 39),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   showDialog(
  //                                     context: context,
  //                                     builder:
  //                                         (_) => AlertDialog(
  //                                           backgroundColor: Color(
  //                                             0xff000000B8,
  //                                           ),
  //                                           shape: RoundedRectangleBorder(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(10),
  //                                           ),
  //                                           contentPadding: EdgeInsets.all(0),
  //                                           actionsPadding: EdgeInsets.all(0),
  //                                           actions: [
  //                                             Stack(
  //                                               clipBehavior: Clip.none,
  //                                               alignment:
  //                                                   AlignmentDirectional.center,
  //                                               children: [
  //                                                 Container(
  //                                                   width: res_width * 0.8,
  //                                                   height: res_height * 0.3,
  //                                                   decoration: BoxDecoration(
  //                                                     // border: Border.all(color: Colors.white),
  //                                                     borderRadius:
  //                                                         BorderRadius.circular(
  //                                                           10,
  //                                                         ),
  //                                                     color: Color(0xffFEB038),
  //                                                   ),
  //                                                   child: Column(
  //                                                     mainAxisAlignment:
  //                                                         MainAxisAlignment
  //                                                             .spaceBetween,
  //                                                     children: [
  //                                                       SizedBox(
  //                                                         height:
  //                                                             res_height * 0.07,
  //                                                       ),
  //                                                       Text(
  //                                                         "Delete",
  //                                                         style: TextStyle(
  //                                                           fontFamily:
  //                                                               "Inter, Bold",
  //                                                           fontSize: 25,
  //                                                           color: Colors.white,
  //                                                         ),
  //                                                       ),
  //                                                       Padding(
  //                                                         padding:
  //                                                             const EdgeInsets.all(
  //                                                               10.0,
  //                                                             ),
  //                                                         child: Text(
  //                                                           "Are you sure you want to delete this item?",
  //                                                           style: TextStyle(
  //                                                             fontFamily:
  //                                                                 "Inter, Regular",
  //                                                             fontSize: 18,
  //                                                             color:
  //                                                                 Colors.white,
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       // 15.verticalSpace,
  //                                                       // Container(
  //                                                       //   width: 270.w,
  //                                                       //   height: 50.h,
  //                                                       //   child: Text(
  //                                                       //     "You will be contacted by the Owner via direct message to confirm!",
  //                                                       //     textAlign: TextAlign.center,
  //                                                       //     style: TextStyle(
  //                                                       //       fontFamily: "Inter, Regular",
  //                                                       //       fontSize: 15.sp,
  //                                                       //       color: Colors.white,
  //                                                       //     ),
  //                                                       //   ),
  //                                                       // ),
  //                                                       // SizedBox(
  //                                                       //   height: 18,
  //                                                       // ),
  //                                                       Row(
  //                                                         children: [
  //                                                           Expanded(
  //                                                             child: InkWell(
  //                                                               onTap: () {
  //                                                                 Get.back();
  //                                                               },
  //                                                               child: Container(
  //                                                                 height: 50,
  //                                                                 decoration: BoxDecoration(
  //                                                                   borderRadius: BorderRadius.only(
  //                                                                     bottomLeft:
  //                                                                         Radius.circular(
  //                                                                           10,
  //                                                                         ),
  //                                                                     // bottomRight:
  //                                                                     //     Radius.circular(10.r),
  //                                                                   ),
  //                                                                   color:
  //                                                                       Colors
  //                                                                           .white,
  //                                                                 ),
  //                                                                 child: Center(
  //                                                                   child: Text(
  //                                                                     "No",
  //                                                                     style: TextStyle(
  //                                                                       fontFamily:
  //                                                                           "Inter, Regular",
  //                                                                       fontSize:
  //                                                                           14,
  //                                                                       color:
  //                                                                           Colors.black,
  //                                                                     ),
  //                                                                   ),
  //                                                                 ),
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                           Expanded(
  //                                                             child: InkWell(
  //                                                               onTap: () {
  //                                                                 ApiRepository
  //                                                                     .shared
  //                                                                     .deleteProductsById(
  //                                                                       prodID,
  //                                                                     );
  //                                                                 final bottomcontroller =
  //                                                                     Get.put(
  //                                                                       BottomController(),
  //                                                                     );
  //                                                                 bottomcontroller
  //                                                                     .navBarChange(
  //                                                                       1,
  //                                                                     );
  //                                                               },
  //                                                               child: Container(
  //                                                                 height: 50,
  //                                                                 decoration: BoxDecoration(
  //                                                                   borderRadius: BorderRadius.only(
  //                                                                     // bottomLeft:
  //                                                                     //     Radius.circular(10.r),
  //                                                                     bottomRight:
  //                                                                         Radius.circular(
  //                                                                           10,
  //                                                                         ),
  //                                                                   ),
  //                                                                   color:
  //                                                                       Colors
  //                                                                           .white,
  //                                                                 ),
  //                                                                 child: Center(
  //                                                                   child: Text(
  //                                                                     "Yes",
  //                                                                     style: TextStyle(
  //                                                                       fontFamily:
  //                                                                           "Inter, Regular",
  //                                                                       fontSize:
  //                                                                           14,
  //                                                                       color:
  //                                                                           Colors.black,
  //                                                                     ),
  //                                                                   ),
  //                                                                 ),
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                         ],
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                 ),
  //                                                 Positioned(
  //                                                   top: -20,
  //                                                   // left: 100,
  //                                                   child: Container(
  //                                                     width: 90,
  //                                                     height: 90,
  //                                                     decoration: BoxDecoration(
  //                                                       shape: BoxShape.circle,
  //                                                       color: Color(
  //                                                         0xffFEB038,
  //                                                       ),
  //                                                     ),
  //                                                     child: Center(
  //                                                       child: Image.asset(
  //                                                         "assets/slicing/smile@3x.png",
  //                                                         scale: 5,
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ],
  //                                         ),
  //                                   );
  //                                 },
  //                                 child: Container(
  //                                   height: 44,
  //                                   width: 150,
  //                                   child: Center(
  //                                     child: Text(
  //                                       'Delete',
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 12,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.white,
  //                                     border: Border.all(color: Colors.orange),
  //                                     borderRadius: BorderRadius.circular(5),
  //                                   ),
  //                                 ),
  //                               ),
  //                               SizedBox(width: 15),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   if (categoryID != null &&
  //                                       subCategoryID != null &&
  //                                       name != null &&
  //                                       price != null &&
  //                                       specifications != null &&
  //                                       description != null &&
  //                                       negotiation != null &&
  //                                       product_id != null &&
  //                                       images != null &&
  //                                       imageID != null &&
  //                                       message != null &&
  //                                       delivery_charges != null) {
  //                                     //   categoryID.toString() +
  //                                     //   subCategoryID.toString() +
  //                                     //   name.toString() +
  //                                     //   price.toString() +
  //                                     //   specifications.toString() +
  //                                     //   description.toString() +
  //                                     //   negotiation.toString() +
  //                                     //   product_id.toString()
  //
  //                                     // );
  //                                     Get.off(
  //                                       () => EditProductScreen(
  //                                         category_id: categoryID,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .categoryId,
  //                                         sub_category_id: subCategoryID,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .subcategoryId,
  //                                         name: name,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .name,
  //                                         price: price,
  //
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .price,
  //                                         specifications: specifications,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .specifications,
  //                                         description: description,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .serviceAgreements,
  //                                         negotiation: negotiation,
  //                                         //  ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .negotiation,
  //                                         product_id: product_id,
  //                                         // ApiRepository
  //                                         //     .shared
  //                                         //     .getProductsByIdList
  //                                         //     ?.data![0]
  //                                         //     .productId,
  //                                         relProd: [],
  //                                         images: images,
  //                                         imageID: imageID,
  //                                         messageStatus: message,
  //                                         delivery_charges: delivery_charges,
  //                                       ),
  //                                     );
  //                                   }
  //                                 },
  //                                 child: Container(
  //                                   height: 44,
  //                                   width: 150,
  //                                   child: Center(
  //                                     child: Text(
  //                                       'Edit Product',
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 12,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   decoration: BoxDecoration(
  //                                     color:
  //                                         editVisibility
  //                                             ? kprimaryColor
  //                                             : kprimaryColor.withAlpha(128),
  //                                     borderRadius: BorderRadius.circular(5),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: res_height * 0.03),
  //
  //                       relloading
  //                           ? SizedBox(height: 10)
  //                           : FutureBuilder(
  //                             builder: (context, snapshot) {
  //                               return GridView.builder(
  //                                 gridDelegate:
  //                                     SliverGridDelegateWithFixedCrossAxisCount(
  //                                       crossAxisCount: 2,
  //                                       crossAxisSpacing: 2.0,
  //                                       mainAxisSpacing: 30.0,
  //                                       childAspectRatio: 1,
  //                                     ),
  //                                 shrinkWrap: true,
  //                                 physics: NeverScrollableScrollPhysics(),
  //                                 itemCount:
  //                                     ApiRepository
  //                                         .shared
  //                                         .getRelatedProductsList
  //                                         ?.data
  //                                         ?.length,
  //                                 itemBuilder: (context, int index) {
  //                                   relProdArray.add(
  //                                     ApiRepository
  //                                         .shared
  //                                         .getRelatedProductsList!
  //                                         .data![index],
  //                                   );
  //                                   var name =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .name;
  //                                   var price =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .price;
  //                                   var stars =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .stars;
  //                                   var image =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .image;
  //                                   var length =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .length;
  //                                   var id =
  //                                       ApiRepository
  //                                           .shared
  //                                           .getRelatedProductsList!
  //                                           .data![index]
  //                                           .id;
  //                                   return Container(
  //                                     child: Wrap(
  //                                       spacing: 10,
  //                                       runSpacing: 10,
  //                                       children: [
  //                                         itmBox(
  //                                           img:
  //                                               AppUrl.baseUrlM +
  //                                               image.toString(),
  //                                           dx: '\$${price}',
  //                                           rv: length.toString(),
  //                                           tx: name,
  //                                           rt: stars,
  //                                           id: id,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   );
  //                                 },
  //                               );
  //                             },
  //                             future: null,
  //                           ),
  //                       SizedBox(height: 100),
  //                       // Container(height: 100,)
  //                     ],
  //                   ),
  //                 ),
  //
  //                 ///here
  //               ),
  //             ),
  //   );
  // }

  itmBox({img, tx, dx, rt, rv, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        // getProducts(id.toString());
      },
      child: Container(
        width: res_width * 0.44,
        // height: res_height * 0.28,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        // child: Padding(
        //   padding: const EdgeInsets.only(
        //       bottom: 120, left: 10, right: 10, top: 10),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: res_height * 0.2,
                decoration: BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: '$img',
                    fit: BoxFit.fill,
                    placeholder:
                        (context, url) =>
                            Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) =>
                            Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.005),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tx', style: TextStyle(fontSize: 11)),
                    SizedBox(height: res_height * 0.006),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          RatingBarIndicator(
                            rating: double.parse(rt),
                            itemBuilder:
                                (context, index) =>
                                    Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 15,
                            direction: Axis.horizontal,
                          ),
                          Text(
                            '($rv) Reviews',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
