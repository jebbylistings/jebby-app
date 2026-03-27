import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as d;
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/getProductsByProductId.dart';
import '../../../model/productDeleteModelImage.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class EditProductScreen extends StatefulWidget {
  final dynamic category_id;
  final dynamic sub_category_id;
  final dynamic name;
  final dynamic price;
  final dynamic specifications;
  final dynamic description;
  final dynamic negotiation;
  final dynamic product_id;
  final dynamic relProd;
  final dynamic images;
  final dynamic imageID;
  final dynamic messageStatus;
  final dynamic delivery_charges;

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
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';
  // bool switchnot = false;
  bool insRentSwitchNot = true; // Match add/edit screenshot default (switch ON)
  bool messageSwitchNot = false;
  bool product_update_button = false;
  bool img_button = false;
  bool imgLoader = false;
  int _groupValue = -1;
  String dropdownValue = 'One';
  bool switchnot = true;
  // var imageList = [];
  // var imageID = [];
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

  var pasd =
      ApiRepository.shared.getProductsByIdList?.data![0].pastart.toString();
  var paed =
      ApiRepository.shared.getProductsByIdList?.data![0].paend.toString();
  var dasd =
      ApiRepository.shared.getProductsByIdList?.data![0].dastart.toString();
  var daed =
      ApiRepository.shared.getProductsByIdList?.data![0].daend.toString();
  var price_1 =
      ApiRepository.shared.getProductsByIdList?.data![0].price1.toString();
  var per = ApiRepository.shared.getProductsByIdList?.data![0].per.toString();
  var dis =
      ApiRepository.shared.getProductsByIdList?.data![0].discount.toString();
  var freePU = ApiRepository.shared.getProductsByIdList?.data![0].fp.toString();
  var locationBD =
      ApiRepository.shared.getProductsByIdList?.data![0].lbd.toString();

  var security_deposit =
      ApiRepository.shared.getProductsByIdList?.data![0].security_deposit
          .toString();

  var price_2 =
      ApiRepository.shared.getProductsByIdList?.data![0].price.toString();

  // Index of the image currently shown in the big preview.
  int _activeImageIndex = 0;
  late var name_length;
  late var category_name;
  late var category_id;
  late var cat_value;
  late var sub_cat_value;

  // -----------------------------
  // Redesigned UI state (matches screenshots)
  // -----------------------------
  bool productAvailabilitySwitch = true;

  // Location (for Location Based Delivery)
  final TextEditingController _locationController = TextEditingController();
  String? locationLat;
  String? locationLng;
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';

  // Dropdown values shown in the second screenshot.
  String materialValue = "Wooden";
  String conditionValue = "New";
  String finishValue = "Simple Finish";
  String styleValue = "Minimal";
  String yearMadeValue = "2025";

  final List<String> _materialOptions = ["Wooden", "Plastic", "Metal", "Other"];
  final List<String> _conditionOptions = ["New", "Used", "Refurbished"];
  final List<String> _finishOptions = ["Simple Finish", "Glossy", "Matte"];
  final List<String> _styleOptions = ["Minimal", "Classic", "Modern"];
  final List<String> _yearOptions = [
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
  ];

  void _syncSpecsFromDropdowns() {
    // Keep backend compatibility: backend expects a single `specifications` string.
    specsController.text =
        "Material: $materialValue, Condition: $conditionValue, Finish: $finishValue, Style: $styleValue, Year Made: $yearMadeValue";
  }

  Future<void> pickAvailabilityFromDate() async {
    final initial = DateTime.tryParse(pasd.toString()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      pasd = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> pickAvailabilityToDate() async {
    final initial = DateTime.tryParse(paed.toString()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      paed = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  void initState() {
    assign();
    getCatId();
    getSubCatID();
    getData();
    profileData(context);
    getCategory();
    // relP();
    super.initState();
  }

  bool negotiationVisibility = true;

  void assign() {
    switchnot = widget.negotiation.toString() == "0" ? true : false;
    negotiationVisibility = widget.negotiation.toString() == "0" ? false : true;
    messageSwitchNot = widget.messageStatus == 1 ? true : false;
    price_2 =
        ApiRepository.shared.getProductsByIdList?.data![0].price.toString();
    price_1 =
        ApiRepository.shared.getProductsByIdList?.data![0].price1.toString();
    per = ApiRepository.shared.getProductsByIdList?.data![0].per.toString();
    dis =
        ApiRepository.shared.getProductsByIdList?.data![0].discount.toString();
    pasd =
        ApiRepository.shared.getProductsByIdList?.data![0].pastart.toString();
    paed = ApiRepository.shared.getProductsByIdList?.data![0].paend.toString();
    dasd =
        ApiRepository.shared.getProductsByIdList?.data![0].dastart.toString();
    daed = ApiRepository.shared.getProductsByIdList?.data![0].daend.toString();

    freePU = ApiRepository.shared.getProductsByIdList?.data![0].fp.toString();
    locationBD =
        ApiRepository.shared.getProductsByIdList?.data![0].lbd.toString();
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
    _groupValue =
        freePU != 0
            ? int.parse(freePU.toString())
            : int.parse(locationBD.toString());
    deliverychargesController.text = widget.delivery_charges;
    SecurityDepositeController.text = security_deposit.toString();
    final data0 = ApiRepository.shared.getProductsByIdList?.data?[0];
    if (data0 != null) {
      if (data0.latitude != null) locationLat = data0.latitude.toString();
      if (data0.longitude != null) locationLng = data0.longitude.toString();
    }
  }

  void _onLocationChanged() {
    getSuggestion(_locationController.text);
  }

  void getSuggestion(String input) async {
    final kPLACES_API_KEY =
        dotenv.env['kPLACES_API_KEY'] ?? 'No secret key found';
    if (input.isEmpty) {
      setState(() => _placeList = []);
      return;
    }
    try {
      final baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      final request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _placeList = []);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  getCatId() {
    ApiRepository.shared.CategoryId(
      (List) => {
        if (this.mounted)
          {
            if (List.status == 0)
              {
                setState(() {
                  catLoader = false;
                  catError = false;
                }),
              }
            else
              {
                setState(() {
                  cat_value =
                      ApiRepository
                          .shared
                          .getCategoryByIdModelList!
                          .data![0]
                          .name
                          .toString();
                  catLoader = false;
                  catError = false;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              catLoader = true;
              catError = true;
            }),
          },
      },
      widget.category_id.toString(),
    );
  }

  getSubCatID() {
    ApiRepository.shared.SubCategoryId(
      (List) => {
        if (this.mounted)
          {
            if (List.status == 0)
              {
                setState(() {
                  sub_catLoader = false;
                  sub_catError = false;
                }),
              }
            else
              {
                setState(() {
                  sub_cat_value =
                      ApiRepository
                          .shared
                          .getSubCategoryByIdModelList!
                          .data![0]
                          .name
                          .toString();
                  sub_catLoader = false;
                  sub_catError = false;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              sub_catLoader = true;
              sub_catError = true;
            }),
          },
      },
      widget.sub_category_id.toString(),
    );
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
                    category_name =
                        ApiRepository.shared.categoryList?.data?[i].name,
                    category_id =
                        ApiRepository.shared.categoryList?.data?[i].id,
                    items.add(category_name.toString()),
                    items_id.add(category_id),
                  },
                setState(() {
                  dropdownValue = items.first;
                  cats_loader = false;
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
                  cats_loader = false;
                  // isError = true;
                }),
              },
          },
      },
    );
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
                    sub_name =
                        ApiRepository.shared.subCategoryList?.data?[i].name,
                    sub_id = ApiRepository.shared.subCategoryList?.data?[i].id,
                    sub_items.add(sub_name),
                    sub_items_id.add(sub_id),
                  },
                setState(() {
                  selected_sub_id = sub_items_id.first;
                  sub_dropdownvalue = sub_items.first;
                  sub_cat_value = sub_items.first;
                  sub_cats_loader = false;
                  // sub_categoryError = false;
                  // subCategoryVisibility = true;
                }),
              },
          },
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
      id.toString(),
    );
  }

  void selectImages() async {
    try {
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages.isNotEmpty) {
        const int maxImages = 4;
        final remaining = maxImages - imageFileList.length;
        if (remaining <= 0) return;

        final imagesToAdd = selectedImages.take(remaining).toList();
        for (XFile image in imagesToAdd) {
          final tempImage = File(image.path);
          imagesPath.add(tempImage);
        }
        imageFileList.addAll(imagesToAdd);
        _activeImageIndex = imageFileList.length - 1;
      }
      setState(() {});
    } catch (e) {}
  }

  // Adds exactly one image (matches the "+ Add" behavior in screenshots).
  void addOneImage() async {
    try {
      const int maxImages = 4;
      if (imageFileList.length >= maxImages) return;

      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final tempImage = File(image.path);
      setState(() {
        imagesPath.add(tempImage);
        imageFileList.add(image);
        _activeImageIndex = imageFileList.length - 1;
      });
    } catch (_) {}
  }

  // Replaces the currently selected image in the preview.
  void replaceFirstImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final tempImage = File(image.path);
      setState(() {
        if (imageFileList.isEmpty || imagesPath.isEmpty) {
          imagesPath = [tempImage];
          imageFileList = [image];
          _activeImageIndex = 0;
        } else {
          final idx = _activeImageIndex.clamp(0, imageFileList.length - 1);
          imagesPath[idx] = tempImage;
          imageFileList[idx] = image;
        }
      });
    } catch (_) {}
  }

  Future<GetProductsByProductId> getProductsById(
    onResponse(GetProductsByProductId List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getProductsByID + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetProductsByProductId.fromJson(jsonDecode(response.body));

        ApiRepository.shared.getProductByProductId(data);
        // getProductByProductId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetProductsByProductId();
  }

  Future<ProductDeleteImageModel> deleteProductImage(id) async {
    setState(() {
      imgLoader = true;
    });
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(
      Uri.parse(AppUrl.productDeleteImage),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
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
                    }),
                  },
              },
          },
          (error) {},
          widget.product_id.toString(),
        );
        // getdeletedProductImage(true);
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
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
        image_document.add(
          await d.MultipartFile.fromFile(path, filename: uniqueName),
        );
      }
      try {
        setState(() {
          imagesPath = []; //for displaying images at grid
          imageFileList = []; //for displaying images at grid
        });
        getProductsById(
          (list) {
            if (this.mounted) {
              if (list.status == 0) {
              } else {
                setState(() {
                  img_button = false;
                });
              }
            }
          },
          (error) {},
          widget.product_id.toString(),
        );
        final snackBar = new SnackBar(content: new Text("Images Updated"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        final snackBar = new SnackBar(
          content: new Text("Error in uploading images"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } ////image picker
    else {
      final snackBar = new SnackBar(
        content: new Text("Select Images To Upload"),
      );
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
    if (DateTime.parse(
          pasd.toString(),
        ).isAfter(DateTime.parse(paed.toString())) ||
        DateTime.parse(
          pasd.toString(),
        ).isAtSameMomentAs(DateTime.parse(paed.toString()))) {
      final snackBar = SnackBar(
        content: Text("End Date must be greater than Start Date"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (id != null &&
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
      if (locationBD == "1" && (locationLat == null || locationLng == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter and select a location for delivery"),
          ),
        );
        setState(() => product_update_button = false);
        return;
      }
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
        [],
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
        SecurityDepositeController.text.toString(),
        locationLat ?? "0",
        locationLng ?? "0",
      );
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
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  // void relP() {
  //   for (int i = 0;
  //       i < ApiRepository.shared.getRelatedProductsList!.data!.length;
  //       i++) {
  //     relProdArray.add(
  //         ApiRepository.shared.getRelatedProductsList!.data![i].id.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "List Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      imageFileList.isEmpty
                          ? Colors.grey.shade300
                          : Colors.white,
                  border:
                      imageFileList.isEmpty
                          ? Border.all(color: Colors.grey.shade400, width: 1)
                          : null,
                ),
                child: Stack(
                  children: [
                    if (imageFileList.isNotEmpty)
                      Positioned.fill(
                        child: Image.file(
                          File(imageFileList[_activeImageIndex].path),
                          fit: BoxFit.cover,
                        ),
                      ),

                    if (imageFileList.isEmpty)
                      Center(
                        child: _glassPill(
                          onTap: addOneImage,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          backgroundColor: const Color(
                            0xFF000000,
                          ).withOpacity(0.25),
                          borderColor: kprimaryColor.withOpacity(0.95),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Add Image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (imageFileList.isNotEmpty && imageFileList.length < 4)
                      Positioned(
                        top: 15,
                        left: 15,
                        child: _glassPill(
                          onTap: replaceFirstImage,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(
                            0xFF000000,
                          ).withOpacity(0.25),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.upload,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Replace Image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (imageFileList.isNotEmpty && imageFileList.length < 4)
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: _glassPill(
                          onTap: addOneImage,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(
                            0xFF000000,
                          ).withOpacity(0.25),
                          borderColor: kprimaryColor.withOpacity(0.95),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: imageFileList.isEmpty ? 8 : 20),
            if (imageFileList.isNotEmpty)
              SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      imageFileList.isEmpty
                          ? 0
                          : (imageFileList.length < 4
                              ? imageFileList.length + 1
                              : imageFileList.length),
                  itemBuilder: (context, index) {
                    const maxImages = 4;
                    final showAddTile =
                        imageFileList.length < maxImages &&
                        index == imageFileList.length;
                    if (showAddTile) {
                      final activeDots =
                          imageFileList.length < 3 ? imageFileList.length : 3;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: addOneImage,
                          child: Container(
                            width: 92,
                            height: 86,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 26,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (i) {
                                    return Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            i < activeDots
                                                ? kprimaryColor
                                                : Colors.grey.shade400,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final imageIndex = index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeImageIndex = imageIndex;
                                });
                              },
                              child: Opacity(
                                opacity: 0.78,
                                child: Image.file(
                                  File(imageFileList[imageIndex].path),
                                  width: 92,
                                  height: 86,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (imageIndex < imagesPath.length) {
                                    imagesPath.removeAt(imageIndex);
                                  }
                                  imageFileList.removeAt(imageIndex);
                                  if (_activeImageIndex > imageIndex) {
                                    _activeImageIndex--;
                                  }
                                  if (imageFileList.isEmpty) {
                                    _activeImageIndex = 0;
                                  } else if (_activeImageIndex >=
                                      imageFileList.length) {
                                    _activeImageIndex =
                                        imageFileList.length - 1;
                                  }
                                });
                              },
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: imageFileList.isEmpty ? 8 : 20),

            /// PRODUCT NAME
            Text(
              "Product Name",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            SizedBox(
              height: 48,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kprimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// DESCRIPTION
            Text(
              "Description",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            SizedBox(
              height: 80,
              child: TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kprimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// RENT PRICE
            Text(
              "Rent Price",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            SizedBox(
              height: 48,
              child: TextField(
                controller: rentPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 46,
                    minHeight: 48,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 6),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E88E5),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kprimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// SECURITY + DELIVERY
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Deposit',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: SecurityDepositeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 46,
                              minHeight: 48,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 6,
                              ),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1E88E5),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              8,
                              10,
                              14,
                              10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: kprimaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Charges',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: deliverychargesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 46,
                              minHeight: 48,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 6,
                              ),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1E88E5),
                                ),
                                child: const Icon(
                                  Icons.local_shipping_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              8,
                              10,
                              14,
                              10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: kprimaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// INSTANT RENT SWITCH
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 30, color: darkBlue),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Instant Rent',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We provide sturdy and comfortable wood',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 10),
                CupertinoSwitch(
                  value: insRentSwitchNot,
                  activeColor: darkBlue,
                  thumbColor: Colors.white,
                  trackColor: lightBlue,
                  onChanged: (value) {
                    setState(() {
                      insRentSwitchNot = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            /// CATEGORY
            Text(
              "Category",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: cat_value,
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                items:
                    items.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    cat_value = value;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            /// SUB CATEGORY
            Text(
              "Sub Category",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: sub_cat_value,
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                items:
                    sub_items.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    sub_cat_value = value;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            Row(
              children: [
                Text(
                  "Delivery Type",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // DELIVERY TYPE (Free Pickup / Location based)
            Container(
              height: 52,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EAF2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _groupValue = 0;
                          locationBD = "0";
                          freePU = "1";
                        });
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _groupValue == 0
                                  ? kprimaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          "Free Pickup",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                _groupValue == 0
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _groupValue = 1;
                          freePU = "0";
                          locationBD = "1";
                        });
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _groupValue == 1
                                  ? kprimaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          "Location based",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                _groupValue == 1
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14),

            // Location (for Location Based Delivery)
            if (_groupValue == 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Location",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: TextField(
                  controller: _locationController,
                  onChanged: (_) => _onLocationChanged(),
                  decoration: InputDecoration(
                    hintText: "Enter address",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
              if (_placeList.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      final prediction = _placeList[index];
                      final name = prediction["description"] ?? "";
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.pin_drop,
                          color: kprimaryColor,
                          size: 22,
                        ),
                        title: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          _locationController.text = name;
                          try {
                            List<Location> locations =
                                await locationFromAddress(name);
                            if (locations.isNotEmpty && mounted) {
                              setState(() {
                                locationLat =
                                    locations.last.latitude.toString();
                                locationLng =
                                    locations.last.longitude.toString();
                                _placeList = [];
                              });
                            }
                          } catch (e) {
                            if (mounted) setState(() => _placeList = []);
                          }
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: 14),
            ],

            // PRODUCT AVAILABILITY + FROM/TO dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Availability",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "We provide sturdy and comfortable wood",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: pickAvailabilityFromDate,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: kprimaryColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(DateTime.parse(pasd.toString())),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "To",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: pickAvailabilityToDate,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: kprimaryColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(DateTime.parse(paed.toString())),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18),

            // Product Specifications
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Product Specifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We provide sturdy and comfortable wood",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            _specDropdown("Material", materialValue, _materialOptions, (v) {
              setState(() {
                materialValue = v!;
                _syncSpecsFromDropdowns();
              });
            }),
            SizedBox(height: 12),
            _specDropdown("Condition", conditionValue, _conditionOptions, (v) {
              setState(() {
                conditionValue = v!;
                _syncSpecsFromDropdowns();
              });
            }),
            SizedBox(height: 12),
            _specDropdown("Finish", finishValue, _finishOptions, (v) {
              setState(() {
                finishValue = v!;
                _syncSpecsFromDropdowns();
              });
            }),
            SizedBox(height: 12),
            _specDropdown("Style", styleValue, _styleOptions, (v) {
              setState(() {
                styleValue = v!;
                _syncSpecsFromDropdowns();
              });
            }),
            SizedBox(height: 12),
            _specDropdown("Year Made", yearMadeValue, _yearOptions, (v) {
              setState(() {
                yearMadeValue = v!;
                _syncSpecsFromDropdowns();
              });
            }),
            SizedBox(height: 16),

            /// UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                onPressed: () {
                  product_update_button ? null : prodUpdate();
                },

                child: Text(
                  product_update_button ? "Updating..." : "List Product",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   double res_width = MediaQuery.of(context).size.width;
  //   double res_height = MediaQuery.of(context).size.height;
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       centerTitle: true,
  //       title: Text(
  //         'Edit Product',
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black,
  //           fontSize: 19,
  //         ),
  //       ),
  //       leading: InkWell(
  //         onTap: () {
  //           Get.back();
  //           // Get.to(() => ProductListScreen(side: false));
  //         },
  //         borderRadius: BorderRadius.circular(50),
  //         child: Icon(Icons.arrow_back, color: Colors.black),
  //       ),
  //     ),
  //     body: Container(
  //       width: double.infinity,
  //       child: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             Container(
  //               width: res_width * 0.9,
  //               child: Column(
  //                 children: [
  //                   SizedBox(height: res_height * 0.01),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Product Name',
  //                         style: TextStyle(
  //                           fontSize: 17,
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     child: Text(
  //                       'This information helps you and your customers identify the products on orders, documents and in the online store',
  //                       style: TextStyle(fontSize: 11, color: Colors.black),
  //                     ),
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       controller: nameController,
  //                       decoration: InputDecoration(
  //                         // hintText: widget.name,
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: res_height * 0.02),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         // 'Add Photo or Video',
  //                         "Update Photo",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 13,
  //                         ),
  //                       ),
  //                       InkWell(
  //                         onTap: () {
  //                           selectImages();
  //                         },
  //                         child: Icon(Icons.image, color: Colors.black),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.02),
  //
  //                   SizedBox(
  //                     height: 150,
  //                     child:
  //                         imgLoader
  //                             ? Center(child: Text("Updating Images"))
  //                             : ApiRepository
  //                                     .shared
  //                                     .getProductsByIdList!
  //                                     .data![1]
  //                                     .images!
  //                                     .length >
  //                                 0
  //                             // imageList.length > 0
  //                             ? ListView.separated(
  //                               scrollDirection: Axis.horizontal,
  //                               shrinkWrap: true,
  //                               separatorBuilder:
  //                                   (context, index) => SizedBox(width: 10),
  //                               itemCount:
  //                                   ApiRepository
  //                                       .shared
  //                                       .getProductsByIdList!
  //                                       .data![1]
  //                                       .images!
  //                                       .length,
  //                               // imageList.length,
  //                               itemBuilder: (context, int index) {
  //                                 // var img_id =
  //                                 // var img = imageList[index];
  //                                 var img =
  //                                     ApiRepository
  //                                         .shared
  //                                         .getProductsByIdList!
  //                                         .data![1]
  //                                         .images![index]
  //                                         .path;
  //                                 var img_id =
  //                                     ApiRepository
  //                                         .shared
  //                                         .getProductsByIdList!
  //                                         .data![1]
  //                                         .images![index]
  //                                         .id;
  //                                 return Stack(
  //                                   children: [
  //                                     Container(
  //                                       child: Image.network(
  //                                         AppUrl.baseUrlM + img.toString(),
  //                                       ),
  //                                     ),
  //                                     Positioned(
  //                                       bottom: 2,
  //                                       left: 4,
  //                                       child: InkWell(
  //                                         onTap: () {
  //                                           deleteProductImage(img_id);
  //                                         },
  //                                         child: Icon(
  //                                           Icons.delete,
  //                                           color: Colors.grey,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 );
  //                               },
  //                             )
  //                             : Text("loading"),
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   imageFileList.length > 0
  //                       ? SizedBox(
  //                         height: 150,
  //                         child: ListView.separated(
  //                           scrollDirection: Axis.horizontal,
  //                           // physics: NeverScrollableScrollPhysics(),
  //                           shrinkWrap: true,
  //                           separatorBuilder:
  //                               (context, index) => SizedBox(width: 10),
  //                           itemCount: imageFileList.length,
  //                           itemBuilder: (context, int index) {
  //                             return Stack(
  //                               children: [
  //                                 Container(
  //                                   child: Image.file(
  //                                     File(imageFileList[index].path),
  //                                   ),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 2,
  //                                   left: 4,
  //                                   child: InkWell(
  //                                     onTap: () {
  //                                       setState(() {
  //                                         imageFileList.removeAt(index);
  //                                         imagesPath.removeAt(index);
  //                                       });
  //                                     },
  //                                     child: Icon(
  //                                       Icons.delete,
  //                                       color: Colors.grey,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         ),
  //                       )
  //                       : SizedBox(),
  //                   SizedBox(height: res_height * 0.02),
  //                   Center(
  //                     child: InkWell(
  //                       onTap: () async {
  //                         img_button ? null : updateImage();
  //                       },
  //                       child: Container(
  //                         width: 250,
  //                         height: 50,
  //                         decoration: BoxDecoration(
  //                           color:
  //                               img_button
  //                                   ? kprimaryColor.withAlpha(128)
  //                                   : kprimaryColor,
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: Center(
  //                           child: Text(
  //                             img_button ? "Updating .." : "Update Image",
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 15,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //
  //                   // Row(
  //                   //   mainAxisAlignment: MainAxisAlignment.start,
  //                   //   children: [
  //                   //     //     // Container(
  //                   //     //     //   child: Row(
  //                   //     //     //     children: [
  //                   //     //     //       tag(),
  //                   //     //     //       SizedBox(
  //                   //     //     //         width: res_width * 0.01,
  //                   //     //     //       ),
  //                   //     //     //       tag(),
  //                   //     //     //       SizedBox(
  //                   //     //     //         width: res_width * 0.01,
  //                   //     //     //       ),
  //                   //     //     //       tag(),
  //                   //     //     //     ],
  //                   //     //     //   ),
  //                   //     //     // ),
  //                   //     Row(
  //                   //       children: [
  //                   //         Text(
  //                   //           'Discount',
  //                   //           style: TextStyle(
  //                   //             fontWeight: FontWeight.bold,
  //                   //             fontSize: 17,
  //                   //           ),
  //                   //         ),
  //                   //         Transform.scale(
  //                   //           scale: 0.6,
  //                   //           child: CupertinoSwitch(
  //                   //             activeColor: Color.fromARGB(255, 210, 210, 210),
  //                   //             trackColor: Color.fromARGB(255, 235, 235, 235),
  //                   //             thumbColor: switchnot ? Color.fromARGB(255, 173, 173, 173) : Color(0xff00ff01),
  //                   //             value: switchnot,
  //                   //             onChanged: (value) {
  //                   //               setState(() {
  //                   //                 negotiationVisibility = !negotiationVisibility;
  //                   //                 switchnot = value;
  //                   //               });
  //                   //             },
  //                   //           ),
  //                   //         ),
  //                   //       ],
  //                   //     )
  //                   //   ],
  //                   // ),
  //                   // SizedBox(
  //                   //   height: res_height * 0.01,
  //                   // ),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Specs',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       controller: specsController,
  //                       decoration: InputDecoration(
  //                         // hintText:
  //                         //     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   SizedBox(height: res_height * 0.01),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Description',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       controller: descriptionController,
  //                       decoration: InputDecoration(
  //                         // hintText:
  //                         //     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   SizedBox(height: res_height * 0.01),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Rent Price',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       controller: rentPriceController,
  //                       decoration: InputDecoration(
  //                         // hintText: 'Add Price',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Security Deposit',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       keyboardType: TextInputType.number,
  //                       controller: SecurityDepositeController,
  //                       decoration: InputDecoration(
  //                         hintText: 'Add Security Deposit',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // SizedBox(
  //                   //   height: res_height * 0.01,
  //                   // ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         'Delivery Charges',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.normal,
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     height: 50,
  //                     width: res_width * 0.9,
  //                     child: TextField(
  //                       controller: deliverychargesController,
  //                       decoration: InputDecoration(
  //                         // hintText: 'Add Price',
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(15.0),
  //                         ),
  //                         enabledBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                         focusedBorder: const OutlineInputBorder(
  //                           borderSide: const BorderSide(
  //                             color: kprimaryColor,
  //                             width: 1,
  //                           ),
  //                           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // SizedBox(
  //                   //   height: res_height * 0.01,
  //                   // ),
  //                   // Visibility(
  //                   //   visible: negotiationVisibility,
  //                   //   child: Row(
  //                   //     children: [
  //                   //       Text(
  //                   //         'Discount',
  //                   //         style: TextStyle(
  //                   //           fontWeight: FontWeight.normal,
  //                   //           color: Colors.black,
  //                   //           fontSize: 15,
  //                   //         ),
  //                   //       ),
  //                   //     ],
  //                   //   ),
  //                   // ),
  //                   // SizedBox(
  //                   //   height: res_height * 0.01,
  //                   // ),
  //                   // Visibility(
  //                   //   visible: negotiationVisibility,
  //                   //   child: Container(
  //                   //     height: 50,
  //                   //     width: res_width * 0.9,
  //                   //     child: TextField(
  //                   //       controller: negotiationController,
  //                   //       decoration: InputDecoration(
  //                   //         // hintText: 'Enter Amount',
  //                   //         border: OutlineInputBorder(
  //                   //           borderRadius: BorderRadius.circular(15.0),
  //                   //         ),
  //                   //         enabledBorder: const OutlineInputBorder(
  //                   //           borderSide: const BorderSide(color: kprimaryColor, width: 1),
  //                   //           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                   //         ),
  //                   //         focusedBorder: const OutlineInputBorder(
  //                   //           borderSide: const BorderSide(color: kprimaryColor, width: 1),
  //                   //           borderRadius: BorderRadius.all(Radius.circular(15)),
  //                   //         ),
  //                   //       ),
  //                   //     ),
  //                   //   ),
  //                   // ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Instant Rent',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 17,
  //                         ),
  //                       ),
  //                       Transform.scale(
  //                         scale: 0.6,
  //                         child: CupertinoSwitch(
  //                           activeTrackColor: Color.fromARGB(
  //                             255,
  //                             210,
  //                             210,
  //                             210,
  //                           ),
  //                           inactiveTrackColor: Color.fromARGB(
  //                             255,
  //                             235,
  //                             235,
  //                             235,
  //                           ),
  //                           thumbColor:
  //                               insRentSwitchNot
  //                                   ? Color.fromARGB(255, 173, 173, 173)
  //                                   : Color(0xff00ff01),
  //                           value: insRentSwitchNot,
  //                           onChanged: (value) {
  //                             setState(() {
  //                               insRentSwitchNot = value;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       // Row(
  //                       //   children: [
  //                       //     Text(
  //                       //       'Messaging',
  //                       //       style: TextStyle(
  //                       //         fontWeight: FontWeight.bold,
  //                       //         fontSize: 17,
  //                       //       ),
  //                       //     ),
  //                       //     Transform.scale(
  //                       //       scale: 0.6,
  //                       //       child: CupertinoSwitch(
  //                       //         activeColor: Color.fromARGB(255, 210, 210, 210),
  //                       //         trackColor: Color.fromARGB(255, 235, 235, 235),
  //                       //         thumbColor: messageSwitchNot
  //                       //             ? Color(0xff00ff01)
  //                       //             : Color.fromARGB(255, 173, 173, 173),
  //                       //         // ? Color.fromARGB(255, 173, 173, 173)
  //                       //         // : Color(0xff00ff01),
  //                       //         value: messageSwitchNot,
  //                       //         onChanged: (value) {
  //                       //           setState(() {
  //                       //             messageSwitchNot = value;
  //                       //                 "messageSwitchNot ${messageSwitchNot}");
  //                       //           });
  //                       //         },
  //                       //       ),
  //                       //     ),
  //                       //   ],
  //                       // )
  //                     ],
  //                   ),
  //                   SizedBox(height: res_height * 0.01),
  //                   Container(
  //                     width: double.infinity,
  //                     child: SingleChildScrollView(
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: res_width * 0.9,
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 // Text('Price'),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.005,
  //                                 // ),
  //                                 // Container(
  //                                 //   height: 50,
  //                                 //   width: res_width * 0.9,
  //                                 //   child: TextField(
  //                                 //     controller: price_2_Controller,
  //                                 //     decoration: InputDecoration(
  //                                 //       // hintText: '500 \$',
  //                                 //       border: OutlineInputBorder(
  //                                 //         borderRadius:
  //                                 //             BorderRadius.circular(15.0),
  //                                 //       ),
  //                                 //       enabledBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //       focusedBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 // Container(
  //                                 //   height: 50,
  //                                 //   width: res_width * 0.9,
  //                                 //   child: TextField(
  //                                 //     decoration: InputDecoration(
  //                                 //         enabledBorder: OutlineInputBorder(
  //                                 //             borderRadius: BorderRadius.circular(15),
  //                                 //             borderSide: BorderSide(
  //                                 //                 color: kprimaryColor, width: 1)),
  //                                 //         filled: true,
  //                                 //         fillColor: Colors.white,
  //                                 //         hintText: "Rs 500",
  //                                 //         hintStyle: TextStyle(color: Colors.grey)),
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 // Text('Per'),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.005,
  //                                 // ),
  //                                 // Container(
  //                                 //   height: 50,
  //                                 //   width: res_width * 0.9,
  //                                 //   child: TextField(
  //                                 //     controller: perController,
  //                                 //     decoration: InputDecoration(
  //                                 //       // hintText: 'Per',
  //                                 //       border: OutlineInputBorder(
  //                                 //         borderRadius:
  //                                 //             BorderRadius.circular(15.0),
  //                                 //       ),
  //                                 //       enabledBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //       focusedBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 catLoader
  //                                     ? SizedBox()
  //                                     : Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text('Category'),
  //                                         SizedBox(height: res_height * 0.01),
  //                                         Container(
  //                                           height: 50,
  //                                           width: res_width * 0.9,
  //                                           decoration: BoxDecoration(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(15),
  //                                             border: Border.all(
  //                                               color: kprimaryColor,
  //                                             ),
  //                                           ),
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.only(
  //                                               top: 12.0,
  //                                               left: 12.0,
  //                                             ),
  //                                             child: Text(cat_value),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                 SizedBox(height: res_height * 0.01),
  //                                 // Padding(
  //                                 //   padding: const EdgeInsets.only(top: 5),
  //                                 //   child: Center(
  //                                 //     child: Container(
  //                                 //       child: DropdownButtonFormField(
  //                                 //         hint: Text(
  //                                 //             'Select option'), // Not necessary for Option 1
  //
  //                                 //         items: [
  //                                 //           {
  //                                 //             "value": "Login",
  //                                 //             "label": "Login"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Create",
  //                                 //             "label": "Create"
  //                                 //           },
  //                                 //           {"value": "Read", "label": "Read"},
  //                                 //           {
  //                                 //             "value": "Update",
  //                                 //             "label": "Update"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Delete",
  //                                 //             "label": "Delete"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Print",
  //                                 //             "label": "Print"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Email",
  //                                 //             "label": "Email"
  //                                 //           },
  //                                 //           {"value": "Sms", "label": "Sms"},
  //                                 //           {
  //                                 //             "value": "Upload Image",
  //                                 //             "label": "Upload Image"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Read All",
  //                                 //             "label": "Read All"
  //                                 //           }
  //                                 //         ].map((category) {
  //                                 //           return new DropdownMenuItem(
  //                                 //               value: category['value'],
  //                                 //               child: Text(
  //                                 //                 category['label'].toString(),
  //                                 //                 style: TextStyle(
  //                                 //                     color: Color(0xffbdbdbd),
  //                                 //                     fontFamily:
  //                                 //                         'UbuntuRegular'),
  //                                 //               ));
  //                                 //         }).toList(),
  //                                 //         onChanged: (newValue) {
  //                                 //           setState(() {
  //                                 //             var _selectActionsText;
  //                                 //             _selectActionsText.text =
  //                                 //                 newValue;
  //                                 //           });
  //                                 //         },
  //                                 //         decoration: new InputDecoration(
  //                                 //           border: new OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //           enabledBorder:
  //                                 //               new OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //           filled: true,
  //                                 //           hintStyle: new TextStyle(
  //                                 //               color: Color(0xffbdbdbd),
  //                                 //               fontFamily: 'UbuntuRegular'),
  //                                 //           fillColor: Colors.white70,
  //                                 //           focusedBorder: OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //         ),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 //                       var currencies = [
  //                                 //     "Food",
  //                                 //     "Transport",
  //                                 //     "Personal",
  //                                 //     "Shopping",
  //                                 //     "Medical",
  //                                 //     "Rent",
  //                                 //     "Movie",
  //                                 //     "Salary"
  //                                 //   ];
  //
  //                                 //  FormField<String>(
  //                                 //           builder: (FormFieldState<String> state) {
  //                                 //             return InputDecorator(
  //                                 //               decoration: InputDecoration(
  //                                 //                   labelStyle: textStyle,
  //                                 //                   errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
  //                                 //                   hintText: 'Please select expense',
  //                                 //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
  //                                 //               isEmpty: _currentSelectedValue == '',
  //                                 //               child: DropdownButtonHideUnderline(
  //                                 //                 child: DropdownButton<String>(
  //                                 //                   value: _currentSelectedValue,
  //                                 //                   isDense: true,
  //                                 //                   onChanged: (String newValue) {
  //                                 //                     setState(() {
  //                                 //                       _currentSelectedValue = newValue;
  //                                 //                       state.didChange(newValue);
  //                                 //                     });
  //                                 //                   },
  //                                 //                   items: _currencies.map((String value) {
  //                                 //                     return DropdownMenuItem<String>(
  //                                 //                       value: value,
  //                                 //                       child: Text(value),
  //                                 //                     );
  //                                 //                   }).toList(),
  //                                 //                 ),
  //                                 //               ),
  //                                 //             );
  //                                 //           },
  //                                 //         )
  //                                 // dropdown('Day'),
  //                                 // DropdownButtonFormField(items: items, onChanged: onChanged)
  //                                 // DropdownButton<String>(
  //                                 //   // value: dropdownValue,
  //                                 //   // icon: const Icon(
  //                                 //   //   Icons.keyboard_arrow_down,
  //                                 //   //   size: 1,
  //                                 //   // ),
  //                                 //   // elevation: 16,
  //                                 //   // style: const TextStyle(color: Colors.deepPurple),
  //                                 //   // underline: Container(
  //                                 //   //   height: 2,
  //                                 //   //   color: Colors.deepPurpleAccent,
  //                                 //   // ),
  //                                 //   onChanged: (String? newValue) {
  //                                 //     setState(() {
  //                                 //       dropdownValue = newValue!;
  //                                 //     });
  //                                 //   },
  //                                 //   items: <String>['1', '2', '3', '4']
  //                                 //       .map<DropdownMenuItem<String>>((String value) {
  //                                 //     return DropdownMenuItem<String>(
  //                                 //       value: value,
  //                                 //       child: Text(value),
  //                                 //     );
  //                                 //   }).toList(),
  //                                 // ),
  //                                 // dropdown('Day'),
  //                                 SizedBox(height: res_height * 0.01),
  //
  //                                 Text('Edit Category'),
  //                                 SizedBox(height: res_height * 0.005),
  //                                 Container(
  //                                   height: 50,
  //                                   width: res_width * 0.9,
  //                                   child:
  //                                       cats_loader
  //                                           ? Center(child: Text("Loading"))
  //                                           : FutureBuilder(
  //                                             builder: (
  //                                               BuildContext context,
  //                                               AsyncSnapshot<dynamic> snapshot,
  //                                             ) {
  //                                               return DropdownButton<String>(
  //                                                 value: cat_value,
  //                                                 icon: const Icon(
  //                                                   Icons.arrow_downward,
  //                                                   color: Colors.black,
  //                                                 ),
  //                                                 elevation: 16,
  //                                                 style: const TextStyle(
  //                                                   color: darkBlue,
  //                                                 ),
  //                                                 underline: Container(
  //                                                   height: 2,
  //                                                   color: darkBlue,
  //                                                 ),
  //                                                 onChanged: (String? value) {
  //                                                   // This is called when the user selects an item.
  //                                                   setState(() {
  //                                                     cat_value = value;
  //                                                     dropdownValue = value!;
  //                                                     selected_id =
  //                                                         items_id[items
  //                                                             .indexOf(
  //                                                               dropdownValue,
  //                                                             )];
  //                                                     sub_id = [];
  //                                                     sub_items = [];
  //                                                     sub_cat_value = "";
  //                                                     selected_sub_id = "";
  //                                                     getSubCategory(
  //                                                       selected_id,
  //                                                     );
  //                                                   });
  //                                                 },
  //                                                 items:
  //                                                     items.map<
  //                                                       DropdownMenuItem<String>
  //                                                     >((String value) {
  //                                                       return DropdownMenuItem<
  //                                                         String
  //                                                       >(
  //                                                         value: value,
  //                                                         child: Text(value),
  //                                                       );
  //                                                     }).toList(),
  //                                               );
  //                                             },
  //                                             future: null,
  //                                           ),
  //                                 ),
  //                                 SizedBox(height: res_height * 0.005),
  //                                 sub_catLoader
  //                                     ? Text("Loading")
  //                                     : Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text('Sub Category'),
  //                                         SizedBox(height: res_height * 0.01),
  //                                         Container(
  //                                           height: 50,
  //                                           width: res_width * 0.9,
  //                                           decoration: BoxDecoration(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(15),
  //                                             border: Border.all(
  //                                               color: kprimaryColor,
  //                                             ),
  //                                           ),
  //                                           child: Padding(
  //                                             padding: const EdgeInsets.only(
  //                                               top: 12.0,
  //                                               left: 12.0,
  //                                             ),
  //                                             child: Text(sub_cat_value),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                 SizedBox(height: res_height * 0.01),
  //                                 // sub_catLoader ? SizedBox() :
  //                                 // Container(child: Padding(
  //                                 //   padding: const EdgeInsets.only(top: 12.0, left: 12),
  //                                 //   child: Text("Select Sub Category"),
  //                                 // ),),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 Container(
  //                                   height: 50,
  //                                   width: res_width * 0.9,
  //                                   child:
  //                                       sub_cats_loader
  //                                           ? SizedBox(
  //                                             height: 25,
  //                                             width: 25,
  //                                             child: Text(""),
  //                                           )
  //                                           : FutureBuilder(
  //                                             builder: (
  //                                               BuildContext context,
  //                                               AsyncSnapshot<dynamic> snapshot,
  //                                             ) {
  //                                               return DropdownButton<String>(
  //                                                 value: sub_cat_value,
  //                                                 icon: const Icon(
  //                                                   Icons.arrow_downward,
  //                                                 ),
  //                                                 elevation: 16,
  //                                                 style: const TextStyle(
  //                                                   color: darkBlue,
  //                                                 ),
  //                                                 underline: Container(
  //                                                   height: 2,
  //                                                   color: darkBlue,
  //                                                 ),
  //                                                 onChanged: (String? value) {
  //                                                   // This is called when the user selects an item.
  //                                                   setState(() {
  //                                                     sub_cat_value = value;
  //                                                     sub_dropdownvalue =
  //                                                         value!;
  //                                                     selected_sub_id =
  //                                                         sub_items_id[sub_items
  //                                                             .indexOf(value)];
  //                                                   });
  //                                                 },
  //                                                 items:
  //                                                     sub_items.map<
  //                                                       DropdownMenuItem<String>
  //                                                     >((String value) {
  //                                                       return DropdownMenuItem<
  //                                                         String
  //                                                       >(
  //                                                         value: value,
  //                                                         child: Text(value),
  //                                                       );
  //                                                     }).toList(),
  //                                               );
  //                                             },
  //                                             future: null,
  //                                           ),
  //                                 ),
  //                                 SizedBox(height: res_height * 0.01),
  //                                 // dropdown('Select'),
  //                                 // Padding(
  //                                 //   padding: const EdgeInsets.only(top: 5),
  //                                 //   child: Center(
  //                                 //     child: Container(
  //                                 //       child: DropdownButtonFormField(
  //                                 //         hint: Text(ApiRepository
  //                                 //             .shared
  //                                 //             .getCategoryByIdModelList!
  //                                 //             .data![0]
  //                                 //             .name
  //                                 //             .toString()), // Not necessary for Option 1
  //
  //                                 //         items: [
  //                                 //           {
  //                                 //             "value": "Login",
  //                                 //             "label": "Login"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Create",
  //                                 //             "label": "Create"
  //                                 //           },
  //                                 //           {"value": "Read", "label": "Read"},
  //                                 //           {
  //                                 //             "value": "Update",
  //                                 //             "label": "Update"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Delete",
  //                                 //             "label": "Delete"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Print",
  //                                 //             "label": "Print"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Email",
  //                                 //             "label": "Email"
  //                                 //           },
  //                                 //           {"value": "Sms", "label": "Sms"},
  //                                 //           {
  //                                 //             "value": "Upload Image",
  //                                 //             "label": "Upload Image"
  //                                 //           },
  //                                 //           {
  //                                 //             "value": "Read All",
  //                                 //             "label": "Read All"
  //                                 //           }
  //                                 //         ].map((category) {
  //                                 //           return new DropdownMenuItem(
  //                                 //               value: category['value'],
  //                                 //               child: Text(
  //                                 //                 category['label'].toString(),
  //                                 //                 style: TextStyle(
  //                                 //                     color: Color(0xffbdbdbd),
  //                                 //                     fontFamily:
  //                                 //                         'UbuntuRegular'),
  //                                 //               ));
  //                                 //         }).toList(),
  //                                 //         onChanged: (newValue) {
  //                                 //           setState(() {
  //                                 //             var _selectActionsText;
  //                                 //             _selectActionsText.text =
  //                                 //                 newValue;
  //                                 //           });
  //                                 //         },
  //                                 //         decoration: new InputDecoration(
  //                                 //           border: new OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //           enabledBorder:
  //                                 //               new OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //           filled: true,
  //                                 //           hintStyle: new TextStyle(
  //                                 //               color: kprimaryColor,
  //                                 //               fontFamily: 'UbuntuRegular'),
  //                                 //           fillColor: Colors.white70,
  //                                 //           focusedBorder: OutlineInputBorder(
  //                                 //             borderSide: const BorderSide(
  //                                 //                 color: kprimaryColor,
  //                                 //                 width: 1),
  //                                 //             borderRadius:
  //                                 //                 const BorderRadius.all(
  //                                 //               const Radius.circular(15.0),
  //                                 //             ),
  //                                 //           ),
  //                                 //         ),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                       flex: 1,
  //                                       child: _myRadioButton(
  //                                         title: "Free Pickup",
  //                                         value: 0,
  //                                         onChanged:
  //                                             (newValue) => setState(() {
  //                                               _groupValue = newValue;
  //                                               // freePU = newValue.toString();
  //                                               locationBD = "0";
  //                                               freePU = "1";
  //                                             }),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       flex: 1,
  //                                       child: _myRadioButton(
  //                                         title: "Location Based Delivery",
  //                                         value: 1,
  //                                         onChanged:
  //                                             (newValue) => setState(() {
  //                                               _groupValue = newValue;
  //                                               locationBD = "1";
  //                                               freePU = "0";
  //                                             }),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 SizedBox(height: res_height * 0.005),
  //                                 itemdtl('Product Availibility', 1),
  //                                 SizedBox(height: res_height * 0.005),
  //                                 // itemdtl('Discount Availibility', 2),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 // GestureDetector(
  //                                 //   // onTap: () {
  //                                 //   //   Get.to(() => GeneratePromoCode());
  //                                 //   // },
  //                                 //   child: Center(
  //                                 //     child: Container(
  //                                 //       width: 398,
  //                                 //       height: 58,
  //                                 //       decoration: BoxDecoration(
  //                                 //           color: kprimaryColor,
  //                                 //           borderRadius:
  //                                 //               BorderRadius.circular(12)),
  //                                 //       child: Center(
  //                                 //         child: Text(
  //                                 //           'Add Promo Code',
  //                                 //           style: TextStyle(
  //                                 //               fontWeight: FontWeight.bold,
  //                                 //               fontSize: 15),
  //                                 //         ),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.02,
  //                                 // ),
  //                                 // Text('Price'),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.005,
  //                                 // ),
  //                                 // Container(
  //                                 //   height: 50,
  //                                 //   width: res_width * 0.7,
  //                                 //   child: TextField(
  //                                 //     decoration: InputDecoration(
  //                                 //       hintText: '###############',
  //                                 //       border: OutlineInputBorder(
  //                                 //         borderRadius:
  //                                 //             BorderRadius.circular(15.0),
  //                                 //       ),
  //                                 //       enabledBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //       focusedBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 // Row(
  //                                 //   children: [
  //                                 //     Text(
  //                                 //       'Price',
  //                                 //       style: TextStyle(
  //                                 //         fontWeight: FontWeight.normal,
  //                                 //         color: Colors.black,
  //                                 //         fontSize: 15,
  //                                 //       ),
  //                                 //     ),
  //                                 //   ],
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 // Container(
  //                                 //   height: 50,
  //                                 //   width: res_width * 0.9,
  //                                 //   child: TextField(
  //                                 //     controller: price_1_Controller,
  //                                 //     decoration: InputDecoration(
  //                                 //       // hintText: 'Enter Amount',
  //                                 //       border: OutlineInputBorder(
  //                                 //         borderRadius:
  //                                 //             BorderRadius.circular(15.0),
  //                                 //       ),
  //                                 //       enabledBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //       focusedBorder: const OutlineInputBorder(
  //                                 //         borderSide: const BorderSide(
  //                                 //             color: kprimaryColor, width: 1),
  //                                 //         borderRadius: BorderRadius.all(
  //                                 //             Radius.circular(15)),
  //                                 //       ),
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.01,
  //                                 // ),
  //                                 // Text('Discount'),
  //                                 // SizedBox(
  //                                 //   height: res_height * 0.005,
  //                                 // ),
  //                                 Row(
  //                                   children: [
  //                                     // Container(
  //                                     //   height: 50,
  //                                     //   width: res_width * 0.4,
  //                                     //   child: TextField(
  //                                     //     controller: discountController,
  //                                     //     decoration: InputDecoration(
  //                                     //       // hintText: '%',
  //                                     //       border: OutlineInputBorder(
  //                                     //         borderRadius:
  //                                     //             BorderRadius.circular(15.0),
  //                                     //       ),
  //                                     //       enabledBorder:
  //                                     //           const OutlineInputBorder(
  //                                     //         borderSide: const BorderSide(
  //                                     //             color: kprimaryColor,
  //                                     //             width: 1),
  //                                     //         borderRadius: BorderRadius.all(
  //                                     //             Radius.circular(15)),
  //                                     //       ),
  //                                     //       focusedBorder:
  //                                     //           const OutlineInputBorder(
  //                                     //         borderSide: const BorderSide(
  //                                     //             color: kprimaryColor,
  //                                     //             width: 1),
  //                                     //         borderRadius: BorderRadius.all(
  //                                     //             Radius.circular(15)),
  //                                     //       ),
  //                                     //     ),
  //                                     //   ),
  //                                     // ),
  //                                     // Container(
  //                                     //   height: 50,
  //                                     //   width: res_width * 0.4,
  //                                     //   child: TextField(
  //                                     //     decoration: InputDecoration(
  //                                     //       enabledBorder: OutlineInputBorder(
  //                                     //           borderRadius: BorderRadius.circular(15),
  //                                     //           borderSide: BorderSide(
  //                                     //               color: kprimaryColor, width: 1)),
  //                                     //       filled: true,
  //                                     //       fillColor: Colors.white,
  //                                     //       // hintText: "Rs 500",
  //                                     //       // hintStyle: TextStyle(color: Colors.grey)),
  //                                     //     ),
  //                                     //   ),
  //                                     // ),
  //                                     // SizedBox(
  //                                     //   width: res_width * 0.05,
  //                                     // ),
  //                                     // Text(
  //                                     //   '%',
  //                                     //   style: TextStyle(
  //                                     //       fontSize: 25, color: Colors.grey),
  //                                     // )
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(height: res_height * 0.02),
  //                           // Align(
  //                           //     alignment: Alignment.topLeft,
  //                           //     child: Text("Related Products")),
  //                           // ListView.builder(
  //                           //   shrinkWrap: true,
  //                           //   physics: NeverScrollableScrollPhysics(),
  //                           //   itemCount: ApiRepository
  //                           //       .shared.getRelatedProductsList?.data?.length,
  //                           //   itemBuilder: (BuildContext context, int index) {
  //                           //     var name = ApiRepository.shared
  //                           //         .getRelatedProductsList!.data![index].name
  //                           //         .toString();
  //                           //     var id =ApiRepository.shared
  //                           //         .getRelatedProductsList!.data![index].id
  //                           //         .toString();
  //                           //     relProdArray.add(name);
  //                           //     return ListTile(
  //                           //       title: Text(name),
  //                           //       trailing: Text(id),
  //                           // trailing: relProdArray
  //                           //           .contains(name)
  //                           //       ?
  //                           //        InkWell(
  //                           //           onTap: () {
  //                           //             setState(() {
  //                           //              relProdArray
  //                           //                   .remove(name);
  //                           //             });
  //                           //           },
  //                           //           child: Icon(Icons.delete_outline))
  //                           //       : InkWell(
  //                           //           onTap: () {
  //                           //             setState(() {
  //                           //               relProdArray
  //                           //                   .add(name);
  //                           //             });
  //                           //           },
  //                           //           child: Icon(Icons.add))
  //                           //     );
  //                           //   },
  //                           // ),
  //                           SizedBox(height: res_height * 0.01),
  //                           GestureDetector(
  //                             onTap: () {
  //                               final bottomcontroller = Get.put(
  //                                 BottomController(),
  //                               );
  //                               bottomcontroller.navBarChange(1);
  //                               Get.to(() => MainScreen());
  //                             },
  //                             child: Center(
  //                               child: InkWell(
  //                                 onTap: () {
  //                                   product_update_button ? null : prodUpdate();
  //                                 },
  //                                 child: Container(
  //                                   width: 380,
  //                                   height: 58,
  //                                   decoration: BoxDecoration(
  //                                     color:
  //                                         product_update_button
  //                                             ? kprimaryColor.withOpacity(0.5)
  //                                             : kprimaryColor,
  //                                     borderRadius: BorderRadius.circular(12),
  //                                   ),
  //                                   child: Center(
  //                                     child: Text(
  //                                       product_update_button
  //                                           ? "Updating .."
  //                                           : 'Update',
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 15,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(height: res_height * 0.02),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   // GestureDetector(
  //                   //   onTap: () {
  //                   //     Get.to(() => AddProduct2Screen());
  //                   //   },
  //                   //   child: Container(
  //                   //     width: 398,
  //                   //     height: 58,
  //                   //     child: Center(
  //                   //       child: Text(
  //                   //         'Next',
  //                   //         style: TextStyle(
  //                   //             fontWeight: FontWeight.bold, fontSize: 19),
  //                   //       ),
  //                   //     ),
  //                   //     decoration: BoxDecoration(
  //                   //         color: kprimaryColor,
  //                   //         borderRadius: BorderRadius.circular(14)),
  //                   //   ),
  //                   // ),
  //                   SizedBox(height: res_height * 0.02),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  tag() {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.13,
      height: res_height * 0.03,
      decoration: BoxDecoration(
        color: kprimaryColor,
        border: Border.all(color: kprimaryColor, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'TAG',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: kprimaryColor, width: 1),
          ),
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
            items:
                <String>['1', '2', '3', '4'].map<DropdownMenuItem<String>>((
                  String value,
                ) {
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
          SizedBox(height: res_height * 0.01),
          SizedBox(height: res_height * 0.018),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                txth1,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: res_height * 0.018),
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
                      SizedBox(height: res_height * 0.01),
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
                                        value == 1
                                            ? DateFormat('MM/dd/yyyy')
                                                .format(
                                                  DateTime.parse(
                                                    pasd.toString(),
                                                  ),
                                                )
                                                .toString()
                                            : DateFormat('MM/dd/yyyy')
                                                .format(
                                                  DateTime.parse(
                                                    dasd.toString(),
                                                  ),
                                                )
                                                .toString(),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.3,
                              ),
                            ),
                          ),
                          SizedBox(width: res_width * 0.01),
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
                                        primary:
                                            kprimaryColor, // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface:
                                            kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              String formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(pickedDate!);
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
                                child: Image.asset(
                                  'assets/slicing/calender.png',
                                ),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: res_width * 0.06),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('End Date', style: TextStyle(fontSize: 13)),
                      ),
                      SizedBox(height: res_height * 0.01),
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
                                        value == 1
                                            ? DateFormat('MM/dd/yyyy')
                                                .format(
                                                  DateTime.parse(
                                                    paed.toString(),
                                                  ),
                                                )
                                                .toString()
                                            : DateFormat('MM/dd/yyyy')
                                                .format(
                                                  DateTime.parse(
                                                    daed.toString(),
                                                  ),
                                                )
                                                .toString(),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.3,
                              ),
                            ),
                          ),
                          SizedBox(width: res_width * 0.01),
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
                                        primary:
                                            kprimaryColor, // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface:
                                            kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              String formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(pickedDate!);
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
                                child: Image.asset(
                                  'assets/slicing/calender.png',
                                ),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                              ),
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
          SizedBox(height: res_height * 0.02),
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

  Widget _glassPill({
    required VoidCallback onTap,
    required Widget child,
    required EdgeInsets padding,
    Color? backgroundColor,
    Color? borderColor,
    double blurSigma = 10,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(30)),
  }) {
    final bg = backgroundColor ?? const Color(0xFF517A94).withOpacity(0.22);
    final bd = borderColor;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius,
            border: bd == null ? null : Border.all(color: bd, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _specDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              items:
                  options
                      .map(
                        (v) =>
                            DropdownMenuItem<String>(value: v, child: Text(v)),
                      )
                      .toList(),
              onChanged: onChanged,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
