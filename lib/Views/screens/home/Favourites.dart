import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/auth/ProductDetail.dart';
// import 'package:jared/screens/home/profile/myprofile.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:jared/res/app_url.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

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
    getUserDate().then((value) async {
      token = value.token.toString();
      sourceId = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      getFavourites();
      print("Source ID: ${sourceId}");
      print("role: ${role}");
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  getFavourites() {
    ApiRepository.shared.getFavourites(
        sourceId,
        (List) => {
              if (this.mounted)
                {
                  if (List.data!.length == 0)
                    {
                      setState(() {
                        isLoading = false;
                        isEmpty = true;
                        isError = false;
                      })
                    }
                  else
                    {
                      setState(() {
                        isLoading = false;
                        isEmpty = false;
                        isError = false;
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    isLoading = false;
                    isEmpty = false;
                    isError = true;
                  })
                }
            });
  }

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      // key: _key,
      // drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Wishlist',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          //  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreen()));
          },
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => MyProfileScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: Container(
                child: Image.asset('assets/slicing/avatar.png'),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            width: double.infinity,
            child: isError
                ? Center(child: Text("An Error Ocuured While Loading Data"))
                : isLoading
                    ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator()))
                    : isEmpty
                        ? Center(child: Text("No items Added"))
                        : GridView.builder(
                           gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300,
                                    childAspectRatio: 2 / 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10),
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: ApiRepository.shared.getFavouriteProductsModelList!.data!.length,
                          itemBuilder: (context, int index) {
                            var data = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index];
                            var id = data.id.toString();
                            var userID = data.userId.toString();
                            var servAgreement = data.serviceAgreements.toString();
                            var msg = data.isMessage;
                            var img = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .image
                                .toString();
                            var name = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .name
                                .toString();
                            var specs = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .specifications
                                .toString();
                            var price = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .price
                                .toString();
                            var stars = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .stars
                                .toString();
                            var length = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .length
                                .toString();
                                var delivery_charges = ApiRepository
                                .shared
                                .getFavouriteProductsModelList!
                                .data![index]
                                .delivery_charges
                                .toString();
                            return itmBox(
                                id: id,
                                img: AppUrl.baseUrlM + img.toString(),
                                tx: name,
                                dx: price,
                                rt: stars,
                                rv: length,
                                specs: specs,
                                userID: userID,
                                servAg: servAgreement,
                                msg: msg,
                                delivery_charges: delivery_charges,
                                );
                          })
            // Container(
            //   child: Wrap(
            //     spacing: 10,
            //     runSpacing: 10,
            //     children: [
            //       itmBox(
            //           img: 'assets/slicing/h.jpg',
            //           dx: '\$ 7000',
            //           rv: '(2.9k Revews)',
            //           tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
            //           rt: '4.9'),
            //       itmBox(
            //           img: 'assets/slicing/h.jpg',
            //           dx: '\$ 9000',
            //           rv: '(2.9k Revews)',
            //           tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
            //           rt: '4.9'),
            //       itmBox(
            //           img: 'assets/slicing/h.jpg',
            //           dx: '\$ 9000',
            //           rv: '(2.9k Revews)',
            //           tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
            //           rt: '4.9'),
            //       itmBox(
            //           img: 'assets/slicing/h.jpg',
            //           dx: '\$ 9000',
            //           rv: '(2.9k Revews)',
            //           tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
            //           rt: '4.9'),
            //     ],
            //   ),
            // ),
            ),
      ),
    );
  }

  itmBox({id, img, tx, dx, rt, rv, specs, userID, servAg, msg,delivery_charges}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Get.to(routeName: "PD",() => ProductDetailScreen(
          id,
          tx,
          int.parse(dx.toString()),
          rt,
          img,
          specs,
          userID,
          servAg,
          msg,
          delivery_charges
        ));
      },
      child: Container(
        // width: res_width * 0.44,
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: Image.network(
                    '$img',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                height: res_height * 0.005,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$tx',
                      style: TextStyle(fontSize: 11),
                    ),
                    SizedBox(
                      height: res_height * 0.006,
                    ),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(rt),
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
                          '($rv) Reviews',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
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
