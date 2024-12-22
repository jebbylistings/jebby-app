import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/Views/screens/profile/editprofile.dart';
import 'package:jared/Views/screens/vendors/Productdetail2.dart';
import 'package:jared/res/app_url.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

import '../../controller/bottomcontroller.dart';
import '../home/UpdateReview.dart';

class RenterProfile extends StatefulWidget {
  const RenterProfile({super.key});

  @override
  State<RenterProfile> createState() => _RenterProfileState();
}

class _RenterProfileState extends State<RenterProfile> {
   String Url = dotenv.env['baseUrlM'] ?? 'No url found';
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  var _locationController = TextEditingController();
  var Latitiude;
  var Longitude;

  ///////////////////////////
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
    final usp = context.read<UserViewModel>();
    usp.getUpdatedUser();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();
  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate().then((value) async {
      token = value.token.toString();
      id = value.id.toString();
      getProductsApi(id);
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      getReviews();
      getProducts();
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getReviews() {
    ApiRepository.shared.reviewsByVendorId(id.toString(), (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isEmpty = true;
            isLoading = false;
            isError = false;
          });
        } else {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          isEmpty = false;
          isLoading = false;
          isError = true;
        });
      }
    });
  }

  bool isPLoading = true;
  bool isPError = false;
  bool isPEmpty = false;

  getProducts() {
    ApiRepository.shared.reviewsByVenodorProduct(id.toString(), (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isPEmpty = true;
            isPLoading = false;
            isPError = false;
          });
        } else {
          setState(() {
            isPEmpty = false;
            isPLoading = false;
            isPError = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          isPEmpty = false;
          isPLoading = false;
          isPError = true;
        });
      }
    });
  }

  final bottomctrl = Get.put(BottomController());

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            setState(() {
            //   Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => MainScreen()),
            // );
            bottomctrl.navBarChange(0);
              Get.back();
            });
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(19.0),
            child: GestureDetector(
              onTap: () {
                Get.off(() => EditProfile());
              },
              child: Container(
                child: Image.asset('assets/slicing/Group 63@3x.png'),
              ),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 400,
                      height: 136,
                      decoration: BoxDecoration(),
                      child: imagesapi == "null"
                          ? sp.imageUrl.toString() == "null"
                              ? Image.asset("assets/slicing/blankuser.jpeg", fit: BoxFit.cover)
                              : CachedNetworkImage(
                                          imageUrl: "${sp.imageUrl}",
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        )
                          : CachedNetworkImage(
                                      imageUrl: "${Url}${back_image_api}",
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    ),
                    ),
                    Positioned(
                      left: 15,
                      bottom: -20,
                      child: Container(
                        child:
                            //if we face face errir we use this widget
                            // CircleAvatar(
                            //     radius: 40,
                            //     child: imagesapi == "null"?
                            //       sp.imageUrl.toString() == "null"?
                            //       CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                            //           :CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}")): CircleAvatar(
                            //               radius: 40,
                            //               backgroundImage: NetworkImage(
                            //                 "${Url}${imagesapi}",
                            //               )),)
                            usp.image.toString() == "null"
                                ? sp.imageUrl.toString() == "null"
                                    ? CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                                    : CachedNetworkImage(
                                            imageUrl: "${sp.imageUrl}",
                                            imageBuilder: (context, imageProvider) => CircleAvatar(
                                              radius: 40,
                                              backgroundImage: imageProvider,
                                            ),
                                            placeholder: (context, url) => CircularProgressIndicator(), // Placeholder widget
                                            errorWidget: (context, url, error) => Icon(Icons.error, size: 40), // Error widget
                                          )
                                : CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[200],
                                      child: CachedNetworkImage(
                                        imageUrl: "${Url}${usp.image}",
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          radius: 40,
                                          backgroundImage: imageProvider,
                                        ),
                                        placeholder: (context, url) => CircularProgressIndicator(), // Placeholder widget
                                        errorWidget: (context, url, error) => Icon(Icons.error, size: 40), // Error widget
                                      ),
                                    )
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sp.name.toString() == "null"
                              ? nameapi == "null"
                                  ? fullname.toString()
                                  : nameapi.toString()
                              : sp.name.toString(),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 300,
                          child: Text(
                            address == "null" ? "City,ST" : address.toString(),
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // Container(
                        //   width: 380,
                        //   child: Text(
                        //     "Lorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitanLorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitan",
                        //     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 14),
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Container(
                //       height: 34,
                //       width: 192,
                //       child: Center(
                //         child: Text(
                //           'Unfollow',
                //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                //         ),
                //       ),
                //       decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(5)),
                //     ),
                //     Container(
                //       height: 34,
                //       width: 192,
                //       child: Center(
                //         child: Text(
                //           'Unfollow',
                //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                //         ),
                //       ),
                //       decoration:
                //           BoxDecoration(color: Colors.white, border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(5)),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [

                //     // itmBox(
                //     //     img: 'assets/slicing/Layer 4@3x.png',
                //     //     dx: '\$ 7000',
                //     //     rv: '(2.9k Revews)',
                //     //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                //     //     rt: '4.9'),
                //     // itmBox(
                //     //     img: 'assets/slicing/Layer 4@3x.png',
                //     //     dx: '\$ 9000',
                //     //     rv: '(2.9k Revews)',
                //     //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                //     //     rt: '4.9'),
                //   ],
                // ),
                // Followesss(),
                isPLoading
                    ? Text("")
                    : isPEmpty
                        ? Container(height: 100, child: Center(child: Text("No Review Product")))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 30.0, childAspectRatio: 0.75),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ApiRepository.shared.getVendorProductsByReviewsModelList!.data!.length,
                            itemBuilder: (context, int index) {
                              var data = ApiRepository.shared.getVendorProductsByReviewsModelList!.data![index];
                              var image = data.image.toString();
                              var price = data.price.toString();
                              var length = data.length.toString();
                              var name = data.name.toString();
                              var id = data.id.toString();
                              var stars = data.stars;
                              return itmBox(img: image, dx: price, rv: length, tx: name, rt: stars, id: id);
                            }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                isLoading
                    ? Text("")
                    : isEmpty
                        ? Text("")
                        : Reviewsss(ApiRepository.shared.getAllReviewsByVendorIdModelList!.totalreviews.toString()),
                SizedBox(
                  height: 10,
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //     ],
                //   ),
                // ),
                isLoading
                    ? Text("")
                    : isEmpty
                        ? Text("")
                        : SizedBox(
                            width: double.infinity,
                            height: res_height * 0.1,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: ApiRepository.shared.getAllReviewsByVendorIdModelList!.data!.length,
                                itemBuilder: (context, int index) {
                                  var image = ApiRepository.shared.getAllReviewsByVendorIdModelList!.data![index].image.toString();
                                  var stars = ApiRepository.shared.getAllReviewsByVendorIdModelList!.data![index].stars.toString();
                                  var desc = ApiRepository.shared.getAllReviewsByVendorIdModelList!.data![index].description.toString();
                                  var name = ApiRepository.shared.getAllReviewsByVendorIdModelList!.data![index].userName.toString();
                                  return scrollss(image, stars, desc, name);
                                }),
                          ),
                // Row(
                //   children: [
                //     Text(
                //       "Menu",
                //       style: TextStyle(color: Colors.black, fontSize: 24),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 400,
                  height: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: 10,
                ),
                // Row(
                //   children: [
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           "New Arrivals",
                //           style: TextStyle(color: Colors.black, fontSize: 19),
                //         ),
                //         SizedBox(
                //           height: 5,
                //         ),
                //         Text(
                //           "Top products incredible price",
                //           style: TextStyle(color: Colors.grey, fontSize: 14),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),

                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Followesss() {
    return Container(
      width: 391,
      height: 74,
      decoration: BoxDecoration(color: Color(0xFF4285F4), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "0",
                  style: TextStyle(color: kprimaryColor),
                ),
                Text(
                  "Following",
                  style: TextStyle(color: kprimaryColor),
                ),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: 1,
              height: 40,
              color: kprimaryColor,
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "2654",
                  style: TextStyle(color: kprimaryColor),
                ),
                Text(
                  "Followers",
                  style: TextStyle(color: kprimaryColor),
                ),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: 1,
              height: 40,
              color: kprimaryColor,
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "265",
                  style: TextStyle(color: kprimaryColor),
                ),
                Text(
                  "Products",
                  style: TextStyle(color: kprimaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Reviewsss(review) {
    double res_width = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: res_width * 0.25,
          child: Text(
            "Reveiws",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        // SizedBox(
        //   width: 5,
        // ),
        SizedBox(
          width: res_width * 0.55,
          child: Text(
            review,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        // SizedBox(
          
        // ),
        GestureDetector(
          onTap: () {
            Get.to(() => ReviewScreen());
          },
          child: Container(
            child: Text(
              "See All",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        )
      ],
    );
  }

  scrollss(img, stars, desc, name) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.58, 
      height: res_height * 0.145,
      margin: EdgeInsets.only(right: res_width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(AppUrl.baseUrlM + img),
                ),
                // Container(
                //   child: Image.network(
                //     AppUrl.baseUrlM + img,
                //     fit: BoxFit.fill,
                //   ),
                // ),
                SizedBox(
                  width: res_width * 0.02,
                ),
                SizedBox(
                  width: res_width * 0.38,
                  child: Text(name),
                )
              ],
            ),
            SizedBox(
              height: res_height * 0.01,
            ),
            RatingBarIndicator(
              rating: double.parse(stars.toString()),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 15,
              direction: Axis.horizontal,
            ),
            SizedBox(
              height: res_height * 0.005,
            ),
            SizedBox(
              width: res_width * 0.5,
              child: Text(
                desc,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  itmBox({img, tx, dx, rt, rv, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetail2Screen(
              id: id,
            ));
      },
      child: Container(
        width: res_width * 0.44,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: res_height * 0.2,
                decoration: BoxDecoration(),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: Image.network(
                      AppUrl.baseUrlM + img.toString(),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(
                height: res_height * 0.005,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tx',
                    style: TextStyle(fontSize: 11),
                  ),
                  // SizedBox(
                  //   height: res_height * 0.006,
                  // ),
                  // Text(
                  //   '$dx',
                  //   style: TextStyle(fontSize: 11),
                  //   textAlign: TextAlign.left,
                  // ),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: double.parse(rt.toString()),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15,
                        direction: Axis.horizontal,
                      ),
                      Text(
                        '$rt ',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        '( $rv reviews)',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              )
            ],
          ),
        ),
      ),
    );
  }

  var imagesapi = "null";
  var nameapi = "null";
  var locationapi = "null";
  var emailapi = "null";
  var back_image_api = "null";
  var address = "null";

  ////////
  Future getProductsApi(id) async {
    final response = await http.get(Uri.parse('${Url}/UserProfileGetById/${id}'));
    var data = jsonDecode(response.body.toString());
    if (data["data"].length != 0) {
    }

    setState(() {
      if (data["data"].length != 0) {
        imagesapi = data["data"][0]["image"].toString();
        nameapi = data["data"][0]["name"].toString();
        _nameController.text = data["data"][0]["name"].toString();
        _emailController.text = data["data"][0]["email"].toString();
        address = data["data"][0]["address"].toString();

        back_image_api = data["data"][0]["back_image"].toString();
        Latitiude = data["data"][0]["latitude"].toString();
        Longitude = data["data"][0]["longitude"].toString();
      }
    });
    if (response.statusCode == 200) {
      if (data["data"].length != 0) {
        SharedPreferences updatePrefrences = await SharedPreferences.getInstance();

        setState(() {
          updatePrefrences.setString('fullname', data["data"][0]["name"].toString());
          updatePrefrences.setString('email', data["data"][0]["email"].toString());
          updatePrefrences.setString('image', data["data"][0]["image"].toString());
          updatePrefrences.setString('address', data["data"][0]["address"].toString());
          updatePrefrences.setString('latitude', data["data"][0]["latitude"].toString());
          updatePrefrences.setString('longitude', data["data"][0]["longitude"].toString());
          updatePrefrences.setString('number', data["data"][0]["number"].toString());
        });
        return data;
      } else {
        return "No data";
      }
    }
  }
}
