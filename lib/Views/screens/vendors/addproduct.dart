import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/vendors/addproduct2.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart' as d;
import 'package:provider/provider.dart';

import '../../../view_model/user_view_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
   String Url = dotenv.env['baseUrlM'] ?? 'No url found';
  bool addBtn = false;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];
  List imagesPath = [];
  bool switchnot = false;
  bool insRentSwitchNot = false;
  bool messageSwitchNot = false;
  bool isError = false;
  bool isLoading = true;
  bool sub_categoryLoader = true;
  bool sub_categoryError = false;
  bool vendorProductLoader = true;
  bool vendorProductError = false;
  late var sub_length;
  late var sub_name;
  late var sub_id;
  late var name_length;
  late var category_name;
  late var category_id;
  late String dropdownValue = "Select";
  String sub_dropdownvalue = "Sub Category";
  String selectedValue = "select";
  String sub_selectedvalue = "select";
  List<String> sub_items = [];
  List sub_items_id = [];
  List<String> items = [];
  List items_id = [];
  late var selected_id;
  late var selected_sub_id;
  bool subCategoryVisibility = false;
  TextEditingController productController = TextEditingController();
  TextEditingController specsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController rentPriceController = TextEditingController();
  TextEditingController SecurityDepositeController = TextEditingController();
  TextEditingController deliveryChargesController = TextEditingController();
  TextEditingController negotiationController = TextEditingController();
  bool relatedProdIcon = true;
  late String productName;
  var relatedProductsId = [];
  List<dynamic> image_document = [];

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      getCategory();
    });
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
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      vendorProducts(id);
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  getSubCategory(id) {
    ApiRepository.shared.getSubCategoryList(
        (list) => {
              if (this.mounted)
                {
                  if (list.status == 0)
                    {sub_items.add("No Category Found")}
                  else
                    {
                      sub_items = [],
                      sub_items_id = [],
                      sub_length = ApiRepository.shared.subCategoryList?.data?.length,
                      for (int i = 0; i < sub_length!; i++)
                        {
                          sub_name = ApiRepository.shared.subCategoryList?.data?[i].name,
                          sub_id = ApiRepository.shared.subCategoryList?.data?[i].id,
                          sub_items.add(sub_name),
                          sub_items_id.add(sub_id),
                        },
                      print("Sub CATEGORY LIST --> ${sub_items}"),
                      print("Sub Category ID ---->> ${sub_items_id}"),
                      selected_sub_id = sub_items_id[0],
                      print("PRINT Selected_Sub CATEG ID ${selected_sub_id}"),
                      setState(() {
                        sub_dropdownvalue = sub_items.first;
                        sub_categoryLoader = false;
                        sub_categoryError = false;
                        subCategoryVisibility = true;
                      }),
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    sub_categoryError = true;
                    // isLoading = false;
                  }),
                },
            },
        id.toString());
  }

  getCategory() {
    ApiRepository.shared.getCategoryList(
        (List) => {
              if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      name_length = ApiRepository.shared.categoryList?.data?.length,
                      for (int i = 0; i <= name_length; i++)
                        {
                          category_name = ApiRepository.shared.categoryList?.data?[i].name,
                          category_id = ApiRepository.shared.categoryList?.data?[i].id,
                          items.add(category_name.toString()),
                          items_id.add(category_id),
                        },
                      print("CATEGORY LIST --> ${items}"),
                      print("Category ID ---->> ${items_id}"),
                      selected_id = items_id[0],
                      print("PRINT SELECTED CATEG ID ${selected_id}"),
                      setState(() {
                        dropdownValue = items.first;
                        isLoading = false;
                        isError = true;
                      }),
                    }
                  else
                    {
                      name_length = ApiRepository.shared.categoryList?.data?.length,
                      for (int i = 0; i < name_length; i++)
                        {
                          category_name = ApiRepository.shared.categoryList?.data?[i].name,
                          category_id = ApiRepository.shared.categoryList?.data?[i].id,
                          items.add(category_name.toString()),
                          items_id.add(category_id),
                        },
                      print("CATEGORY LIST --> ${items}"),
                      print("Category ID ---->> ${items_id}"),
                      selected_id = items_id[0],
                      print("PRINT SELECTED CATEG ID ${selected_id}"),
                      setState(() {
                        dropdownValue = items.first;
                        print("EXEXEXEXEXEXE");
                        isLoading = false;
                      }),
                    }
                },
            },
        (error) => {
              if (this.mounted)
                {
                  if (error != null)
                    {
                      setState(() {
                        isLoading = false;
                        isError = true;
                        print("Error:  ${error}");
                      }),
                    }
                }
            });
    ApiRepository.shared.checkApiStatus(true, "categoryList");
  }

  void selectImages() async {
    try {
      List<XFile>? selectedImages = await imagePicker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        for (XFile image in selectedImages) {
          var temp_image = File(image.path);
          imagesPath.add(temp_image);
        }
        imageFileList.addAll(selectedImages);
      }
      print("Image List Length:" + imageFileList.length.toString());
      print(imageFileList);
      print("Image Path Length:" + imagesPath.length.toString());
      print(imagesPath);
      setState(() {});
    } catch (e) {
      print("ERROR IN UPLOADING IMAGE");
    }
  }

  vendorProducts(user_id) {
    ApiRepository.shared.getVendorProductList(
        (list) => {
              if (this.mounted)
                {
                  ApiRepository.shared.checkApiStatus(false, "getVendorProductList"),
                  setState(() {
                    vendorProductLoader = false;
                  }),
                  if (list.data?.length == 0)
                    {
                      setState(() {
                        vendorProductError = true;
                      }),
                    }
                  else
                    {vendorProductLoader = false}
                }
            }, (error) {
      if (error != null) {
        // ApiRepository.shared.checkApiStatus(false, "getVendorProductList");
        setState(() {
          vendorProductError = true;
          vendorProductLoader = false;
        });
      }
    }, user_id);
  }

  addProduct() async {
    setState(() {
      addBtn = true;
    });
    if (productController.text.isNotEmpty &&
        imagesPath.length > 0 &&
        specsController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        rentPriceController.text.isNotEmpty &&
        selected_id != null &&
        selected_sub_id != null) {
          
      for (int i = 0; i < imagesPath.length; i++) {
        String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
        String filename = p.basename(imageFileList[i].path);
        image_document.add(await d.MultipartFile.fromFile(imageFileList[i].path, filename: uniqueName));
        print(uniqueName);
        print(imageFileList[i].path);
      }
      var data = {
        "file": image_document,
        "user_id": id.toString(),
        "category_id": selected_id.toString(),
        "subcategory_id": selected_sub_id.toString(),
        "name": productController.text.toString(),
        "price": rentPriceController.text.toString(),
        "delivery_charges": deliveryChargesController.text.toString().isEmpty ? "0" : deliveryChargesController.text.toString(),
        "specifications": specsController.text.toString(),
        "service_agreements": descriptionController.text.toString(),
        "negotiation": negotiationController.text.toString().isEmpty ? "0" : negotiationController.text.toString(),
        "array": relatedProductsId.length == 1 ? [relatedProductsId] : relatedProductsId,
        "isMessage": "1"
      };
      print("dataaaaaaaaaaaaaaaaaaaaa");
      print(data);
      try {
        // print("hello length , ${relatedProductsId}");
        d.FormData formData = new d.FormData.fromMap(data);
        d.Response response = await Dio().post("${Url}/productInsert", data: formData);

        print("API HIT SUCESSFULL");
        print("---> ID  ${id}");
        print('response $response');
        if (response.toString() == 'Your files uploaded.') {
          final snackBar = new SnackBar(content: new Text("Uploaded"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            addBtn = false;
          });
          Get.off(() => AddProduct2Screen(
                user_id: id,
                SecurityDeposite: SecurityDepositeController.text.toString(),
              ));
        } else {
          final snackBar = new SnackBar(content: new Text(response.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            addBtn = false;
          });
          print(response.toString());
        }
      } catch (e) {
        print("ERROR IN POSTING DATA " + e.toString());
      }
    } else {
      print("----> ID ${id}");
      print("UNSUCESSFULL HIT");
      final snackBar = new SnackBar(content: new Text("Fields Cannot Be Empty"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      addBtn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();

    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'General Information',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: res_width * 0.9,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Product Name',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      child: Text(
                        'This information helps you and your customers identify the products on orders, documents and in the online store',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        controller: productController,
                        decoration: InputDecoration(
                          hintText: "eg : ipad",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Add Photo or Video',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    imagesPath.length == 0
                        ? Container(
                            width: res_width * 0.9,
                            height: res_height * 0.2,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kprimaryColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              width: res_width * 0.2,
                              height: res_height * 0.15,
                              // child: ImageIcon(
                              //   AssetImage('assets/slicing/upload-cloud.png'),
                              // ),
                              child: InkWell(
                                onTap: () {
                                  selectImages();
                                  // imagePath();
                                },
                                child: Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 25,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 100,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) => SizedBox(
                                      width: 10,
                                    ),
                                // physics: NeverScrollableScrollPhysics(),
                                itemCount: imagesPath.length,
                                itemBuilder: (context, int index) {
                                  return Container(
                                    child: Image.file(File(imageFileList[index].path)),
                                    // Image.network(AppUrl.baseUrlM +
                                    //     "/resources/static/assets/uploads/products/image_picker968263936832331487.jpg"),
                                  );
                                }),
                          ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Container(
                        //   child: Row(
                        //     children: [
                        //       tag(),
                        //       SizedBox(
                        //         width: res_width * 0.01,
                        //       ),
                        //       tag(),
                        //       SizedBox(
                        //         width: res_width * 0.01,
                        //       ),
                        //       tag(),
                        //     ],
                        //   ),
                        // ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Discount',
                        //       // 'Negotiation',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 17,
                        //       ),
                        //     ),
                        //     Transform.scale(
                        //       scale: 0.6,
                        //       child: CupertinoSwitch(
                        //         activeColor: Color.fromARGB(255, 210, 210, 210),
                        //         trackColor: Color.fromARGB(255, 235, 235, 235),
                        //         thumbColor: switchnot ? Color.fromARGB(255, 173, 173, 173) : Color(0xff00ff01),
                        //         value: switchnot,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             print("Negotiation ${switchnot}");
                        //             switchnot = value;
                        //           });
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Specs',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        controller: specsController,
                        decoration: InputDecoration(
                          hintText: "Enter Details",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: "Enter Details",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: isLoading
                          ? Center(
                              child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
                            )
                          : FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              return DropdownButton<String>(
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    dropdownValue = value!;
                                    print(dropdownValue);
                                    print(items_id[items.indexOf(dropdownValue)]);
                                    selected_id = items_id[items.indexOf(dropdownValue)];
                                    print("selected ID ${selected_id}");
                                    sub_id = [];
                                    sub_items = [];
                                    getSubCategory(selected_id);
                                  });
                                },
                                items: items.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              );
                              ;
                            }, future: null,),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Sub Category',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: sub_categoryLoader
                          ? SizedBox(height: 25, width: 25, child: Text("Please Select The Category"))
                          : Visibility(
                              visible: subCategoryVisibility,
                              child: FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                return DropdownButton<String>(
                                  value: sub_dropdownvalue,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      sub_dropdownvalue = value!;
                                      print("SubDropDown --> ${sub_dropdownvalue}");
                                      selected_sub_id = sub_items_id[sub_items.indexOf(sub_dropdownvalue)];
                                      print("SelectedSubID --> ${selected_sub_id}");
                                    });
                                  },
                                  items: sub_items.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                );
                                ;
                              }, future: null,),
                            ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Rent Price per day',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: rentPriceController,
                        decoration: InputDecoration(
                          hintText: 'Add Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Security Deposit',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: SecurityDepositeController,
                        decoration: InputDecoration(
                          hintText: 'Add Security Deposit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Delivery Charges',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      height: 50,
                      width: res_width * 0.9,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: deliveryChargesController,
                        decoration: InputDecoration(
                          hintText: 'Add Delivery',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: res_height * 0.01,
                    // ),
                    // Visibility(
                    //   visible: switchnot ? false : true,
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         'Discount Margin in %',
                    //         // 'Negotiation Margin in %',
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.normal,
                    //           color: Colors.black,
                    //           fontSize: 15,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.01,
                    // ),
                    // Visibility(
                    //   visible: switchnot ? false : true,
                    //   child: Container(
                    //     height: 50,
                    //     width: res_width * 0.9,
                    //     child: TextField(
                    //       keyboardType: TextInputType.number,
                    //       controller: negotiationController,
                    //       decoration: InputDecoration(
                    //         hintText: 'Enter Discount',
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.circular(15.0),
                    //         ),
                    //         enabledBorder: const OutlineInputBorder(
                    //           borderSide: const BorderSide(color: kprimaryColor, width: 1),
                    //           borderRadius: BorderRadius.all(Radius.circular(15)),
                    //         ),
                    //         focusedBorder: const OutlineInputBorder(
                    //           borderSide: const BorderSide(color: kprimaryColor, width: 1),
                    //           borderRadius: BorderRadius.all(Radius.circular(15)),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.01,
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       'Instant Rent',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 17,
                    //       ),
                    //     ),
                    //     Transform.scale(
                    //       scale: 0.6,
                    //       child: CupertinoSwitch(
                    //         activeColor: Color.fromARGB(255, 210, 210, 210),
                    //         trackColor: Color.fromARGB(255, 235, 235, 235),
                    //         thumbColor: insRentSwitchNot ? Color.fromARGB(255, 173, 173, 173) : Color(0xff00ff01),
                    //         value: insRentSwitchNot,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             insRentSwitchNot = value;
                    //           });
                    //         },
                    //       ),
                    //     ),

                    //     // Row(
                    //     //   children: [
                    //     //     Text(
                    //     //       'Messaging',
                    //     //       style: TextStyle(
                    //     //         fontWeight: FontWeight.bold,
                    //     //         fontSize: 17,
                    //     //       ),
                    //     //     ),
                    //     //     Transform.scale(
                    //     //       scale: 0.6,
                    //     //       child: CupertinoSwitch(
                    //     //         activeColor: Color.fromARGB(255, 210, 210, 210),
                    //     //         trackColor: Color.fromARGB(255, 235, 235, 235),
                    //     //         thumbColor: messageSwitchNot
                    //     //             ? Color(0xff00ff01)
                    //     //             : Color.fromARGB(255, 173, 173, 173),
                    //     //         value: messageSwitchNot,
                    //     //         onChanged: (value) {
                    //     //           setState(() {
                    //     //             messageSwitchNot = value;
                    //     //             print("messageSwitchNot ${messageSwitchNot}");
                    //     //           });
                    //     //         },
                    //     //       ),
                    //     //     ),
                    //     //   ],
                    //     // )
                    //   ],
                    // ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          'Related Products',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Container(
                      child: vendorProductLoader
                          ? Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()))
                          : FutureBuilder(builder: (
                              context,
                              AsyncSnapshot<dynamic> snapshot,
                            ) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: ApiRepository.shared.VendorProductList?.data?.length,
                                  itemBuilder: (BuildContext context, index) {
                                    var name = ApiRepository.shared.VendorProductList?.data?[index].name;
                                    var product_id = ApiRepository.shared.VendorProductList?.data?[index].id;
                                    return ListTile(
                                      title: Text(name.toString()),
                                      trailing: relatedProductsId.contains(product_id)
                                          ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  relatedProductsId.remove(product_id);
                                                  print(relatedProductsId);
                                                });
                                              },
                                              child: Icon(Icons.delete_outline))
                                          : InkWell(
                                              onTap: () {
                                                setState(() {
                                                  relatedProductsId.add(product_id);
                                                  print(relatedProductsId);
                                                });
                                              },
                                              child: Icon(Icons.add)),
                                    );
                                  });
                            }, future: null,),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    GestureDetector(
                      // onTap: () async {
                      //   Get.to(() => AddProduct2Screen(SecurityDeposite : SecurityDepositeController.text.toString()));
                      // },
                      child: GestureDetector(
                        onTap: () {
                            addBtn ? null : addProduct();
                        },
                        child: Container(
                          width: 398,
                          height: 58,
                          child: Center(
                            child: Text(
                              addBtn ? "Uploading" : 'Next',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                            ),
                          ),
                          decoration:
                              BoxDecoration(color: addBtn ? kprimaryColor.withOpacity(0.5) : kprimaryColor, borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.02,
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

  tag() {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.13,
      height: res_height * 0.03,
      decoration: BoxDecoration(
        color: kprimaryColor,
        border: Border.all(
          color: kprimaryColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'TAG',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class RelProdIns extends ChangeNotifier {
  bool relatedProdIcon;

  RelProdIns({this.relatedProdIcon = true});

  changeIcon(value) {
    relatedProdIcon = value;
    notifyListeners();
    print(relatedProdIcon);
  }
}
