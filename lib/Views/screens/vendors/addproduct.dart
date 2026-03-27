import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
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
  bool insRentSwitchNot = true; // Match screenshot default (switch ON)
  bool messageSwitchNot = false;
  bool isError = false;
  bool isLoading = true;
  bool sub_categoryLoader = true;
  bool sub_categoryError = false;
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
  List<dynamic> image_document = [];

  // -----------------------------
  // Redesigned UI state (screenshots)
  // -----------------------------
  int _groupValue = 0; // 0: Free Pickup, 1: Location Based Delivery
  String freePU = "1";
  String locationBD = "0";
  bool productAvailabilitySwitch = true;

  // Index of the image currently shown in the big preview.
  int _activeImageIndex = 0;

  // Displayed in "dd/MM/yyyy" boxes, but stored as "yyyy-MM-dd".
  String pasd = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String paed = DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(const Duration(days: 1)));

  // Location (for Location Based Delivery)
  final TextEditingController _locationController = TextEditingController();
  String? locationLat;
  String? locationLng;
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';

  // Specs dropdown values (also synced into `specsController` for backend).
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
    _syncSpecsFromDropdowns();
    getData();
    profileData(context);
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
                    sub_name =
                        ApiRepository.shared.subCategoryList?.data?[i].name,
                    sub_id = ApiRepository.shared.subCategoryList?.data?[i].id,
                    sub_items.add(sub_name),
                    sub_items_id.add(sub_id),
                  },
                selected_sub_id = sub_items_id[0],
                setState(() {
                  sub_dropdownvalue = sub_items.first;
                  sub_categoryLoader = false;
                  sub_categoryError = false;
                  subCategoryVisibility = true;
                }),
              },
          },
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
      id.toString(),
    );
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
                    category_name =
                        ApiRepository.shared.categoryList?.data?[i].name,
                    category_id =
                        ApiRepository.shared.categoryList?.data?[i].id,
                    items.add(category_name.toString()),
                    items_id.add(category_id),
                  },
                selected_id = items_id[0],
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
                    category_name =
                        ApiRepository.shared.categoryList?.data?[i].name,
                    category_id =
                        ApiRepository.shared.categoryList?.data?[i].id,
                    items.add(category_name.toString()),
                    items_id.add(category_id),
                  },
                selected_id = items_id[0],
                setState(() {
                  dropdownValue = items.first;
                  isLoading = false;
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
                  isLoading = false;
                  isError = true;
                }),
              },
          },
      },
    );
    ApiRepository.shared.checkApiStatus(true, "categoryList");
  }

  void selectImages() async {
    try {
      List<XFile>? selectedImages = await imagePicker.pickMultiImage();
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

  // Adds exactly one image (matches screenshot "+ Add" behavior).
  void addOneImage() async {
    try {
      const int maxImages = 4;
      if (imageFileList.length >= maxImages) return;

      final XFile? image = await imagePicker.pickImage(
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

  // Replaces only the first image (matches screenshot "Replace Image").
  void replaceFirstImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
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

  void reselectImage(int index) async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        imagesPath[index] = File(image.path);
        imageFileList[index] = image;
      });
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

  addProduct() async {
    if (locationBD == "1" &&
        (_locationController.text.trim().isEmpty ||
            locationLat == null ||
            locationLng == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter and select a location for delivery")),
      );
      return;
    }
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
        image_document.add(
          await d.MultipartFile.fromFile(
            imageFileList[i].path,
            filename: uniqueName,
          ),
        );
      }
      var data = {
        "file": image_document,
        "user_id": id.toString(),
        "category_id": selected_id.toString(),
        "subcategory_id": selected_sub_id.toString(),
        "name": productController.text.toString(),
        "price": rentPriceController.text.toString(),
        "delivery_charges":
            deliveryChargesController.text.toString().isEmpty
                ? "0"
                : deliveryChargesController.text.toString(),
        "specifications": specsController.text.toString(),
        "service_agreements": descriptionController.text.toString(),
        "negotiation":
            negotiationController.text.toString().isEmpty
                ? "0"
                : negotiationController.text.toString(),
        "array": [],
        "isMessage": "1",
      };
      try {
        d.FormData formData = new d.FormData.fromMap(data);
        d.Response response = await Dio().post(
          "${Url}/productInsert",
          data: formData,
        );

        if (response.toString() == 'Your files uploaded.') {
          ApiRepository.shared.getLastProductByVendorId(
            (list) {
              final productID = ApiRepository.shared.lastVendorProductList?.data?.id;
              final categoryID =
                  ApiRepository.shared.lastVendorProductList?.data?.subcategoryId;
              if (productID == null || categoryID == null) {
                if (mounted) {
                  setState(() => addBtn = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not get product info")),
                  );
                }
                return;
              }
              ApiRepository.shared.postProductInfo(
                productID.toString(),
                id.toString(),
                "0",
                categoryID.toString(),
                freePU == "1" ? 1 : 0,
                locationBD == "1" ? 1 : 0,
                pasd,
                paed,
                pasd,
                paed,
                "0",
                "0",
                locationLat ?? "0",
                locationLng ?? "0",
                SecurityDepositeController.text.toString(),
                (list) {},
                (error) {
                  if (mounted) {
                    setState(() => addBtn = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product saved. Failed to save location info.")),
                    );
                  }
                },
              );
            },
            (error) {
              if (mounted) {
                setState(() => addBtn = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product created but could not load details")),
                );
              }
            },
            id,
          );
        } else {
          final snackBar = new SnackBar(content: new Text(response.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            addBtn = false;
          });
        }
      } catch (e) {}
    } else {
      final snackBar = new SnackBar(
        content: new Text("Fields Cannot Be Empty"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      addBtn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'List Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: res_width * 0.9,
                color: Colors.white,
                child: Column(
                  children: [
                    // -----------------------------
                    // IMAGE SELECTOR (pixel-perfect)
                    // -----------------------------
                    SizedBox(height: res_height * 0.01),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: res_width * 0.9,
                        height: res_height * 0.23,
                        decoration: BoxDecoration(
                          color:
                              imagesPath.isEmpty
                                  ? Colors.grey.shade300
                                  : Colors.black12,
                          border:
                              imagesPath.isEmpty
                                  ? Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                  )
                                  : null,
                          borderRadius: BorderRadius.circular(20),
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
                            if (imagesPath.isEmpty)
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
                            if (imageFileList.isNotEmpty)
                              Positioned(
                                top: 18,
                                left: 18,
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
                            if (imageFileList.isNotEmpty &&
                                imageFileList.length < 4)
                              Positioned(
                                bottom: 18,
                                right: 18,
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

                    SizedBox(
                      height:
                          imageFileList.isEmpty
                              ? res_height * 0.005
                              : res_height * 0.015,
                    ),
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
                            final maxImages = 4;
                            final showAddTile =
                                imageFileList.length < maxImages &&
                                index == imageFileList.length;

                            if (showAddTile) {
                              final activeDots =
                                  imageFileList.length < 3
                                      ? imageFileList.length
                                      : 3;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 26,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(3, (i) {
                                            return Container(
                                              width: 5,
                                              height: 5,
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _activeImageIndex = imageIndex;
                                      });
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.file(
                                        File(imageFileList[imageIndex].path),
                                        width: 92,
                                        height: 86,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          imagesPath.removeAt(imageIndex);
                                          imageFileList.removeAt(imageIndex);
                                          if (imageFileList.isEmpty) {
                                            _activeImageIndex = 0;
                                          } else if (_activeImageIndex >=
                                              imageFileList.length) {
                                            _activeImageIndex =
                                                imageFileList.length - 1;
                                          }
                                        });
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: res_height * 0.01),
                    Row(
                      children: [
                        Text(
                          'Product Name',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    SizedBox(height: res_height * 0.005),
                    Container(
                      height: 48,
                      width: res_width * 0.9,
                      child: TextField(
                        controller: productController,
                        decoration: InputDecoration(
                          hintText: "eg : ipad",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade700,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.01),

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
                        //             switchnot = value;
                        //           });
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Row(
                      children: [
                        Text(
                          'Description',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      height: 80,
                      width: res_width * 0.9,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Enter Details",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade700,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    // Rent Price
                    Row(
                      children: [
                        Text(
                          'Rent Price',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      height: 48,
                      width: res_width * 0.9,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: rentPriceController,
                        decoration: InputDecoration(
                          hintText: 'Add Price',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade700,
                          ),
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
                          contentPadding: const EdgeInsets.fromLTRB(
                            8,
                            10,
                            14,
                            10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    // Security Deposit + Delivery Charges
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
                              SizedBox(height: res_height * 0.007),
                              Container(
                                height: 48,
                                width: double.infinity,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: SecurityDepositeController,
                                  decoration: InputDecoration(
                                    hintText: 'Add Security Deposit',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                    ),
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
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kprimaryColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
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
                              SizedBox(height: res_height * 0.007),
                              Container(
                                height: 48,
                                width: double.infinity,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: deliveryChargesController,
                                  decoration: InputDecoration(
                                    hintText: 'Add Delivery',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                    ),
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
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kprimaryColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
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
                    SizedBox(height: res_height * 0.01),
                    // Instant Rent
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
                          onChanged: (v) {
                            setState(() {
                              insRentSwitchNot = v;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Row(
                      children: [
                        Text(
                          'Category',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      height: 48,
                      width: res_width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          isLoading
                              ? Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade600,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                      selected_id =
                                          items_id[items.indexOf(
                                            dropdownValue,
                                          )];
                                      sub_id = [];
                                      sub_items = [];
                                      getSubCategory(selected_id);
                                    });
                                  },
                                  items:
                                      items.map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    Row(
                      children: [
                        Text(
                          'Sub Category',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      height: 48,
                      width: res_width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          sub_categoryLoader
                              ? Center(
                                child: Text(
                                  "Please Select The Category",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                              : Visibility(
                                visible: subCategoryVisibility,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: sub_dropdownvalue,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey.shade600,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    onChanged: (String? value) {
                                      setState(() {
                                        sub_dropdownvalue = value!;
                                        selected_sub_id =
                                            sub_items_id[sub_items.indexOf(
                                              sub_dropdownvalue,
                                            )];
                                      });
                                    },
                                    items:
                                        sub_items.map<DropdownMenuItem<String>>(
                                          (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                  ),
                                ),
                              ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    Row(
                      children: [
                        Text(
                          'Delivery Type',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    // DELIVERY TYPE (Free Pickup / Location based)
                    Container(
                      height: 52,
                      width: res_width * 0.9,
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
                    SizedBox(height: res_height * 0.01),

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
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
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
                          constraints: BoxConstraints(maxHeight: res_height * 0.25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
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
                      SizedBox(height: res_height * 0.01),
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
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
                    SizedBox(height: res_height * 0.01),

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
                                          DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(pasd.toString()),
                                          ),
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
                                          DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(paed.toString()),
                                          ),
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
                    SizedBox(height: res_height * 0.01),

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
                    SizedBox(height: res_height * 0.01),
                    _specDropdown("Material", materialValue, _materialOptions, (
                      v,
                    ) {
                      setState(() {
                        materialValue = v!;
                        _syncSpecsFromDropdowns();
                      });
                    }),
                    SizedBox(height: res_height * 0.01),
                    _specDropdown(
                      "Condition",
                      conditionValue,
                      _conditionOptions,
                      (v) {
                        setState(() {
                          conditionValue = v!;
                          _syncSpecsFromDropdowns();
                        });
                      },
                    ),
                    SizedBox(height: res_height * 0.01),
                    _specDropdown("Finish", finishValue, _finishOptions, (v) {
                      setState(() {
                        finishValue = v!;
                        _syncSpecsFromDropdowns();
                      });
                    }),
                    SizedBox(height: res_height * 0.01),
                    _specDropdown("Style", styleValue, _styleOptions, (v) {
                      setState(() {
                        styleValue = v!;
                        _syncSpecsFromDropdowns();
                      });
                    }),
                    SizedBox(height: res_height * 0.01),
                    _specDropdown("Year Made", yearMadeValue, _yearOptions, (
                      v,
                    ) {
                      setState(() {
                        yearMadeValue = v!;
                        _syncSpecsFromDropdowns();
                      });
                    }),
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
                    //     //           });
                    //     //         },
                    //     //       ),
                    //     //     ),
                    //     //   ],
                    //     // )
                    //   ],
                    // ),
                    SizedBox(height: res_height * 0.02),
                    GestureDetector(
                      onTap: () {
                        addBtn ? null : addProduct();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: addBtn
                              ? kprimaryColor.withAlpha(128)
                              : kprimaryColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          addBtn ? "Uploading" : 'List Product',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.02),
                  ],
                ),
              ),
            ],
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
}

class RelProdIns extends ChangeNotifier {
  bool relatedProdIcon;

  RelProdIns({this.relatedProdIcon = true});

  changeIcon(value) {
    relatedProdIcon = value;
    notifyListeners();
  }
}
