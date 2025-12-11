import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jebby/Views/controller/bottomcontroller.dart';
import 'package:jebby/Views/helper/colors.dart';

import 'package:get/get.dart';
import 'package:jebby/Views/screens/profile/myprofile.dart';
import 'package:jebby/model/categoryList_model.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../res/app_url.dart';
import '../../../res/color.dart';
import '../../../view_model/category_get_View_model.dart';
import 'Electronics.dart';
import 'messages.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
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

class _CategoryState extends State<Category> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController searchController = TextEditingController();
  CategoryList? _categoryList;
  List<Data> results = [];

  getProducts() {
    ApiRepository.shared.getCategoryList(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  emptyData = true;
                  _categoryList = List;
                }),
              }
            else
              {
                setState(() {
                  _categoryList = List;
                  // runFilter(widget.word.toString());
                  isLoading = false;
                  isError = false;
                  emptyData = false;
                }),
              },
          },
      },
      (error) => {
        if (this.mounted)
          {
            if (error != null)
              {
                setState(() {
                  isError = true;
                  isLoading = false;
                  emptyData = false;
                }),
              },
          },
      },
    );
  }

  void runFilter() {
    if (searchController.text.isEmpty) {
      results = _categoryList!.data!;
    } else {
      results =
          _categoryList!.data!
              .where(
                (product) => product.name!.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  String? role;

  void getRole() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    role = sp.getString("role").toString();
  }

  void initState() {
    getProducts();
    getRole();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    double res_height = MediaQuery.of(context).size.height;
    double res_width = MediaQuery.of(context).size.width;

    GetAPiFromModel getAPiFromModel = GetAPiFromModel();
    final bottomctrl = Get.put(BottomController());

    return Scaffold(
      key: _key,
      // drawer: DrawerScreen(),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      //   title: Text(
      //     'Categories',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.black,
      //       fontSize: 19,
      //     ),
      //   ),
      //   leading: InkWell(
      //     onTap: () {
      //       bottomctrl.navBarChange(0);
      //       Get.back();
      //       // _key.currentState!.openDrawer();
      //     },
      //     borderRadius: BorderRadius.circular(50),
      //     child: Icon(Icons.arrow_back, color: Colors.black),
      //   ),
      //   actions: [
      //     Visibility(
      //       visible: role != null && role != "Guest",
      //       child: GestureDetector(
      //         onTap: () {
      //           Get.to(() => MyProfileScreen());
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.all(19.0),
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
        preferredSize: const Size.fromHeight(120),
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
                    Container(
                      height: 120,
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


                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Featured Categories',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
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


                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: res_height * 0.03),
              //! Search Bar Commented out
              // Container(
              //   // width: res_width * 0.9,
              //   child: TextFormField(
              //     onChanged: (value) {},
              //     controller: searchController,
              //     decoration: InputDecoration(
              //       hintStyle: TextStyle(color: Colors.grey),
              //       suffixIcon: IconButton(
              //         onPressed: () {
              //           if (searchController.text.isNotEmpty) {
              //             runFilter();
              //           }
              //         },
              //         icon: Icon(
              //           Icons.search_outlined,
              //           color: Colors.grey,
              //         ),
              //       ),
              //       hintText: "Search Category",
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(15.0),
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: kprimaryColor, width: 1),
              //         borderRadius: BorderRadius.circular(15),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: kprimaryColor, width: 1),
              //         borderRadius: BorderRadius.circular(15),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: res_height * 0.03),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   child: Text(
              //     'Featured Categories',
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   ),
              // ),
              SizedBox(height: res_height * 0.01),
              FutureBuilder(
                future: getAPiFromModel.getCategoryList(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data!.data;
                    // return Wrap(
                    //   spacing: 1,
                    //   runSpacing: 5,
                    //   children: List.generate(snapshot.data!.data!.length, (
                    //     index,
                    //   ) {
                    //     return data[index].status == 1
                    //         ? contBox(
                    //           txt: data[index].name,
                    //           img: '${AppUrl.baseUrlM}${data[index].image}',
                    //           id: data[index].id.toString(),
                    //         )
                    //         : SizedBox.shrink(); // Use SizedBox.shrink() to render nothing
                    //   }),
                    // );
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
                  }
                },
              ),
              SizedBox(height: res_height * 0.07),
            ],
          ),
        ),
      ),
    );
  }

  contBox({txt, img, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double responsiveFontSize = res_width * 0.035;
    double borderRadius = 20;
    double scrimStrength = 0.05;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => ElectronicsScreen(categoryname: txt, id: id,pictureurl: img,));
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
    // return GestureDetector(
    //   onTap: () {
    //     Get.to(() => ElectronicsScreen(categoryname: txt, id: id));
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.all(5.5),
    //     child: Column(
    //       children: [
    //         SizedBox(height: 10),
    //         Container(
    //           margin: EdgeInsets.only(left: 5, top: 5),
    //           width: res_width * 0.25,
    //           height: res_height * 0.12,
    //           decoration: BoxDecoration(
    //             border: Border.all(color: Colors.white, width: 2),
    //             color: kprimaryColor,
    //             borderRadius: BorderRadius.all(Radius.circular(18)),
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.grey,
    //                 blurRadius: 5,
    //                 offset: Offset(2, 1), // Shadow position
    //               ),
    //             ],
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: ClipOval(
    //               child: CachedNetworkImage(
    //                 imageUrl: '$img',
    //                 fit: BoxFit.cover,
    //                 placeholder:
    //                     (context, url) => Center(
    //                       child: CircularProgressIndicator(), // Loading spinner
    //                     ),
    //                 errorWidget:
    //                     (context, url, error) => Icon(
    //                       Icons.error,
    //                       color: Colors.red,
    //                     ), // Display an error icon
    //               ),
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 6),
    //         SizedBox(
    //           width: res_width * 0.27,
    //           child: Center(
    //             child: Text(
    //               "$txt",
    //               style: TextStyle(fontSize: responsiveFontSize),
    //               overflow: TextOverflow.ellipsis, // Specify overflow behavior
    //               maxLines: 1, // Limit to a single line
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  contBox1({txt, img, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double responsiveFontSize = res_width * 0.035;
    return GestureDetector(
      onTap: () {
        Get.to(() => ElectronicsScreen(categoryname: txt, id: id));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 5, top: 5),
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
                padding: const EdgeInsets.all(20.0),
                child: Image.network('$img'),
              ),
            ),
            SizedBox(height: 6),
            SizedBox(
              width: res_width * 0.27,
              child: Center(
                child: Text(
                  "$txt",
                  style: TextStyle(fontSize: responsiveFontSize),
                  overflow: TextOverflow.ellipsis, // Specify overflow behavior
                  maxLines: 1, // Limit to a single line
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
