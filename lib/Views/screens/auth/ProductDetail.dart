// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/agreements/insuranceAndIndemnifications.dart';
import 'package:jebby/Views/screens/agreements/rentalAgreement.dart';
import 'package:jebby/Views/screens/agreements/termsAndConditions.dart';
import 'package:jebby/Views/screens/agreements/transportAndInstallationPolicy.dart';
import 'package:jebby/Views/screens/home/RentNow.dart';
import 'package:jebby/Views/screens/home/RenterView.dart';
import 'package:jebby/Views/screens/home/chat.dart';
import 'package:jebby/Views/screens/home/gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic id;
  final dynamic name;
  final dynamic price;
  final dynamic stars;
  final dynamic image;
  final dynamic specs;
  final dynamic userID;
  final dynamic desc;
  final dynamic messageStatus;
  final dynamic delivery_charges;
  final dynamic sourceId;

  const ProductDetailScreen(
      this.id,
      this.name,
      this.price,
      this.stars,
      this.image,
      this.specs,
      this.userID,
      this.desc,
      this.messageStatus,
      this.delivery_charges, {
        this.sourceId,
      });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool fav = false;
  bool rentVisibility = true;
  String? role;
  String sourceId = "";

  String vendorName = "Vendor";
  String vendorAddress = "";
  String vendorImage = "";
  String vendorBackImage = "";

  @override
  void initState() {
    super.initState();
    profileData();
    getVendor();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData() async {
    getUserDate().then((value) {
      setState(() {
        role = value.role;
        sourceId = value.id.toString();
      });
      getFavourites();
    });
  }

  void getVendor() {
    ApiRepository.shared.userCredential(
          (_) {
        if (ApiRepository.shared.getUserCredentialModelList!.data!.isNotEmpty) {
          final v =
          ApiRepository.shared.getUserCredentialModelList!.data![0];
          setState(() {
            vendorName = v.name.toString();
            vendorAddress = v.address.toString();
            vendorImage = v.image.toString();
            vendorBackImage = v.backImage.toString();
          });
        }
      },
          (_) {},
      widget.userID.toString(),
    );
  }

  void getFavourites() {
    ApiRepository.shared.getFavourites(
      sourceId,
          (_) {
        for (var f
        in ApiRepository.shared.getFavouriteProductsModelList!.data!) {
          if (f.id.toString() == widget.id.toString()) {
            setState(() => fav = true);
          }
        }
      },
          (_) {},
    );
  }

  void addFavorite(int val) {
    ApiRepository.shared.addFavorite(
      sourceId.toString(),
      widget.id.toString(),
      val.toString(),
    );
  }

  void rentClicked(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("fullname") ?? "";

    Get.to(
          () => RentnowScreen(
        vendorName,
        vendorAddress,
        "",
        vendorImage,
        widget.userID,
        widget.id,
        "",
        "",
        widget.price,
        "",
        "",
        "simple",
        widget.delivery_charges,
        "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (role != "Guest")
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: fav ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  fav = !fav;
                  addFavorite(fav ? 1 : 0);
                });
              },
            ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// IMAGE
                SizedBox(
                  height: size.height * 0.38,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: AppUrl.baseUrlM + widget.image.toString(),
                    fit: BoxFit.cover,
                  ),
                ),

                /// TITLE + PRICE
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rental Price",
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            "€ ${widget.price}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kprimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(),

                /// DESCRIPTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.desc.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// VENDOR
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: vendorImage.isEmpty
                        ? AssetImage("assets/slicing/blankuser.jpeg")
                        : NetworkImage(AppUrl.baseUrlM + vendorImage)
                    as ImageProvider,
                  ),
                  title: Text(vendorName),
                  subtitle: Text(vendorAddress),
                  onTap: () {
                    Get.to(
                          () => RenterScreen(
                        vendorName,
                        vendorImage,
                        vendorBackImage,
                        vendorAddress,
                        widget.userID.toString(),
                      ),
                    );
                  },
                ),

                Divider(),

                _sectionTitle("Product Specifications"),
                _specRow("Material", "Wooden"),
                _specRow("Condition", "New"),
                _specRow("Finish", "Simple Finish"),
                _specRow("Style", "Minimal"),

                Divider(),

                _expandTile("Service Agreements", [
                  _link("Rental Agreement", () => Get.to(RentalAgreement())),
                  _link("Terms & Conditions", () => Get.to(TermsAndCondition())),
                  _link("Insurance Policy",
                          () => Get.to(InsuranceAndIndemnification())),
                  _link("Transport Policy",
                          () => Get.to(TransportAndInstallationPolicy())),
                ]),

                Divider(),

                _sectionTitle("Ratings & Reviews"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "4.97",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBarIndicator(
                            rating: 4.97,
                            itemCount: 5,
                            itemSize: 18,
                            itemBuilder: (_, __) =>
                                Icon(Icons.star, color: Colors.amber),
                          ),
                          Text("200 Reviews"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  if (role != "Guest")
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: Icon(Icons.chat, color: Colors.white),
                        onPressed: () => Get.to(Chat(widget.userID)),
                      ),
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kprimaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => rentClicked(context),
                      child: Text(
                        "Rent Now",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _specRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  Widget _expandTile(String title, List<Widget> children) {
    return ExpansionTile(title: Text(title), children: children);
  }

  Widget _link(String text, VoidCallback onTap) {
    return ListTile(
      title: Text(text, style: TextStyle(color: Colors.blue)),
      onTap: onTap,
    );
  }
}
