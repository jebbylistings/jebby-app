import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/vendors/ProductList.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as d;
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/getProductsByProductId.dart';
import '../../../model/productDeleteModelImage.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../../controller/bottomcontroller.dart';
import '../mainfolder/homemain.dart';

class EditProductScreen extends StatefulWidget {
  var category_id;
  var sub_category_id;
  var name;
  var price;
  var specifications;
  var description;
  var negotiation;
  var product_id;
  var relProd;
  var images;
  var imageID;
  var messageStatus;
  var delivery_charges;

  EditProductScreen({
    this.category_id,
    this.sub_category_id,
    this.name,
    this.price,
    this.specifications,
    this.description,
    this.negotiation,
    this.product_id,
    this.relProd,
    this.images,
    this.imageID,
    this.messageStatus,
    this.delivery_charges,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // bool switchnot = false;
  bool insRentSwitchNot = false;
  bool messageSwitchNot = false;
  bool product_update_button = false;
  bool img_button = false;
  bool imgLoader = false;
  int _groupValue = -1;
  String dropdownValue = 'One';
  bool switchnot = true;
  // var imageList = [];
  // var imageID = [];
  var relProdArray = [];
  bool catLoader = true;
  bool catError = false;
  bool sub_catLoader = true;
  bool sub_catError = false;
  bool cats_loader = true;
  bool sub_cats_loader = true;
  late String dropdownvalue;
  late String sub_dropdownvalue;
  String selectedValue = "select";
  String sub_selectedvalue = "select";
  List<String> sub_items = [];
  List sub_items_id = [];
  List<String> items = [];
  List items_id = [];
  late var selected_id;
  late var selected_sub_id;
  late var sub_name;
  late var sub_id;
  late var sub_length;
  List<XFile> imageFileList = [];
  List imagesPath = [];
  List<dynamic> image_document = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController specsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController negotiationController = TextEditingController();
  TextEditingController rentPriceController = TextEditingController();
  TextEditingController deliverychargesController = TextEditingController();
  TextEditingController price_1_Controller = TextEditingController();
  TextEditingController price_2_Controller = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController perController = TextEditingController();
  TextEditingController SecurityDepositeController = TextEditingController();

  var pasd = ApiRepository.shared.getProductsByIdList?.data![0].pastart.toString();
  var paed = ApiRepository.shared.getProductsByIdList?.data![0].paend.toString();
  var dasd = ApiRepository.shared.getProductsByIdList?.data![0].dastart.toString();
  var daed = ApiRepository.shared.getProductsByIdList?.data![0].daend.toString();
  var price_1 = ApiRepository.shared.getProductsByIdList?.data![0].price1.toString();
  var per = ApiRepository.shared.getProductsByIdList?.data![0].per.toString();
  var dis = ApiRepository.shared.getProductsByIdList?.data![0].discount.toString();
  var freePU = ApiRepository.shared.getProductsByIdList?.data![0].fp.toString();
  var locationBD = ApiRepository.shared.getProductsByIdList?.data![0].lbd.toString();

  var security_deposit = ApiRepository.shared.getProductsByIdList?.data![0].security_deposit.toString();

  var price_2 = ApiRepository.shared.getProductsByIdList?.data![0].price.toString();
  late var name_length;
  late var category_name;
  late var category_id;
  late var cat_value;
  late var sub_cat_value;

  void initState() {
    assign();
    getCatId();
    getSubCatID();
    getData();
    profileData(context);
    getCategory();
    print("related products ${widget.relProd}");
    // relP();
    super.initState();
  }

  bool negotiationVisibility = true;

  void assign() {
    switchnot = widget.negotiation.toString() == "0" ? true : false;
    print("switch not ${widget.negotiation.toString()}");
    negotiationVisibility = widget.negotiation.toString() == "0" ? false : true;
    messageSwitchNot = widget.messageStatus == 1 ? true : false;
    price_2 = ApiRepository.shared.getProductsByIdList?.data![0].price.toString();
    price_1 = ApiRepository.shared.getProductsByIdList?.data![0].price1.toString();
    per = ApiRepository.shared.getProductsByIdList?.data![0].per.toString();
    dis = ApiRepository.shared.getProductsByIdList?.data![0].discount.toString();
    pasd = ApiRepository.shared.getProductsByIdList?.data![0].pastart.toString();
    paed = ApiRepository.shared.getProductsByIdList?.data![0].paend.toString();
    dasd = ApiRepository.shared.getProductsByIdList?.data![0].dastart.toString();
    daed = ApiRepository.shared.getProductsByIdList?.data![0].daend.toString();

    freePU = ApiRepository.shared.getProductsByIdList?.data![0].fp.toString();
    locationBD = ApiRepository.shared.getProductsByIdList?.data![0].lbd.toString();
    //   delivery_charges =
    // ApiRepository.shared.getProductsByIdList?.data![0].delivery_charges.toString();

    nameController.text = widget.name;
    specsController.text = widget.specifications;
    descriptionController.text = widget.description;
    rentPriceController.text = widget.price.toString();
    negotiationController.text = widget.negotiation.toString();
    price_2_Controller.text = price_2.toString();
    price_1_Controller.text = price_1.toString();
    perController.text = per.toString();
    discountController.text = dis.toString();
    selected_id = widget.category_id.toString();
    selected_sub_id = widget.sub_category_id.toString();
    _groupValue = freePU != 0 ? int.parse(freePU.toString()) : int.parse(locationBD.toString());
    deliverychargesController.text = widget.delivery_charges;
    SecurityDepositeController.text = security_deposit.toString();
  }

  getCatId() {
    ApiRepository.shared.CategoryId(
        (List) => {
              if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      print("Category Data"),
                      setState(() {
                        catLoader = false;
                        catError = false;
                      })
                    }
                  else
                    {
                      print("Category Data"),
                      setState(() {
                        cat_value = ApiRepository.shared.getCategoryByIdModelList!.data![0].name.toString();
                        catLoader = false;
                        catError = false;
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    catLoader = true;
                    catError = true;
                  })
                }
            },
        widget.category_id.toString());
  }

  getSubCatID() {
    ApiRepository.shared.SubCategoryId(
        (List) => {
              if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      print("Category Data"),
                      setState(() {
                        sub_catLoader = false;
                        sub_catError = false;
                      })
                    }
                  else
                    {
                      print("Category Data"),
                      setState(() {
                        sub_cat_value = ApiRepository.shared.getSubCategoryByIdModelList!.data![0].name.toString();
                        sub_catLoader = false;
                        sub_catError = false;
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    sub_catLoader = true;
                    sub_catError = true;
                  })
                }
            },
        widget.sub_category_id.toString());
  }

  getCategory() {
    ApiRepository.shared.getCategoryList(
        (List) => {
              if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      setState(() {
                        cats_loader = false;
                        // isError = true;
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
                      print("PRINT SELECTED CATEG ID ${selected_id}"),
                      setState(() {
                        dropdownValue = items.first;
                        cats_loader = false;
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
                        cats_loader = false;
                        // isError = true;
                        print("Error:  ${error}");
                      }),
                    }
                }
            });
    ApiRepository.shared.checkApiStatus(true, "categoryList");
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
                      print("PRINT Selected_Sub CATEG ID ${selected_sub_id}"),
                      setState(() {
                        selected_sub_id = sub_items_id.first;
                        sub_dropdownvalue = sub_items.first;
                        sub_cat_value = sub_items.first;
                        sub_cats_loader = false;
                        // sub_categoryError = false;
                        // subCategoryVisibility = true;
                      }),
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    sub_cats_loader = true;
                    // sub_categoryError = true;
                    // isLoading = false;
                  }),
                },
            },
        id.toString());
  }

  void selectImages() async {
    try {
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
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

  Future<GetProductsByProductId> getProductsById(onResponse(GetProductsByProductId List), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.getProductsByID + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetProductsByProductId.fromJson(jsonDecode(response.body));
        print("Products Data By Product Id is here  ${data.data.toString()}");

        ApiRepository.shared.getProductByProductId(data);
        // getProductByProductId(data);
        onResponse(data);

        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetProductsByProductId();
  }

  Future<ProductDeleteImageModel> deleteProductImage(id) async {
    setState(() {
      imgLoader = true;
    });
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(Uri.parse(AppUrl.productDeleteImage), body: request, headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = ProductDeleteImageModel.fromJson(json.decode(response.body));
        // print("Products Data By Product Id is here  ${data.data.toString()}");
        getProductsById(
            (List) => {
                  if (this.mounted)
                    {
                      if (List.data?.length == 0)
                        {}
                      else
                        {
                          setState(() {
                            imgLoader = false;
                          })
                        }
                    }
                },
            (error) {},
            widget.product_id.toString());
        print("product Image deleted");
        // getdeletedProductImage(true);
      } catch (error) {
        print("Product Delete Image catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }

    return ProductDeleteImageModel();
  }

  updateImage() async {
    setState(() {
      img_button = true;
    });
    image_document = [];
    if (imagesPath.length > 0) {
      for (int i = 0; i < imagesPath.length; i++) {
        String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
        var path = imagesPath[i].path;
        print(path.split('/').last);
        image_document.add(await d.MultipartFile.fromFile(path, filename: uniqueName));
      }
      try {
        d.FormData formData = new d.FormData.fromMap({
          "file": image_document,
          "id": widget.product_id,
        });

        print("images ---->>>>>");
        print(image_document);

        d.Response response = await Dio().post("https://api.jebbylistings.com/productUpdateImage", data: formData);
        setState(() {
          imagesPath = []; //for displaying images at grid
          imageFileList = []; //for displaying images at grid
        });
        getProductsById((list) {
          if (this.mounted) {
            if (list.status == 0) {
            } else {
              setState(() {
                img_button = false;
              });
            }
          }
        }, (error) {}, widget.product_id.toString());
        final snackBar = new SnackBar(content: new Text("Images Updated"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        print("error ${e.toString()}");
        final snackBar = new SnackBar(content: new Text("Error in uploading images"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } ////image picker
    else {
      final snackBar = new SnackBar(content: new Text("Select Images To Upload"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      img_button = false;
    });
  }

  prodUpdate() async {
    setState(() {
      product_update_button = true;
    });
    var data = {
      "user_id": id,
      "category_id": selected_id,
      "subcategory_id": selected_sub_id,
      "name": nameController.text,
      "price": rentPriceController.text,
      "specifications": specsController.text,
      "service_agreements": descriptionController.text,
      "negotiation": negotiationVisibility == true
          ? negotiationController.text.toString().isEmpty
              ? "0"
              : negotiationController.text.toString()
          : "0",
      "id": widget.product_id,
      "array": relProdArray,
      "product_id": widget.product_id,
      "user_id1": id,
      "price2": price_2_Controller.text,
      "per": perController.text,
      "subcat_id": selected_sub_id,
      "fp": freePU,
      "lbd": locationBD,
      "pastart": pasd,
      "paend": paed,
      "dastart": dasd,
      "daend": daed,
      "price1": price_1_Controller.text,
      "discount": discountController.text,
      "isMessage": messageSwitchNot == true ? "1" : "0",
      "delivery_charges": deliverychargesController.text,
      "security_deposit": SecurityDepositeController.text,
    };
    print(data);
    if (DateTime.parse(pasd.toString()).isAfter(DateTime.parse(paed.toString())) ||
    DateTime.parse(pasd.toString()).isAtSameMomentAs(DateTime.parse(paed.toString()))) {
  final snackBar = SnackBar(content: Text("End Date must be greater than Start Date"));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
    else if (id != null &&
            widget.category_id != null &&
            selected_sub_id.toString().isNotEmpty &&
            nameController.text.toString().isNotEmpty &&
            rentPriceController.text.toString().isNotEmpty &&
            SecurityDepositeController.text.isNotEmpty &&
            deliverychargesController.text.toString().isNotEmpty &&
            specsController.text.toString().isNotEmpty &&
            descriptionController.text.toString().isNotEmpty &&
            widget.product_id != null &&
            widget.product_id != null &&
            id != null &&
            // price_2_Controller.text.toString().isNotEmpty &&
            // perController.text.toString().isNotEmpty &&
            selected_sub_id != null &&
            freePU != null &&
            locationBD != null &&
            pasd != null &&
            paed != null
        // dasd != null &&
        // daed != null
        // price_1_Controller.text.toString().isNotEmpty &&
        // discountController.text.toString().isNotEmpty
        ) {
      ApiRepository.shared.productUpdate(
          id,
          selected_id,
          selected_sub_id.toString(),
          nameController.text.toString(),
          rentPriceController.text.toString(),
          specsController.text.toString(),
          descriptionController.text.toString(),
          negotiationVisibility == true
              ? negotiationController.text.toString().isEmpty
                  ? "0"
                  : negotiationController.text.toString()
              : "0",
          widget.product_id,
          relProdArray,
          widget.product_id,
          id,
          // price_2_Controller.text.toString(),
          "0",
          // perController.text.toString(),
          "0",
          selected_sub_id,
          freePU,
          locationBD,
          pasd,
          paed,
          // dasd,
          pasd,
          // daed,
          paed,
          // price_1_Controller.text.toString(),
          "0",
          // discountController.text.toString(),
          "0",
          // messageSwitchNot == true ? "1" : "0"
          "1",
          deliverychargesController.text.toString(),
          SecurityDepositeController.text.toString());
    } else {
      final snackBar = new SnackBar(content: new Text("Fields can't be empty"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      product_update_button = false;
    });
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
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
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  // void relP() {
  //   for (int i = 0;
  //       i < ApiRepository.shared.getRelatedProductsList!.data!.length;
  //       i++) {
  //     relProdArray.add(
  //         ApiRepository.shared.getRelatedProductsList!.data![i].id.toString());
  //   }
  //   print(relProdArray);
  // }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
            // Get.to(() => ProductListScreen(side: false));
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
            children: [
              Container(
                width: res_width * 0.9,
                child: Column(
                  children: [
                    SizedBox(
                      height: res_height * 0.01,
                    ),
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
                        controller: nameController,
                        decoration: InputDecoration(
                          // hintText: widget.name,
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
                      height: res_height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // 'Add Photo or Video',
                          "Update Photo",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            selectImages();
                          },
                          child: Icon(
                            Icons.image,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),

                    SizedBox(
                        height: 150,
                        child: imgLoader
                            ? Center(child: Text("Updating Images"))
                            : ApiRepository.shared.getProductsByIdList!.data![1].images!.length > 0
                                // imageList.length > 0
                                ? ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) => SizedBox(
                                          width: 10,
                                        ),
                                    itemCount: ApiRepository.shared.getProductsByIdList!.data![1].images!.length,
                                    // imageList.length,
                                    itemBuilder: (context, int index) {
                                      // var img_id =
                                      // var img = imageList[index];
                                      var img = ApiRepository.shared.getProductsByIdList!.data![1].images![index].path;
                                      var img_id = ApiRepository.shared.getProductsByIdList!.data![1].images![index].id;
                                      return Stack(children: [
                                        Container(
                                          child: Image.network(AppUrl.baseUrlM + img.toString()),
                                        ),
                                        Positioned(
                                            bottom: 2,
                                            left: 4,
                                            child: InkWell(
                                              onTap: () {
                                                print("Image ID --> ${img_id}");
                                                deleteProductImage(img_id);
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.grey,
                                              ),
                                            )),
                                      ]);
                                    })
                                : Text("loading")),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    imageFileList.length > 0
                        ? SizedBox(
                            height: 150,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) => SizedBox(
                                      width: 10,
                                    ),
                                itemCount: imageFileList.length,
                                itemBuilder: (context, int index) {
                                  return Stack(children: [
                                    Container(
                                      child: Image.file(File(imageFileList[index].path)),
                                    ),
                                    Positioned(
                                        bottom: 2,
                                        left: 4,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              imageFileList.removeAt(index);
                                              imagesPath.removeAt(index);
                                            });

                                            print("imageFileList ${imageFileList}");
                                            print("ImagesPath ${imagesPath}");
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.grey,
                                          ),
                                        )),
                                  ]);
                                }),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          img_button ? null : updateImage();
                        },
                        child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                              color: img_button ? kprimaryColor.withOpacity(0.5) : kprimaryColor.withOpacity(1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              img_button ? "Updating .." : "Update Image",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     //     // Container(
                    //     //     //   child: Row(
                    //     //     //     children: [
                    //     //     //       tag(),
                    //     //     //       SizedBox(
                    //     //     //         width: res_width * 0.01,
                    //     //     //       ),
                    //     //     //       tag(),
                    //     //     //       SizedBox(
                    //     //     //         width: res_width * 0.01,
                    //     //     //       ),
                    //     //     //       tag(),
                    //     //     //     ],
                    //     //     //   ),
                    //     //     // ),
                    //     Row(
                    //       children: [
                    //         Text(
                    //           'Discount',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 17,
                    //           ),
                    //         ),
                    //         Transform.scale(
                    //           scale: 0.6,
                    //           child: CupertinoSwitch(
                    //             activeColor: Color.fromARGB(255, 210, 210, 210),
                    //             trackColor: Color.fromARGB(255, 235, 235, 235),
                    //             thumbColor: switchnot ? Color.fromARGB(255, 173, 173, 173) : Color(0xff00ff01),
                    //             value: switchnot,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 negotiationVisibility = !negotiationVisibility;
                    //                 switchnot = value;
                    //               });
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.01,
                    // ),
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
                          // hintText:
                          //     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
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
                          // hintText:
                          //     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
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
                          'Rent Price',
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
                        controller: rentPriceController,
                        decoration: InputDecoration(
                          // hintText: 'Add Price',
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

                    // SizedBox(
                    //   height: res_height * 0.01,
                    // ),
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
                        controller: deliverychargesController,
                        decoration: InputDecoration(
                          // hintText: 'Add Price',
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
                    //   visible: negotiationVisibility,
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         'Discount',
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
                    //   visible: negotiationVisibility,
                    //   child: Container(
                    //     height: 50,
                    //     width: res_width * 0.9,
                    //     child: TextField(
                    //       controller: negotiationController,
                    //       decoration: InputDecoration(
                    //         // hintText: 'Enter Amount',
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Instant Rent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.6,
                          child: CupertinoSwitch(
                            activeColor: Color.fromARGB(255, 210, 210, 210),
                            trackColor: Color.fromARGB(255, 235, 235, 235),
                            thumbColor: insRentSwitchNot ? Color.fromARGB(255, 173, 173, 173) : Color(0xff00ff01),
                            value: insRentSwitchNot,
                            onChanged: (value) {
                              setState(() {
                                insRentSwitchNot = value;
                                print("insRentSwitchNot ${insRentSwitchNot}");
                              });
                            },
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Messaging',
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
                        //         thumbColor: messageSwitchNot
                        //             ? Color(0xff00ff01)
                        //             : Color.fromARGB(255, 173, 173, 173),
                        //         // ? Color.fromARGB(255, 173, 173, 173)
                        //         // : Color(0xff00ff01),
                        //         value: messageSwitchNot,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             messageSwitchNot = value;
                        //             print(
                        //                 "messageSwitchNot ${messageSwitchNot}");
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
                    Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: res_width * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text('Price'),
                                  // SizedBox(
                                  //   height: res_height * 0.005,
                                  // ),
                                  // Container(
                                  //   height: 50,
                                  //   width: res_width * 0.9,
                                  //   child: TextField(
                                  //     controller: price_2_Controller,
                                  //     decoration: InputDecoration(
                                  //       // hintText: '500 \$',
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15.0),
                                  //       ),
                                  //       enabledBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //       focusedBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // Container(
                                  //   height: 50,
                                  //   width: res_width * 0.9,
                                  //   child: TextField(
                                  //     decoration: InputDecoration(
                                  //         enabledBorder: OutlineInputBorder(
                                  //             borderRadius: BorderRadius.circular(15),
                                  //             borderSide: BorderSide(
                                  //                 color: kprimaryColor, width: 1)),
                                  //         filled: true,
                                  //         fillColor: Colors.white,
                                  //         hintText: "Rs 500",
                                  //         hintStyle: TextStyle(color: Colors.grey)),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  // Text('Per'),
                                  // SizedBox(
                                  //   height: res_height * 0.005,
                                  // ),
                                  // Container(
                                  //   height: 50,
                                  //   width: res_width * 0.9,
                                  //   child: TextField(
                                  //     controller: perController,
                                  //     decoration: InputDecoration(
                                  //       // hintText: 'Per',
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15.0),
                                  //       ),
                                  //       enabledBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //       focusedBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  catLoader
                                      ? SizedBox()
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Category'),
                                            SizedBox(
                                              height: res_height * 0.01,
                                            ),
                                            Container(
                                              height: 50,
                                              width: res_width * 0.9,
                                              decoration:
                                                  BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: kprimaryColor)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                                                child: Text(cat_value),
                                              ),
                                            ),
                                          ],
                                        ),
                                  SizedBox(
                                    height: res_height * 0.01,
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 5),
                                  //   child: Center(
                                  //     child: Container(
                                  //       child: DropdownButtonFormField(
                                  //         hint: Text(
                                  //             'Select option'), // Not necessary for Option 1

                                  //         items: [
                                  //           {
                                  //             "value": "Login",
                                  //             "label": "Login"
                                  //           },
                                  //           {
                                  //             "value": "Create",
                                  //             "label": "Create"
                                  //           },
                                  //           {"value": "Read", "label": "Read"},
                                  //           {
                                  //             "value": "Update",
                                  //             "label": "Update"
                                  //           },
                                  //           {
                                  //             "value": "Delete",
                                  //             "label": "Delete"
                                  //           },
                                  //           {
                                  //             "value": "Print",
                                  //             "label": "Print"
                                  //           },
                                  //           {
                                  //             "value": "Email",
                                  //             "label": "Email"
                                  //           },
                                  //           {"value": "Sms", "label": "Sms"},
                                  //           {
                                  //             "value": "Upload Image",
                                  //             "label": "Upload Image"
                                  //           },
                                  //           {
                                  //             "value": "Read All",
                                  //             "label": "Read All"
                                  //           }
                                  //         ].map((category) {
                                  //           return new DropdownMenuItem(
                                  //               value: category['value'],
                                  //               child: Text(
                                  //                 category['label'].toString(),
                                  //                 style: TextStyle(
                                  //                     color: Color(0xffbdbdbd),
                                  //                     fontFamily:
                                  //                         'UbuntuRegular'),
                                  //               ));
                                  //         }).toList(),
                                  //         onChanged: (newValue) {
                                  //           setState(() {
                                  //             var _selectActionsText;
                                  //             _selectActionsText.text =
                                  //                 newValue;
                                  //           });
                                  //         },
                                  //         decoration: new InputDecoration(
                                  //           border: new OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //           enabledBorder:
                                  //               new OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //           filled: true,
                                  //           hintStyle: new TextStyle(
                                  //               color: Color(0xffbdbdbd),
                                  //               fontFamily: 'UbuntuRegular'),
                                  //           fillColor: Colors.white70,
                                  //           focusedBorder: OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
//                       var currencies = [
//     "Food",
//     "Transport",
//     "Personal",
//     "Shopping",
//     "Medical",
//     "Rent",
//     "Movie",
//     "Salary"
//   ];

//  FormField<String>(
//           builder: (FormFieldState<String> state) {
//             return InputDecorator(
//               decoration: InputDecoration(
//                   labelStyle: textStyle,
//                   errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
//                   hintText: 'Please select expense',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
//               isEmpty: _currentSelectedValue == '',
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _currentSelectedValue,
//                   isDense: true,
//                   onChanged: (String newValue) {
//                     setState(() {
//                       _currentSelectedValue = newValue;
//                       state.didChange(newValue);
//                     });
//                   },
//                   items: _currencies.map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             );
//           },
//         )
                                  // dropdown('Day'),
                                  // DropdownButtonFormField(items: items, onChanged: onChanged)
                                  // DropdownButton<String>(
                                  //   // value: dropdownValue,
                                  //   // icon: const Icon(
                                  //   //   Icons.keyboard_arrow_down,
                                  //   //   size: 1,
                                  //   // ),
                                  //   // elevation: 16,
                                  //   // style: const TextStyle(color: Colors.deepPurple),
                                  //   // underline: Container(
                                  //   //   height: 2,
                                  //   //   color: Colors.deepPurpleAccent,
                                  //   // ),
                                  //   onChanged: (String? newValue) {
                                  //     setState(() {
                                  //       dropdownValue = newValue!;
                                  //     });
                                  //   },
                                  //   items: <String>['1', '2', '3', '4']
                                  //       .map<DropdownMenuItem<String>>((String value) {
                                  //     return DropdownMenuItem<String>(
                                  //       value: value,
                                  //       child: Text(value),
                                  //     );
                                  //   }).toList(),
                                  // ),
                                  // dropdown('Day'),
                                  SizedBox(
                                    height: res_height * 0.01,
                                  ),

                                  Text('Edit Category'),
                                  SizedBox(
                                    height: res_height * 0.005,
                                  ),
                                  Container(
                                    height: 50,
                                    width: res_width * 0.9,
                                    child: cats_loader
                                        ? Center(child: Text("Loading"))
                                        : FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                            return DropdownButton<String>(
                                              value: cat_value,
                                              icon: const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.black,
                                              ),
                                              elevation: 16,
                                              style: const TextStyle(color: kprimaryColor),
                                              underline: Container(height: 2, color: kprimaryColor),
                                              onChanged: (String? value) {
                                                // This is called when the user selects an item.
                                                setState(() {
                                                  cat_value = value;
                                                  dropdownValue = value!;
                                                  print("dropdownValue $dropdownValue");
                                                  print(items_id[items.indexOf(value)]);
                                                  selected_id = items_id[items
                                                      .indexOf(dropdownValue)];
                                                  print("selected ID ${selected_id}");
                                                  sub_id = [];
                                                  sub_items = [];
                                                  sub_cat_value = "";
                                                  selected_sub_id = "";
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
                                          }, future: null,),
                                  ),
                                  SizedBox(
                                    height: res_height * 0.005,
                                  ),
                                  sub_catLoader
                                      ? Text("Loading")
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Sub Category'),
                                            SizedBox(
                                              height: res_height * 0.01,
                                            ),
                                            Container(
                                              height: 50,
                                              width: res_width * 0.9,
                                              decoration:
                                                  BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: kprimaryColor)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                                                child: Text(sub_cat_value),
                                              ),
                                            ),
                                          ],
                                        ),
                                  SizedBox(
                                    height: res_height * 0.01,
                                  ),
                                  // sub_catLoader ? SizedBox() :
                                  // Container(child: Padding(
                                  //   padding: const EdgeInsets.only(top: 12.0, left: 12),
                                  //   child: Text("Select Sub Category"),
                                  // ),),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  Container(
                                    height: 50,
                                    width: res_width * 0.9,
                                    child: sub_cats_loader
                                        ? SizedBox(height: 25, width: 25, child: Text(""))
                                        : FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                            return DropdownButton<String>(
                                              value: sub_cat_value,
                                              icon: const Icon(Icons.arrow_downward),
                                              elevation: 16,
                                              style: const TextStyle(color: kprimaryColor),
                                              underline: Container(
                                                height: 2,
                                                color: kprimaryColor,
                                              ),
                                              onChanged: (String? value) {
                                                // This is called when the user selects an item.
                                                setState(() {
                                                  sub_cat_value = value;
                                                  sub_dropdownvalue = value!;
                                                  print("SubDropDown --> ${sub_dropdownvalue}");
                                                  selected_sub_id = sub_items_id[sub_items.indexOf(value)];
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
                                          }, future: null,),
                                  ),
                                  SizedBox(
                                    height: res_height * 0.01,
                                  ),
                                  // dropdown('Select'),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 5),
                                  //   child: Center(
                                  //     child: Container(
                                  //       child: DropdownButtonFormField(
                                  //         hint: Text(ApiRepository
                                  //             .shared
                                  //             .getCategoryByIdModelList!
                                  //             .data![0]
                                  //             .name
                                  //             .toString()), // Not necessary for Option 1

                                  //         items: [
                                  //           {
                                  //             "value": "Login",
                                  //             "label": "Login"
                                  //           },
                                  //           {
                                  //             "value": "Create",
                                  //             "label": "Create"
                                  //           },
                                  //           {"value": "Read", "label": "Read"},
                                  //           {
                                  //             "value": "Update",
                                  //             "label": "Update"
                                  //           },
                                  //           {
                                  //             "value": "Delete",
                                  //             "label": "Delete"
                                  //           },
                                  //           {
                                  //             "value": "Print",
                                  //             "label": "Print"
                                  //           },
                                  //           {
                                  //             "value": "Email",
                                  //             "label": "Email"
                                  //           },
                                  //           {"value": "Sms", "label": "Sms"},
                                  //           {
                                  //             "value": "Upload Image",
                                  //             "label": "Upload Image"
                                  //           },
                                  //           {
                                  //             "value": "Read All",
                                  //             "label": "Read All"
                                  //           }
                                  //         ].map((category) {
                                  //           return new DropdownMenuItem(
                                  //               value: category['value'],
                                  //               child: Text(
                                  //                 category['label'].toString(),
                                  //                 style: TextStyle(
                                  //                     color: Color(0xffbdbdbd),
                                  //                     fontFamily:
                                  //                         'UbuntuRegular'),
                                  //               ));
                                  //         }).toList(),
                                  //         onChanged: (newValue) {
                                  //           setState(() {
                                  //             var _selectActionsText;
                                  //             _selectActionsText.text =
                                  //                 newValue;
                                  //           });
                                  //         },
                                  //         decoration: new InputDecoration(
                                  //           border: new OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //           enabledBorder:
                                  //               new OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //           filled: true,
                                  //           hintStyle: new TextStyle(
                                  //               color: kprimaryColor,
                                  //               fontFamily: 'UbuntuRegular'),
                                  //           fillColor: Colors.white70,
                                  //           focusedBorder: OutlineInputBorder(
                                  //             borderSide: const BorderSide(
                                  //                 color: kprimaryColor,
                                  //                 width: 1),
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //               const Radius.circular(15.0),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: _myRadioButton(
                                          title: "Free Pickup",
                                          value: 0,
                                          onChanged: (newValue) => setState(() {
                                            _groupValue = newValue;
                                            // freePU = newValue.toString();
                                            locationBD = "0";
                                            freePU = "1";
                                            print(freePU);
                                            print("FREE PICKUP ${freePU}");
                                            print("LOCATION BASED DELIVERY ${locationBD}");
                                          }),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _myRadioButton(
                                          title: "Location Based Delivery",
                                          value: 1,
                                          onChanged: (newValue) => setState(() {
                                            _groupValue = newValue;
                                            locationBD = "1";
                                            freePU = "0";
                                            print("FREE PICKUP ${freePU}");
                                            print("LOCATION BASED DELIVERY ${locationBD}");
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: res_height * 0.005,
                                  ),
                                  itemdtl('Product Availibility', 1),
                                  SizedBox(
                                    height: res_height * 0.005,
                                  ),
                                  // itemdtl('Discount Availibility', 2),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  // GestureDetector(
                                  //   // onTap: () {
                                  //   //   Get.to(() => GeneratePromoCode());
                                  //   // },
                                  //   child: Center(
                                  //     child: Container(
                                  //       width: 398,
                                  //       height: 58,
                                  //       decoration: BoxDecoration(
                                  //           color: kprimaryColor,
                                  //           borderRadius:
                                  //               BorderRadius.circular(12)),
                                  //       child: Center(
                                  //         child: Text(
                                  //           'Add Promo Code',
                                  //           style: TextStyle(
                                  //               fontWeight: FontWeight.bold,
                                  //               fontSize: 15),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.02,
                                  // ),
                                  // Text('Price'),
                                  // SizedBox(
                                  //   height: res_height * 0.005,
                                  // ),
                                  // Container(
                                  //   height: 50,
                                  //   width: res_width * 0.7,
                                  //   child: TextField(
                                  //     decoration: InputDecoration(
                                  //       hintText: '###############',
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15.0),
                                  //       ),
                                  //       enabledBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //       focusedBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  // Row(
                                  //   children: [
                                  //     Text(
                                  //       'Price',
                                  //       style: TextStyle(
                                  //         fontWeight: FontWeight.normal,
                                  //         color: Colors.black,
                                  //         fontSize: 15,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  // Container(
                                  //   height: 50,
                                  //   width: res_width * 0.9,
                                  //   child: TextField(
                                  //     controller: price_1_Controller,
                                  //     decoration: InputDecoration(
                                  //       // hintText: 'Enter Amount',
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15.0),
                                  //       ),
                                  //       enabledBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //       focusedBorder: const OutlineInputBorder(
                                  //         borderSide: const BorderSide(
                                  //             color: kprimaryColor, width: 1),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(15)),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: res_height * 0.01,
                                  // ),
                                  // Text('Discount'),
                                  // SizedBox(
                                  //   height: res_height * 0.005,
                                  // ),
                                  Row(
                                    children: [
                                      // Container(
                                      //   height: 50,
                                      //   width: res_width * 0.4,
                                      //   child: TextField(
                                      //     controller: discountController,
                                      //     decoration: InputDecoration(
                                      //       // hintText: '%',
                                      //       border: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(15.0),
                                      //       ),
                                      //       enabledBorder:
                                      //           const OutlineInputBorder(
                                      //         borderSide: const BorderSide(
                                      //             color: kprimaryColor,
                                      //             width: 1),
                                      //         borderRadius: BorderRadius.all(
                                      //             Radius.circular(15)),
                                      //       ),
                                      //       focusedBorder:
                                      //           const OutlineInputBorder(
                                      //         borderSide: const BorderSide(
                                      //             color: kprimaryColor,
                                      //             width: 1),
                                      //         borderRadius: BorderRadius.all(
                                      //             Radius.circular(15)),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // Container(
                                      //   height: 50,
                                      //   width: res_width * 0.4,
                                      //   child: TextField(
                                      //     decoration: InputDecoration(
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderRadius: BorderRadius.circular(15),
                                      //           borderSide: BorderSide(
                                      //               color: kprimaryColor, width: 1)),
                                      //       filled: true,
                                      //       fillColor: Colors.white,
                                      //       // hintText: "Rs 500",
                                      //       // hintStyle: TextStyle(color: Colors.grey)),
                                      //     ),
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width: res_width * 0.05,
                                      // ),
                                      // Text(
                                      //   '%',
                                      //   style: TextStyle(
                                      //       fontSize: 25, color: Colors.grey),
                                      // )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: res_height * 0.02,
                            ),
                            // Align(
                            //     alignment: Alignment.topLeft,
                            //     child: Text("Related Products")),
                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   physics: NeverScrollableScrollPhysics(),
                            //   itemCount: ApiRepository
                            //       .shared.getRelatedProductsList?.data?.length,
                            //   itemBuilder: (BuildContext context, int index) {
                            //     var name = ApiRepository.shared
                            //         .getRelatedProductsList!.data![index].name
                            //         .toString();
                            //     var id =ApiRepository.shared
                            //         .getRelatedProductsList!.data![index].id
                            //         .toString();
                            //     relProdArray.add(name);
                            //     return ListTile(
                            //       title: Text(name),
                            //       trailing: Text(id),
                            // trailing: relProdArray
                            //           .contains(name)
                            //       ?
                            //        InkWell(
                            //           onTap: () {
                            //             setState(() {
                            //              relProdArray
                            //                   .remove(name);
                            //               print(relProdArray);
                            //             });
                            //           },
                            //           child: Icon(Icons.delete_outline))
                            //       : InkWell(
                            //           onTap: () {
                            //             setState(() {
                            //               relProdArray
                            //                   .add(name);
                            //               print(relProdArray);
                            //             });
                            //           },
                            //           child: Icon(Icons.add))
                            //     );
                            //   },
                            // ),
                            SizedBox(
                              height: res_height * 0.01,
                            ),
                            GestureDetector(
                              onTap: () {
                                final bottomcontroller = Get.put(BottomController());
                                bottomcontroller.navBarChange(1);
                                Get.to(() => MainScreen());
                              },
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    product_update_button ? null : prodUpdate();
                                  },
                                  child: Container(
                                    width: 380,
                                    height: 58,
                                    decoration: BoxDecoration(
                                        color: product_update_button ? kprimaryColor.withOpacity(0.5) : kprimaryColor,
                                        borderRadius: BorderRadius.circular(12)),
                                    child: Center(
                                      child: Text(
                                        product_update_button ? "Updating .." : 'Update',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: res_height * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(() => AddProduct2Screen());
                    //   },
                    //   child: Container(
                    //     width: 398,
                    //     height: 58,
                    //     child: Center(
                    //       child: Text(
                    //         'Next',
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.bold, fontSize: 19),
                    //       ),
                    //     ),
                    //     decoration: BoxDecoration(
                    //         color: kprimaryColor,
                    //         borderRadius: BorderRadius.circular(14)),
                    //   ),
                    // ),
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

  dropdown(txt) {
    double res_width = MediaQuery.of(context).size.width;
    return Container(
      height: 60,
      width: res_width * 0.9,
      child: TextField(
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: kprimaryColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: kprimaryColor, width: 1)),
          filled: true,
          fillColor: Colors.white,
          hintText: txt,
          hintStyle: TextStyle(color: Colors.grey),
          suffix: DropdownButton<String>(
            // value: dropdownValue,
            // icon: const Icon(
            //   Icons.keyboard_arrow_down,
            //   size: 1,
            // ),
            // elevation: 16,
            // style: const TextStyle(color: Colors.deepPurple),
            // underline: Container(
            //   height: 2,
            //   color: Colors.deepPurpleAccent,
            // ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>['1', '2', '3', '4'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     // Icon(
          //     //   Icons.arrow_drop_down_sharp,
          //     //   color: Colors.grey,
          //     // ),
          //   ],
          // )
        ),
      ),
    );
  }

  itemdtl(txth1, value) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: res_height * 0.01,
          ),
          SizedBox(
            height: res_height * 0.018,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                txth1,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: res_height * 0.018,
          ),
          Center(
            child: Row(
              children: [
                // datebox(),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Start Date',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Row(
                        children: [
                          Container(
                            height: res_height * 0.04,
                            width: res_width * 0.29,
                            child: Center(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Center(
                                    child: Text(
                                      value == 1 ? DateFormat('dd/MM/yyyy').format(DateTime.parse(pasd.toString())).toString() : DateFormat('dd/MM/yyyy').format(DateTime.parse(dasd.toString())).toString(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(pasd.toString()),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: kprimaryColor, // header background color
                                        onPrimary: Colors.white, // header text color
                                        onSurface: kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              print(pickedDate);
                              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
                              print(formattedDate);
                              setState(() {
                                if (value == 1) {
                                  pasd = formattedDate.toString();
                                } else {
                                  dasd = formattedDate.toString();
                                }
                              });

                              // if (picked != null && picked != selectedDate) {
                              //   setState(() {
                              //     selectedDate = picked;
                              //   });}
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: res_width * 0.06,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'End Date',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Row(
                        children: [
                          Container(
                            height: res_height * 0.04,
                            width: res_width * 0.29,
                            child: Center(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Center(
                                    child: Text(
                                      value == 1 ? DateFormat('dd/MM/yyyy').format(DateTime.parse(paed.toString())).toString() : DateFormat('dd/MM/yyyy').format(DateTime.parse(daed.toString())).toString(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(paed.toString()),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: kprimaryColor, // header background color
                                        onPrimary: Colors.white, // header text color
                                        onSurface: kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              print(pickedDate);
                              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
                              print(formattedDate);
                              setState(() {
                                if (value == 1) {
                                  paed = formattedDate.toString();
                                } else {
                                  daed = formattedDate.toString();
                                }
                              });

                              // if (picked != null && picked != selectedDate) {
                              //   setState(() {
                              //     selectedDate = picked;
                              //   });}
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // datebox(),
              ],
            ),
          ),
          SizedBox(
            height: res_height * 0.02,
          ),
        ],
      ),
    );
  }

  // itemdtl(txth1) {
  //   double res_width = MediaQuery.of(context).size.width;
  //   double res_height = MediaQuery.of(context).size.height;
  //   return Container(
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height: res_height * 0.01,
  //         ),
  //         // Container(
  //         //   child: Row(
  //         //     children: [
  //         //       // Container(
  //         //         // width: res_width * 0.25,
  //         //         // height: res_height * 0.12,
  //         //         // decoration: BoxDecoration(
  //         //         //   borderRadius: BorderRadius.circular(12),
  //         //         //   border: Border.all(color: Colors.white, width: 2),
  //         //         // ),
  //         //         // child: Padding(
  //         //         //   padding: const EdgeInsets.only(
  //         //         //     left: 15,
  //         //         //     right: 15,
  //         //         //     top: 1,
  //         //         //     bottom: 1,
  //         //         //   ),
  //         //         //   child: Image.asset('assets/slicing/Layer 7.png'),
  //         //         // ),
  //         //       // ),
  //         //       // SizedBox(width: res_width * 0.03),
  //         //       // Column(
  //         //       //   crossAxisAlignment: CrossAxisAlignment.start,
  //         //       //   children: [
  //         //       //     Text(
  //         //       //       'Apple 10.9-inch',
  //         //       //       style: TextStyle(
  //         //       //           fontWeight: FontWeight.normal, fontSize: 19),
  //         //       //     ),
  //         //       //     SizedBox(
  //         //       //       height: res_height * 0.01,
  //         //       //     ),
  //         //       //     Text(
  //         //       //       '70,000',
  //         //       //       style: TextStyle(fontSize: 15),
  //         //       //     ),
  //         //       //   ],
  //         //       // ),
  //         //     ],
  //         //   ),
  //         // ),
  //         // SizedBox(
  //         //   height: res_height * 0.018,
  //         // ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Text(
  //               txth1,
  //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         SizedBox(
  //           height: res_height * 0.018,
  //         ),
  //         Center(
  //           child: Row(
  //             children: [
  //               // datebox(),
  //               Container(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       child: Text(
  //                         'Start Date',
  //                         style: TextStyle(fontSize: 13),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: res_height * 0.01,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Container(
  //                           height: res_height * 0.04,
  //                           width: res_width * 0.29,
  //                           child: Center(
  //                               child: Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             mainAxisAlignment: MainAxisAlignment.end,
  //                             children: [
  //                               Padding(
  //                                 padding: const EdgeInsets.only(right: 3),
  //                                 child: Center(
  //                                   child: Text(
  //                                     '31/12/2021  ',
  //                                     style: TextStyle(fontSize: 10),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )),
  //                           decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(7),
  //                               border:
  //                                   Border.all(color: Colors.grey, width: 0.3)),
  //                         ),
  //                         SizedBox(
  //                           width: res_width * 0.01,
  //                         ),
  //                         GestureDetector(
  //                           onTap: () {
  //                             DateTime selectedDate = DateTime.now();

  //                             showDatePicker(
  //                               context: context,
  //                               initialDate: DateTime(2020),
  //                               firstDate: DateTime(2020),
  //                               lastDate: DateTime(2022),
  //                               builder: (context, child) {
  //                                 return Theme(
  //                                   data: Theme.of(context).copyWith(
  //                                     colorScheme: ColorScheme.light(
  //                                       primary:
  //                                           kprimaryColor, // header background color
  //                                       onPrimary:
  //                                           Colors.white, // header text color
  //                                       onSurface:
  //                                           kprimaryColor, // body text color
  //                                     ),
  //                                     textButtonTheme: TextButtonThemeData(
  //                                       style: TextButton.styleFrom(
  //                                         primary:
  //                                             kprimaryColor, // button text color
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   child: child!,
  //                                 );
  //                               },
  //                             );

  //                             // if (picked != null && picked != selectedDate) {
  //                             //   setState(() {
  //                             //     selectedDate = picked;
  //                             //   });}
  //                           },
  //                           child: Container(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(6.0),
  //                               child:
  //                                   Image.asset('assets/slicing/calender.png'),
  //                             ),
  //                             height: res_height * 0.04,
  //                             width: res_width * 0.11,
  //                             decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.circular(7),
  //                                 border: Border.all(
  //                                     color: Colors.grey, width: 0.3)),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: res_width * 0.06,
  //               ),
  //               Container(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       child: Text(
  //                         'End Date',
  //                         style: TextStyle(fontSize: 13),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: res_height * 0.01,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Container(
  //                           height: res_height * 0.04,
  //                           width: res_width * 0.29,
  //                           child: Center(
  //                               child: Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             mainAxisAlignment: MainAxisAlignment.end,
  //                             children: [
  //                               Padding(
  //                                 padding: const EdgeInsets.only(right: 3),
  //                                 child: Center(
  //                                   child: Text(
  //                                     '31/12/2021  ',
  //                                     style: TextStyle(fontSize: 10),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )),
  //                           decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(7),
  //                               border:
  //                                   Border.all(color: Colors.grey, width: 0.3)),
  //                         ),
  //                         SizedBox(
  //                           width: res_width * 0.01,
  //                         ),
  //                         GestureDetector(
  //                           onTap: () {
  //                             DateTime selectedDate = DateTime.now();

  //                             showDatePicker(
  //                               context: context,
  //                               initialDate: DateTime(2020),
  //                               firstDate: DateTime(2020),
  //                               lastDate: DateTime(2022),
  //                               builder: (context, child) {
  //                                 return Theme(
  //                                   data: Theme.of(context).copyWith(
  //                                     colorScheme: ColorScheme.light(
  //                                       primary:
  //                                           kprimaryColor, // header background color
  //                                       onPrimary:
  //                                           Colors.white, // header text color
  //                                       onSurface:
  //                                           kprimaryColor, // body text color
  //                                     ),
  //                                     textButtonTheme: TextButtonThemeData(
  //                                       style: TextButton.styleFrom(
  //                                         primary:
  //                                             kprimaryColor, // button text color
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   child: child!,
  //                                 );
  //                               },
  //                             );

  //                             // if (picked != null && picked != selectedDate) {
  //                             //   setState(() {
  //                             //     selectedDate = picked;
  //                             //   });}
  //                           },
  //                           child: Container(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(6.0),
  //                               child:
  //                                   Image.asset('assets/slicing/calender.png'),
  //                             ),
  //                             height: res_height * 0.04,
  //                             width: res_width * 0.11,
  //                             decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.circular(7),
  //                                 border: Border.all(
  //                                     color: Colors.grey, width: 0.3)),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // datebox(),
  //             ],
  //           ),
  //         ),
  //         SizedBox(
  //           height: res_height * 0.02,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _myRadioButton({title, value, onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
      activeColor: kprimaryColor,
    );
  }
}
