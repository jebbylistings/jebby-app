import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Services/provider/sign_in_provider.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/auth/ProductDetail.dart';
import 'package:jared/Views/screens/home/Categoriesss.dart';
import 'package:jared/Views/screens/home/Electronics.dart';
import 'package:http/http.dart' as http;

import 'package:jared/Views/screens/home/messages.dart';
import 'package:jared/Views/screens/mainfolder/drawer.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/screens/home/searchData.dart';
import 'package:jared/model/categoryList_model.dart';
import 'package:jared/view_model/auth_view_model.dart';
import 'package:jared/view_model/category_get_View_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../model/user_model.dart';
import '../../../res/app_url.dart';

import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, num? activeIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var fromdate;
  var todate;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();

  TextEditingController searchController = TextEditingController();

  @override
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
    }).onError((error, stackTrace) {
      if (kDebugMode) {}
    });
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getFeaturedProducts() {
    ApiRepository.shared.featuredProducts((List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isLoading = false;
            isError = false;
            isEmpty = true;
          });
        } else {
          setState(() {
            isLoading = false;
            isError = false;
            isEmpty = false;
          });
        }
      }
    }, (error) {
      setState(() {
        isLoading = true;
        isError = false;
        isEmpty = true;
      });
    });
  }

  bool isLoading1 = true;
  bool isError1 = false;
  bool isEmpty1 = false;
  getNotifications() {
    ApiRepository.shared.notifications(sourceId, (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isEmpty1 = true;
            isLoading1 = false;
            isError1 = false;
          });
        } else {
          setState(() {
            isEmpty1 = false;
            isLoading1 = false;
            isError1 = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          isEmpty1 = false;
          isLoading1 = true;
          isError1 = true;
        });
      }
    });
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool('time') == false
        ? notiTimer().timer?.cancel()
        : notiTimer().timer = prefs.getBool('time') == false
            ? notiTimer().timer?.cancel()
            : new Timer.periodic(Duration(seconds: 5), (_) {
                if (token == null || token == "" || role == "" || role == null || prefs.getBool('time') != true) {
                  cancelTimer();
                } else {
                  prefs.getBool('notifiction') == true
                      ? getNotifications()
                      : prefs.getBool('notifiction') == null
                          ? getNotifications()
                          : null;
                }
              });
  }

  cancelTimer() {
    notiTimer().timer.cancel();
    notiTimer().timer = null;
  }

  void dispose() {
    super.dispose();

    // timer.cancel();
  }

  void func() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("time", true);
    if (role != "Guest") {
      check();
    }
  }

  @override
  void initState() {
    super.initState();
    getFeaturedProducts();
    getData();
    profileData(context);
    getCategoryList();
    func();
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate1 = picked;
      });
    }
  }

  var myFormat = DateFormat('MM/dd/yyyy');
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked =
        await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  double starss = 0.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>();
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    GetAPiFromModel getAPiFromModel = GetAPiFromModel();

    return Container(
      width: double.infinity,
      child: Scaffold(
        key: _key,
        drawer: DrawerScreen(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
          ),
          leading: InkWell(
            onTap: () {
              _key.currentState!.openDrawer();
            },
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Container(
                child: Image.asset('assets/slicing/hamburger.png'),
              ),
            ),
          ),
          actions: [
            Stack(
              children: [
                Visibility(
                  visible: role != null && role != "Guest",
                  child: GestureDetector(
                    onTap: () {
                      seenNotification();
                      Get.to(() => MessageScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 18.0, right: 7),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                isLoading1
                    ? SizedBox()
                    : ApiRepository.shared.getNotificationModelList!.unseen.toString() == "0"
                        ? SizedBox()
                        : Visibility(
                            visible: role != null && role != "Guest",
                            child: Positioned(
                              top: 4,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: kprimaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  isLoading1
                                      ? ""
                                      : ApiRepository.shared.getNotificationModelList!.unseen.toString() == "0"
                                          ? ""
                                          : ApiRepository.shared.getNotificationModelList!.unseen.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
              ],
            ),
            Visibility(
              visible: role != null && role != "Guest",
              child: GestureDetector(
                onTap: () {
                  Get.to(() => MyProfileScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 18.0),
                  child: Icon(Icons.person_outline, color: Colors.black, size: 25),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      width: res_width * 0.94,
                      child: TextFormField(
                        onChanged: (value) {},
                        controller: searchController,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () {
                              if (searchController.text.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchData(
                                      word: searchController.text,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              Icons.search,
                              color: kprimaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          filled: true,
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                          hintText: "Product Name",
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: res_height * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Discover!',
                          style: TextStyle(fontSize: 29, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CategoriesssScreen());
                        },
                        child: Container(
                          child: Text("See All"),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getAPiFromModel.getCategoryList(),
                  builder: (BuildContext context, AsyncSnapshot<CategoryList> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      final data = snapshot.data!.data;
                      return Wrap(
                        spacing: 1,
                        runSpacing: 5,
                        children: List.generate(snapshot.data!.data!.length, (index) {
                          return data![index].status == 0
                              ? Text("")
                              : contBox(txt: data[index].name, img: '${AppUrl.baseUrlM}${data[index].image}', id: data[index].id.toString());
                        }),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: res_height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Featured Items!',
                          style: TextStyle(fontSize: 29, color: Colors.black, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // SizedBox(
                      //   width: 120,
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? Text("")
                    : isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("No items available currently"),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 30.0, childAspectRatio: 1),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: ApiRepository.shared.getFeaturedProductsModelList!.data!.length,
                            itemBuilder: (context, int index) {
                              var data = ApiRepository.shared.getFeaturedProductsModelList!.data![index];
                              var price = data.price;
                              var reviews = data.isReview.toString();
                              var name = data.name.toString();
                              var id = data.id.toString();
                              var specs = data.specifications.toString();
                              var desc = data.serviceAgreements.toString();
                              var userId = data.userId.toString();
                              var msg = data.isMessage;
                              var image = data.image.toString();
                              var stars = data.stars.toString();
                              var delivery_charges = data.delivery_charges.toString();
                              return itmBox(
                                img: image,
                                dx: price,
                                rv: '(${reviews} Reveiws)',
                                tx: '${name}',
                                rt: stars,
                                id: id,
                                specs: specs,
                                userId: userId,
                                desc: desc,
                                msg: msg,
                                delivery_charges: delivery_charges,
                              );
                            }),
                SizedBox(
                  height: res_height * 0.12,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  contBox({txt, img, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double responsiveFontSize = res_width * 0.035;
    return GestureDetector(
      onTap: () {
        Get.to(() => ElectronicsScreen(
              categoryname: txt,
              id: id,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 5, left: 5),
              width: res_width * 0.25,
              height: res_height * 0.12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                color: kprimaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: Offset(2, 1), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: '$img',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(), // Loading spinner
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.red,
                  ), // Display an error icon
                )),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            SizedBox(
              width: res_width * 0.27,
              child: Center(
                child: Text(
                  "$txt",
                  style: TextStyle(fontSize: responsiveFontSize),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  itmBox({img, tx, dx, rt, rv, id, specs, userId, desc, msg, delivery_charges}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Get.to(routeName: "PD", () => ProductDetailScreen(id, tx, int.parse(dx.toString()), rt, img, specs, userId, desc, msg, delivery_charges));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 0, left: 10, right: 10),
        child: Column(
          children: [
            Container(
              height: res_height * 0.20,
              decoration: BoxDecoration(),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: AppUrl.baseUrlM + img,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(), // Loading spinner
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.red,
                    ), // Display an error icon
                  )),
            ),
            SizedBox(
              height: res_height * 0.005,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$tx',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: res_height * 0.003,
                  ),
                  Text(
                    '${dx.toString()} \$',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$rt ',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        '$rv',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.001,
                  )
                ],
              ),
            ),
            SizedBox(
              height: res_height * 0.001,
            )
          ],
        ),
      ),
    );
  }

  /////////////////////////////////
  Future<CategoryList> getCategoryList() async {
    dynamic response = await http.get(Uri.parse(AppUrl.categoryGetUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return CategoryList.fromJson(data);
    } else {
      throw Exception("Error");
    }
  }
}
