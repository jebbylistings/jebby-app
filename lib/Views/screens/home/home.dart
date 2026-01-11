import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Services/provider/sign_in_provider.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/auth/ProductDetail.dart';
import 'package:jebby/Views/screens/home/Categoriesss.dart';
import 'package:jebby/Views/screens/home/Electronics.dart';
import 'package:http/http.dart' as http;
import '../../../model/getFeaturedProductsModel.dart' as datamodel;

import 'package:jebby/Views/screens/home/messages.dart';
import 'package:jebby/Views/screens/mainfolder/drawer.dart';
import 'package:jebby/Views/screens/profile/myprofile.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/screens/home/searchData.dart';
import 'package:jebby/model/categoryList_model.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/view_model/auth_view_model.dart';
import 'package:jebby/view_model/category_get_View_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../model/user_model.dart';
import '../../../res/app_url.dart';

import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, num? activeIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

TextEditingController searchController = TextEditingController();

class _HomeScreenState extends State<HomeScreen> {
  var fromdate;
  var todate;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();

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
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getFeaturedProducts() {
    ApiRepository.shared.featuredProducts(
      (List) {
        if (this.mounted) {
          //List.data!.add(RelatedProducts(id: 1,productId: 1,relatedProductId: 1,)) ;
          List.data!.add(
            datamodel.Data(
              image:
                  "https://ik.imagekit.io/bdxxrsiix/15dd61ccbf734ed731469433dcf97363a454ec45.jpg",
              id: 1,
              subcategoryId: 1,
              name: 'OUTDOORS',
              specifications: 'Outdoor Folding Chairs – Perfect for Parties',
              price: 100,
              isReview: 0,
              stars: '5',
            ),
          );

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
      },
      (error) {
        setState(() {
          isLoading = true;
          isError = false;
          isEmpty = true;
        });
      },
    );
  }

  bool isLoading1 = true;
  bool isError1 = false;
  bool isEmpty1 = false;

  getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
      (List) {
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
      },
      (error) {
        if (error != null) {
          setState(() {
            isEmpty1 = false;
            isLoading1 = true;
            isError1 = true;
          });
        }
      },
    );
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool('time') == false
        ? notiTimer().timer?.cancel()
        : notiTimer().timer =
            prefs.getBool('time') == false
                ? notiTimer().timer?.cancel()
                : new Timer.periodic(Duration(seconds: 5), (_) {
                  if (token == null ||
                      token == "" ||
                      role == "" ||
                      role == null ||
                      prefs.getBool('time') != true) {
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

  var myFormat = DateFormat('MM/dd/yyyy');

  double starss = 0.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    context.watch<AuthViewModel>();
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    GetAPiFromModel getAPiFromModel = GetAPiFromModel();

    return Container(
      width: double.infinity,
      child: Scaffold(
        key: _key,
        drawer: DrawerScreen(),

        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     'Home',
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //       fontSize: 19,
        //     ),
        //   ),
        //   leading: InkWell(
        //     onTap: () {
        //       _key.currentState!.openDrawer();
        //     },
        //     borderRadius: BorderRadius.circular(50),
        //     child: Padding(
        //       padding: const EdgeInsets.all(17.0),
        //       child: Container(
        //         child: Image.asset('assets/slicing/hamburger.png'),
        //       ),
        //     ),
        //   ),
        //   actions: [
        //     Stack(
        //       children: [
        //         Visibility(
        //           visible: role != null && role != "Guest",
        //           child: GestureDetector(
        //             onTap: () {
        //               seenNotification();
        //               Get.to(() => MessageScreen());
        //             },
        //             child: Padding(
        //               padding: const EdgeInsets.only(
        //                 top: 18.0,
        //                 bottom: 18.0,
        //                 right: 7,
        //               ),
        //               child: Icon(
        //                 Icons.notifications_none,
        //                 color: Colors.black,
        //               ),
        //             ),
        //           ),
        //         ),
        //         isLoading1
        //             ? SizedBox()
        //             : ApiRepository.shared.getNotificationModelList!.unseen
        //                     .toString() ==
        //                 "0"
        //             ? SizedBox()
        //             : Visibility(
        //               visible: role != null && role != "Guest",
        //               child: Positioned(
        //                 top: 4,
        //                 right: 0,
        //                 child: Container(
        //                   padding: EdgeInsets.all(2),
        //                   decoration: BoxDecoration(
        //                     color: kprimaryColor,
        //                     borderRadius: BorderRadius.circular(10),
        //                   ),
        //                   constraints: BoxConstraints(
        //                     minWidth: 16,
        //                     minHeight: 16,
        //                   ),
        //                   child: Text(
        //                     isLoading1
        //                         ? ""
        //                         : ApiRepository
        //                                 .shared
        //                                 .getNotificationModelList!
        //                                 .unseen
        //                                 .toString() ==
        //                             "0"
        //                         ? ""
        //                         : ApiRepository
        //                             .shared
        //                             .getNotificationModelList!
        //                             .unseen
        //                             .toString(),
        //                     style: TextStyle(color: Colors.white, fontSize: 10),
        //                     textAlign: TextAlign.center,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //       ],
        //     ),
        //     Visibility(
        //       visible: role != null && role != "Guest",
        //       child: GestureDetector(
        //         onTap: () {
        //           Get.to(() => MyProfileScreen());
        //         },
        //         child: Padding(
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 19.0,
        //             vertical: 18.0,
        //           ),
        //           child: Icon(
        //             Icons.person_outline,
        //             color: Colors.black,
        //             size: 25,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(220),
          child: Builder(
            builder: (context) {
              final top = MediaQuery.of(context).padding.top;
              const radius = 26.0;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      // Orange curved header
                      Container(
                        height: 220,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(radius),
                            bottomRight: Radius.circular(radius),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(16, top + 12, 16, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RoundIconButton(
                              onTap: () {
                                _key.currentState!.openDrawer();
                              },
                              bg: Colors.transparent,
                              image: const AssetImage(
                                'assets/slicing/mingcute_menu-fill.png',
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back, ${fullname}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '123 Maple Street, CA 1200',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Row(
                              children: [
                                Visibility(
                                  visible: role != null && role != "Guest",
                                  child: _CircleAction(
                                    onTap: () {
                                      seenNotification();
                                      Get.to(() => MessageScreen());
                                    },
                                    image: const AssetImage(
                                      'assets/slicing/notificationnew.png',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),
                                Visibility(
                                  visible: role != null && role != "Guest",
                                  child: _CircleAction(
                                    onTap: () {
                                      Get.to(() => MyProfileScreen());
                                    },
                                    image: const AssetImage(
                                      'assets/slicing/personnew.png',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ✅ Search bar floating at bottom
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 26,
                        child: _SearchField(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // SizedBox(height: 20),
                // Row(
                //   children: [
                //     Container(
                //       width: res_width * 0.94,
                //       child: TextFormField(
                //         onChanged: (value) {},
                //         controller: searchController,
                //         style: const TextStyle(
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //         ),
                //         decoration: InputDecoration(
                //           suffixIcon: InkWell(
                //             onTap: () {
                //               if (searchController.text.isNotEmpty) {
                //                 Navigator.of(context).push(
                //                   MaterialPageRoute(
                //                     builder:
                //                         (context) => SearchData(
                //                           word: searchController.text,
                //                         ),
                //                   ),
                //                 );
                //               }
                //             },
                //             child: Icon(Icons.search, color: kprimaryColor),
                //           ),
                //           border: OutlineInputBorder(
                //             borderRadius: BorderRadius.circular(15.0),
                //           ),
                //           enabledBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: kprimaryColor,
                //               width: 1,
                //             ),
                //             borderRadius: const BorderRadius.all(
                //               Radius.circular(15),
                //             ),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: kprimaryColor,
                //               width: 1,
                //             ),
                //             borderRadius: const BorderRadius.all(
                //               Radius.circular(15),
                //             ),
                //           ),
                //           filled: true,
                //           hintStyle: const TextStyle(
                //             color: Colors.grey,
                //             fontSize: 15,
                //           ),
                //           hintText: "Product Name",
                //           fillColor: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: res_height * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Featured Items!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
                SizedBox(height: 10),
                isLoading
                    ? Text("")
                    : isEmpty
                    ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("No items available currently"),
                )
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.5,

                  ),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                  ApiRepository
                      .shared
                      .getFeaturedProductsModelList!
                      .data!
                      .length,
                  itemBuilder: (context, int index) {
                    var data =
                    ApiRepository
                        .shared
                        .getFeaturedProductsModelList!
                        .data![index];
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
                  },
                ),
                //SizedBox(height: res_height * 0.001),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CategoriesssScreen());
                        },
                        child: Container(
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getAPiFromModel.getCategoryList(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<CategoryList> snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      final data = snapshot.data!.data;

                      return Container(
                        width: res_width,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(6),
                          //                        physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),

                          itemCount: snapshot.data!.data!.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            // Wider than tall to match your screenshot card shape
                            childAspectRatio: 1.2,
                          ),
                          itemBuilder: (context, index) {
                            // final item = items[index];

                            return contBox(
                              txt: data![index].name,
                              img: '${AppUrl.baseUrlM}${data[index].image}',
                              id: data[index].id.toString(),
                            );
                          },
                        ),
                      );

                      // return Wrap(
                      //   spacing: 1,
                      //   runSpacing: 5,
                      //   children: List.generate(snapshot.data!.data!.length, (
                      //     index,
                      //   ) {
                      //     return data![index].status == 0
                      //         ? Text("")
                      //         : contBox(
                      //           txt: data[index].name,
                      //           img: '${AppUrl.baseUrlM}${data[index].image}',
                      //           id: data[index].id.toString(),
                      //         );
                      //   }),
                      // );
                    }
                  },
                ),
                SizedBox(height: res_height * 0.02),

                SizedBox(height: res_height * 0.05),
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
    double height = 160;
    double borderRadius = 20;
    double scrimStrength = 0.05;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(
            () => ElectronicsScreen(categoryname: txt, id: id, pictureurl: img),
          );
        },
        child: SizedBox(
          width: res_width * 0.45,
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              // Image(
              //   image: imageProvider,
              //   fit: BoxFit.cover,
              // ),
              CachedNetworkImage(
                imageUrl: '$img',
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Center(
                      child: CircularProgressIndicator(), // Loading spinner
                    ),
                errorWidget:
                    (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.red,
                    ), // Display an error icon
              ),

              // Universal darken layer (ensures white text works on any image)
              Container(color: Colors.black.withOpacity(scrimStrength)),

              // Extra bottom gradient for stronger contrast near text
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$txt",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.1,
                            letterSpacing: -0.2,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0 Subcategories',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        shadows: const [
                          Shadow(blurRadius: 3, color: Colors.black45),
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

    return GestureDetector(
      onTap: () {
        Get.to(() => ElectronicsScreen(categoryname: txt, id: id));
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
                borderRadius: BorderRadius.all(Radius.circular(18)),
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
                    placeholder:
                        (context, url) => Center(
                          child: CircularProgressIndicator(), // Loading spinner
                        ),
                    errorWidget:
                        (context, url, error) => Icon(
                          Icons.error,
                          color: Colors.red,
                        ), // Display an error icon
                  ),
                ),
              ),
            ),
            SizedBox(height: 6),
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
            ),
          ],
        ),
      ),
    );
  }

  itmBox({
    img,
    tx,
    dx,
    rt,
    rv,
    id,
    specs,
    userId,
    desc,
    msg,
    delivery_charges,
  }) {
    double res_height = MediaQuery.of(context).size.height;
    double res_width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Get.to(
          routeName: "PD",
          () => ProductDetailScreen(
            id,
            tx,
            int.parse(dx.toString()),
            rt,
            img,
            specs,
            userId,
            desc,
            msg,
            delivery_charges,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 0, left: 5, right: 5),
        child: Column(
          children: [
            Container(
              height: res_height * 0.27,
              width: res_width,
              decoration: BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: id == "1" ? img : AppUrl.baseUrlM + img,
                      fit: BoxFit.cover,
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

                    // Dark gradient overlay (bottom)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Rating badge (top-left)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/newpacks/star.png',width: 25,height: 25,),
                            SizedBox(width: 6),
                            Text(
                              "$rt",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Price badge (top-right)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "\$${dx.toString()} per day",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Bottom text content
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$tx",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Outdoor Folding Chairs – Perfect for Parties",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Downtown LA, 2 miles away",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
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
            // SizedBox(height: res_height * 0.005),
            // Container(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Text('$tx', style: TextStyle(fontSize: 15)),
            //       SizedBox(height: res_height * 0.003),
            //       Text(
            //         '${dx.toString()} \$',
            //         style: TextStyle(fontSize: 13),
            //         textAlign: TextAlign.left,
            //       ),
            //       Row(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text('$rt ', style: TextStyle(fontSize: 11)),
            //           Text(
            //             '$rv',
            //             style: TextStyle(fontSize: 11, color: Colors.grey),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: res_height * 0.001),
            //     ],
            //   ),
            // ),
            SizedBox(height: res_height * 0.001),
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

class CurvedHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CurvedHeaderAppBar({super.key});

  static const _radius = 26.0;

  @override
  Size get preferredSize => const Size.fromHeight(200);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top; // status bar / notch
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white status-bar content
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              height: preferredSize.height,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_radius),
                  bottomRight: Radius.circular(_radius),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, top + 12, 16, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left hamburger
                  _RoundIconButton(
                    onTap: () {},
                    bg: Colors.transparent,
                    // border: Colors.white.withOpacity(.85),
                    image: const AssetImage(
                      'assets/slicing/mingcute_menu-fill.png',
                    ),
                  ),

                  const SizedBox(width: 12),
                  // Title + address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome Back, John',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '123 Maple Street, CA 1200',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right round actions
                  Row(
                    children: [
                      _CircleAction(
                        onTap: () {},
                        image: const AssetImage(
                          'assets/slicing/notificationnew.png',
                        ),
                      ),
                      const SizedBox(width: 10),
                      _CircleAction(
                        onTap: () {},
                        image: const AssetImage('assets/slicing/personnew.png'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Big rounded search field overlapping the bottom curve
            Positioned(
              left: 16,
              right: 16,
              bottom: 16, // hangs slightly below the header
              child: _SearchField(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.onTap,
    this.icon,
    this.image,
    this.size = 20,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final ImageProvider? image; // 👈 custom image support
  final double size; // 👈 size controller

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child:
                image != null
                    ? Image(
                      image: image!,
                      height: size,
                      width: size,
                      fit: BoxFit.contain,
                    )
                    : Icon(icon, size: size, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.onTap,
    this.bg = Colors.white,
    this.border,
    this.icon,
    this.image, // 👈 ADDED
    this.size = 22, // 👈 control icon/image size
  });

  final VoidCallback onTap;
  final Color bg;
  final Color? border;
  final IconData? icon; // If using Flutter Icons
  final ImageProvider? image; // 👈 Your custom image
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border ?? Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child:
                image != null
                    ? Image(
                      image: image!,
                      height: size,
                      width: size,
                      fit: BoxFit.contain,
                    )
                    : Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by Product Name',

          // prefixIcon: const Icon(Icons.search),
          prefixIcon: InkWell(
            onTap: () {
              if (searchController.text.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => SearchData(word: searchController.text),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/slicing/searchnew.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
