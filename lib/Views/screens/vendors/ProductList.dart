import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/mainfolder/drawer.dart';
import 'package:jebby/Views/screens/vendors/Productdetail2.dart';
import 'package:jebby/Views/screens/vendors/addproduct.dart';
import 'package:jebby/res/app_url.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  final side;
  ProductListScreen({Key? key, required this.side}) : super(key: key);
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  bool emptyData = false;
  bool isLoading = true;
  bool isError = false;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          getUserData();
          getVendorProducts(id);
          getProductsApi(id);
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  var profile = [];
  Future getProductsApi(id) async {
    final response = await http.get(
      Uri.parse('${Url}/UserProfileGetById/${id}'),
    );
    var data = jsonDecode(response.body.toString());
    profile = data['data'];
  }

  getVendorProducts(id) {
    ApiRepository.shared.getAllVendorProductsByID(
      (list) {
        if (this.mounted) {
          if (list.data!.length == 0) {
            setState(() {
              emptyData = true;
              isLoading = false;
              isError = false;
            });
          } else {
            setState(() {
              emptyData = false;
              isLoading = false;
              isError = false;
            });
          }
        }
      },
      (error) {
        if (this.mounted) {
          if (error != null) {
            setState(() {
              isLoading = true;
              isError = true;
            });
          }
        }
      },
      id,
    );
  }

  late var vendorAccountMail;
  bool isULoading = true;

  void getUserData() {
    ApiRepository.shared.userCredential(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {}
            else
              {
                setState(() {
                  isULoading = false;
                  vendorAccountMail =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .stripeEmail
                          .toString();
                }),
              },
          },
      },
      (error) => {if (error != null) {}},
      id.toString(),
    );
  }

  void initState() {
    getData();
    profileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.black),
          onPressed: (){
            Get.back();
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:20),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// TITLE + BUTTON

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "My Products",
                      style: TextStyle(
                          fontSize:28,
                          fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height:5),

                    Text(
                      "View and Edit your Products",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize:16),
                    )

                  ],
                ),

                GestureDetector(
                  onTap: (){
                    if (profile.length == 0) {

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Complete Your Profile")));

                    } else {
                      Get.to(()=>AddProductScreen());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:20,vertical:10),
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      "Add Product",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height:20),

            /// SEARCH BAR

            Container(
              padding: EdgeInsets.symmetric(horizontal:15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search by Product Name",
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height:20),

            /// PRODUCT GRID

            Expanded(
              child: isError
                  ? Center(child: Text("Error loading data"))
                  : isLoading
                  ? Center(child: CircularProgressIndicator())
                  : emptyData
                  ? Center(child: Text("No Products Added"))
                  : GridView.builder(

                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.7,
                ),

                itemCount: ApiRepository
                    .shared
                    .vendorProductsByIdList
                    ?.data
                    ?.length,

                itemBuilder: (context,index){

                  var product = ApiRepository
                      .shared
                      .vendorProductsByIdList!
                      .data![index];

                  return productCard(
                      product.id,
                      product.name,
                      product.price,
                      product.stars,
                      product.image);

                },
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget productCard(id,name,price,stars,image){

    return GestureDetector(

      onTap: (){
        Get.to(()=>ProductDetail2Screen(id:id));
      },

      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// IMAGE

            Stack(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18)),
                  child: CachedNetworkImage(
                    imageUrl: AppUrl.baseUrlM + image.toString(),
                    height:140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  right:10,
                  top:10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:8,vertical:3),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "NEW",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:10),
                    ),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    name.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:14),
                  ),

                  SizedBox(height:5),

                  Text(
                    "\$ ${price}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:16),
                  ),

                  SizedBox(height:5),

                  RatingBarIndicator(
                    rating: double.parse(stars.toString()),
                    itemBuilder: (context,index)=>Icon(
                        Icons.star,
                        color: Colors.orange),
                    itemCount: 5,
                    itemSize: 16,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  itmBox({img, tx, dx, rt, rv, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: GestureDetector(
        onTap: () {
          Get.off(() => ProductDetail2Screen(id: id));
        },
        child: Container(
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
                      imageUrl: img.toString(),
                      fit: BoxFit.fill,
                      placeholder:
                          (context, url) => Center(
                            child:
                                CircularProgressIndicator(), // Loading spinner
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.error,
                            color: Colors.red,
                          ), // Display an error icon
                    ),
                  ),
                ),
                SizedBox(height: res_height * 0.005),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: res_width * 0.5,
                        child: Text(
                          '$tx',
                          style: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: res_height * 0.006),
                      Text(
                        '$dx',
                        style: TextStyle(fontSize: 13),
                        textAlign: TextAlign.left,
                      ),
                      Row(
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
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
