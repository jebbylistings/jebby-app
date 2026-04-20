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
import 'package:jebby/res/color.dart';

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
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isSelectingEnd = false;

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

  final DateFormat _rangeTitleFormat = DateFormat('MMM d');

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _availabilityStart() =>
      DateTime.tryParse(pasd.toString()) ?? DateTime.now();
  DateTime _availabilityEnd() =>
      DateTime.tryParse(paed.toString()) ?? DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isWithinSelectedRange(DateTime day) {
    final d = _dateOnly(day);
    final start = _dateOnly(_availabilityStart());
    final end = _dateOnly(_availabilityEnd());
    return !d.isBefore(start) && !d.isAfter(end);
  }

  DateTime _lastAllowedDate() {
    final now = DateTime.now();
    return DateTime(now.year + 5, now.month, now.day);
  }

  void _selectAvailabilityDay(DateTime day) {
    final today = _dateOnly(DateTime.now());
    final last = _dateOnly(_lastAllowedDate());
    if (day.isBefore(today) || day.isAfter(last)) return;

    final start = _availabilityStart();
    setState(() {
      if (!_isSelectingEnd) {
        pasd = DateFormat('yyyy-MM-dd').format(day);
        paed = DateFormat('yyyy-MM-dd').format(day);
        _isSelectingEnd = true;
        return;
      }
      if (day.isBefore(_dateOnly(start))) {
        pasd = DateFormat('yyyy-MM-dd').format(day);
        paed = DateFormat('yyyy-MM-dd').format(day);
      } else {
        paed = DateFormat('yyyy-MM-dd').format(day);
        _isSelectingEnd = false;
      }
    });
  }

  void _shiftCalendarMonth(int delta) {
    final now = DateTime.now();
    final earliest = DateTime(now.year, now.month);
    final latest = DateTime(_lastAllowedDate().year, _lastAllowedDate().month);
    final next = DateTime(_calendarMonth.year, _calendarMonth.month + delta);
    if (next.isBefore(earliest) || next.isAfter(latest)) return;
    setState(() => _calendarMonth = next);
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Add Product',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
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
                        color: const Color(0xFFF7F7F9),
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
                                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                                ),
                              )
                              : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: const Color(0xFF8F9098),
                                  ),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1B1B1F),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                              color: const Color(0xFF1B1B1F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
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
                        color: const Color(0xFFF7F7F9),
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
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0xFF8F9098),
                                    ),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1B1B1F),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
                                                  color: const Color(0xFF1B1B1F),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
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

                    _buildAvailabilityCalendar(res_width),
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
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              underline: const SizedBox(),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF8F9098),
              ),
              items:
                  options
                      .map(
                        (v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1B1B1F),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
              style: GoogleFonts.inter(
                color: const Color(0xFF1B1B1F),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCalendar(double resWidth) {
    final today = _dateOnly(DateTime.now());
    final lastAllowed = _lastAllowedDate();
    final start = _dateOnly(_availabilityStart());
    final end = _dateOnly(_availabilityEnd());
    final isSingleDaySelection = _isSameDay(start, end);
    final monthFirst = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final int leadingEmpty = monthFirst.weekday % 7;
    final int daysInMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rental Period',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF1B1B1F),
              ),
            ),
            const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF0A143D)),
              const SizedBox(width: 10),
              Text(
                '${_rangeTitleFormat.format(start)} - ${_rangeTitleFormat.format(end)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A143D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _monthButton(Icons.chevron_left, () => _shiftCalendarMonth(-1)),
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat('MMMM yyyy').format(_calendarMonth),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  _monthButton(Icons.chevron_right, () => _shiftCalendarMonth(1)),
                ],
              ),
              Row(
                children: const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                    .map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontSize: 12, color: Color(0xFF59689A))))))
                    .toList(),
              ),
              const SizedBox(height: 4),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadingEmpty + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingEmpty) return const SizedBox.shrink();
                  final dayNum = index - leadingEmpty + 1;
                  final day = DateTime(_calendarMonth.year, _calendarMonth.month, dayNum);
                  final disabled = day.isBefore(today) || day.isAfter(lastAllowed);
                  final isStart = _isSameDay(day, start);
                  final isEnd = _isSameDay(day, end);
                  final inRange = _isWithinSelectedRange(day);
                  final row = index ~/ 7;

                  bool hasLeftInRange = false;
                  if (index > 0 && (index - 1) ~/ 7 == row) {
                    final prev = dayNum - 1;
                    if (prev >= 1) {
                      final prevDay = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month,
                        prev,
                      );
                      final prevDisabled =
                          prevDay.isBefore(today) || prevDay.isAfter(lastAllowed);
                      hasLeftInRange = !prevDisabled && _isWithinSelectedRange(prevDay);
                    }
                  }

                  bool hasRightInRange = false;
                  if ((index + 1) ~/ 7 == row) {
                    final next = dayNum + 1;
                    if (next <= daysInMonth) {
                      final nextDay = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month,
                        next,
                      );
                      final nextDisabled =
                          nextDay.isBefore(today) || nextDay.isAfter(lastAllowed);
                      hasRightInRange = !nextDisabled && _isWithinSelectedRange(nextDay);
                    }
                  }

                  Color textColor = const Color(0xFF0A143D);
                  BoxDecoration? rangeDeco;
                  BoxDecoration? dayDeco;
                  Alignment dayAlignment = Alignment.center;
                  if (disabled) {
                    textColor = const Color(0xFFB8BED1);
                  } else if (inRange && !isSingleDaySelection) {
                    rangeDeco = BoxDecoration(
                      color: const Color(0xFFDCE1EB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(hasLeftInRange ? 0 : 10),
                        bottomLeft: Radius.circular(hasLeftInRange ? 0 : 10),
                        topRight: Radius.circular(hasRightInRange ? 0 : 10),
                        bottomRight: Radius.circular(hasRightInRange ? 0 : 10),
                      ),
                    );
                  }
                  if (!disabled && (isStart || isEnd)) {
                    dayDeco = BoxDecoration(
                      color: const Color(0xFF0A143D),
                      borderRadius: BorderRadius.circular(10),
                    );
                    textColor = Colors.white;
                    if (isStart && hasRightInRange) {
                      dayAlignment = Alignment.centerLeft;
                    } else if (isEnd && hasLeftInRange) {
                      dayAlignment = Alignment.centerRight;
                    }
                  }

                  const double dayExtent = 30;
                  return GestureDetector(
                    onTap: disabled ? null : () => _selectAvailabilityDay(day),
                    child: Container(
                      decoration: rangeDeco,
                      alignment: dayAlignment,
                      child: Container(
                        width: dayExtent,
                        height: dayExtent,
                        decoration: dayDeco,
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNum',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: (isStart || isEnd) ? FontWeight.w700 : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                _isSelectingEnd
                    ? 'Select an end date'
                    : 'Select a start date to adjust your range',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF72747A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'From: ${DateFormat('MM/dd/yyyy').format(_availabilityStart())}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF72747A),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'To: ${DateFormat('MM/dd/yyyy').format(_availabilityEnd())}',
                textAlign: TextAlign.end,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF72747A),
                ),
              ),
            ),
          ],
        ),
      ],
    )));
  }

  Widget _monthButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: const Color(0xFF0A143D)),
        ),
      ),
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
