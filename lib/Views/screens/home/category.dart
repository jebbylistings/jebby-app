import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jared/Views/helper/colors.dart';

import 'package:get/get.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:jared/model/categoryList_model.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:jared/view_model/auth_view_model.dart';
import 'package:jared/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../res/app_url.dart';
import '../../../view_model/category_get_View_model.dart';
import '../mainfolder/drawer.dart';
import 'Electronics.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
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
                      })
                    }
                  else
                    {
                      setState(() {
                        _categoryList = List;
                        print("GetAllProducts");
                        print(_categoryList!.data);
                        // print(widget.word);
                        // runFilter(widget.word.toString());
                        // print(results[0].price.toString());
                        isLoading = false;
                        isError = false;
                        emptyData = false;
                      })
                    }
                }
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
                        print("Error:  ${error}");
                      })
                    }
                }
            });
  }

  void runFilter() {
    if (searchController.text.isEmpty) {
      results = _categoryList!.data!;
    } else {
      results = _categoryList!.data!.where((product) => product.name!.toLowerCase().contains(searchController.text.toLowerCase())).toList();
    }
  }

  String? role;

  void getRole() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    role = sp.getString("role").toString();
    print("role $role ");
  }

  void initState() {
    getProducts();
    getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    GetAPiFromModel getAPiFromModel = GetAPiFromModel();
    final userName = context.watch<AuthViewModel>();

    return Scaffold(
      key: _key,
      // drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
            // _key.currentState!.openDrawer();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        actions: [
          Visibility(
            visible: role != null && role != "Guest",
            child: GestureDetector(
              onTap: () {
                Get.to(() => MyProfileScreen());
              },
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: Container(
                  child: Image.asset('assets/slicing/avatar.png'),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: res_height * 0.03),
              Container(
                // width: res_width * 0.9,
                child: TextFormField(
                  onChanged: (value) {},
                  controller: searchController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (searchController.text.isNotEmpty) {
                          print(searchController.text);
                          runFilter();
                        }
                      },
                      icon: Icon(
                        Icons.search_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    hintText: "Search Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Featured Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
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
                    return Wrap(
                      spacing: 1,
                      runSpacing: 5,
                      children: List.generate(snapshot.data!.data!.length, (index) {
                        return data[index].status == 1
                            ? contBox(txt: data[index].name, img: '${AppUrl.baseUrlM}${data[index].image}', id: data[index].id.toString())
                            : SizedBox.shrink(); // Use SizedBox.shrink() to render nothing
                      }),
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
    return GestureDetector(
      onTap: () {
        Get.to(() => ElectronicsScreen(categoryname: txt, id: id));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 5, top: 5),
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
                padding: const EdgeInsets.all(20.0),
                child: Image.network(
                  '$img',
                ),
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
                  overflow: TextOverflow.ellipsis, // Specify overflow behavior
                  maxLines: 1, // Limit to a single line
                ),
              ),
            )
          ],
        ),
      ),
    );
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
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 5, top: 5),
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
                padding: const EdgeInsets.all(20.0),
                child: Image.network(
                  '$img',
                ),
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
                  overflow: TextOverflow.ellipsis, // Specify overflow behavior
                  maxLines: 1, // Limit to a single line
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
