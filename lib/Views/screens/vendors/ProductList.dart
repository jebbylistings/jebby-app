import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/mainfolder/drawer.dart';
import 'package:jared/Views/screens/vendors/Productdetail2.dart';
import 'package:jared/Views/screens/vendors/addproduct.dart';
import 'package:jared/res/app_url.dart';
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
    getUserDate().then((value) async {
      token = value.token.toString();
      id = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      getUserData();
      getVendorProducts(id);
      getProductsApi(id);
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  var profile = [];
  Future getProductsApi(id) async {
    final response = await http.get(Uri.parse('https://api.jebbylistings.com/UserProfileGetById/${id}'));
    var data = jsonDecode(response.body.toString());
    profile = data['data'];
    print("data ${data['data'].toString()}");
  }

  getVendorProducts(id) {
    ApiRepository.shared.getAllVendorProductsByID((list) {
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
    }, (error) {
      if (this.mounted) {
        if (error != null) {
          setState(() {
            isLoading = true;
            isError = true;
            print("Error:  ${error}");
          });
        }
      }
    }, id);
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
                        vendorAccountMail = ApiRepository.shared.getUserCredentialModelList!.data![0].stripeEmail.toString();
                        print("venodor account mail ${vendorAccountMail}");
                      })
                    }
                }
            },
        (error) => {
              if (error != null) {},
            },
        id.toString());
  }

  void initState() {
    getData();
    profileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;

    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();

    return Scaffold(
      key: _key,
      drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Products List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: 
        widget.side ? GestureDetector(
            onTap: () {
              _key.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Container(
                child: Image.asset('assets/slicing/hamburger.png'),
              ),
            ),
          ) :
         GestureDetector(
          onTap: () {
            Get.back();
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
              if (profile.length == 0) {
                final snackBar = new SnackBar(content: new Text("Complete Your Profile"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                Get.off(() => AddProductScreen());
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        kprimaryColor),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: res_height * 0.03,
              ),
              isError
                  ? Center(child: Text("Some error occured while loading data"))
                  : isLoading
                      ? Center(child: CircularProgressIndicator())
                      : emptyData
                          ? profile.length == 0 ? Center(child: Text("Complete Your Profile"))
                          : Center(child: Text("No Product Added"))
                          : FutureBuilder(builder: (context, snapshot) {
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 1.0, childAspectRatio: 0.7
                                    ),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: ApiRepository.shared.vendorProductsByIdList?.data?.length,
                                itemBuilder: (context, int index) {
                                  var id = ApiRepository.shared.vendorProductsByIdList?.data?[index].id;
                                  var name = ApiRepository.shared.vendorProductsByIdList?.data?[index].name;
                                  var price = ApiRepository.shared.vendorProductsByIdList?.data?[index].price;
                                  var stars = ApiRepository.shared.vendorProductsByIdList?.data?[index].stars;
                                  var reviews = ApiRepository.shared.vendorProductsByIdList?.data?[index].length;
                                  var specs = ApiRepository.shared.vendorProductsByIdList?.data?[index].specifications;
                                  var image = ApiRepository.shared.vendorProductsByIdList?.data?[index].image;
                                  var length = ApiRepository.shared.vendorProductsByIdList?.data?[index].length;
                                  return Container(
                                    child: Wrap(
                                      spacing: 1,
                                      runSpacing: 5,
                                      children: [
                                        itmBox(
                                            img: AppUrl.baseUrlM + image.toString(),
                                            dx: '\$${price}',
                                            rv: length.toString(),
                                            tx: name,
                                            rt: stars,
                                            id: id),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }, future: null,),
              // Container(
              //   height: 100,
              //   width: 100,
              // )
            ],
          ),
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
          Get.off(() => ProductDetail2Screen(
                id: id,
              ));
        },
        child:
            Container(
              width: res_width * 0.44,
              height: res_height * 0.3,
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
                            img.toString(),
                            fit: BoxFit.fill,
                          )),
                    ),
                    SizedBox(
                      height: res_height * 0.005,
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: res_width * 0.5,
                            child: Text(
                              '$tx',
                              style: TextStyle(fontSize: 11),
                            ),
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
                                '($rv) Reviews',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
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
