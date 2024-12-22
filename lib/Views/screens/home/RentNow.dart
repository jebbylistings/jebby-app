import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:jared/Services/provider/sign_in_provider.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/CheckOut.dart';
import 'package:jared/view_model/getTax_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import 'package:http/http.dart' as http;

import '../../../view_model/user_view_model.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

class RentnowScreen extends StatefulWidget {
  String vendorName;
  String vendorAddress;
  String cell;
  String vendorImage;
  var vendorID;
  var productID;
  var pastart;
  var paend;
  var price;
  var vendorAccountId;
  var vendorPayPalEmail;
  var route;
  var delivery_charges;
  var security_deposit;

  RentnowScreen(this.vendorName, this.vendorAddress, this.cell, this.vendorImage, this.vendorID, this.productID, this.pastart, this.paend, this.price,
      this.vendorAccountId, this.vendorPayPalEmail, this.route, this.delivery_charges, this.security_deposit);

  @override
  State<RentnowScreen> createState() => _RentnowScreenState();
}

class _RentnowScreenState extends State<RentnowScreen> {
  bool onlinepay = false;
  bool cod = false;

  var fromdate;
  var todate;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ShippingAddressController = TextEditingController();

  var _locationController = TextEditingController();
  var _CurrentAddressController = TextEditingController();
  var Latitiude = "";
  var Longitude = "";
  var uuid = new Uuid();
  var vuid = new Uuid();
  List<dynamic> _placeList = [];
  List<dynamic> _placeList1 = [];
  String _sessionToken = '1234567890';

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),//DateTime.parse(widget.pastart),
      firstDate: DateTime.now().add(Duration(days: 1)),//DateTime.parse(widget.pastart),
      lastDate: DateTime.parse(widget.paend),
    );
    if (picked != null && picked != selectedDate1) {
      setState(() {
        selectedDate1 = picked;
      });
    }
  }

  var myFormat = DateFormat('yyyy-MM-dd');
  var myFormat1 = DateFormat('MM/dd/yyyy');
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),//DateTime.parse(widget.pastart).isBefore(DateTime.now()) ? DateTime.now() : DateTime.parse(widget.pastart),
        firstDate: DateTime.now(),//DateTime.parse(widget.pastart).isBefore(DateTime.now()) ? DateTime.now() : DateTime.parse(widget.pastart),
        lastDate: DateTime.parse(widget.paend)
        );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_locationController.text);
  }

  _onChanged2() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = vuid.v4();
      });
    }
    getSuggestion1(_CurrentAddressController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = dotenv.env['kPLACES_API_KEY'] ?? 'No secret key found';
    String type = '(regions)';

    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = jsonDecode(response.body);
      // log('mydata');
      // log(response.body.toString());
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  void getSuggestion1(String input) async {
    String kPLACES_API_KEY = dotenv.env['kPLACES_API_KEY'] ?? 'No secret key found';
    String type = '(regions)';

    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = jsonDecode(response.body);
      // log('mydata');
      // log(response.body.toString());
      if (response.statusCode == 200) {
        setState(() {
          _placeList1 = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  String? zipCode;
  String? countryCode;
  Future<void> _getZipCodeFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        zipCode = placemark.postalCode ?? '';
        countryCode = placemark.isoCountryCode ?? '';
        print("Country Code: $countryCode");
        print("ZIP Code: $zipCode");
      } else {
        print("ZIP Code not found.");
      }
    } catch (e) {
      print("Error getting ZIP Code: $e");
    }
  }

  dynamic array = [];
  late Map<String, dynamic> _data;

  Future<void> _loadData() async {
    try {
      final data = await GetJebbyfee.fetchData();
      setState(() {
        _data = data;
        array = _data['data'];
      });
      JebbyFee = array.length > 0 ? array[0]['jebby_fees'] : 0;
      print("array ===>  ${JebbyFee}");
    } catch (e) {
      print('error $e');
    }
  }

  void pre() async {
    SharedPreferences Prefrences = await SharedPreferences.getInstance();

    _CurrentAddressController.text = Prefrences.getString('address').toString() == "null" ? "" : Prefrences.getString('address').toString();
    _locationController.text = Prefrences.getString('address').toString() == "null" ? "" : Prefrences.getString('address').toString();
    nameController.text = Prefrences.getString('fullname').toString();
    emailController.text = Prefrences.getString('email').toString();
    Longitude = Prefrences.getString('longitude').toString();
    Latitiude = Prefrences.getString('latitude').toString();
    print("Longitude ${Prefrences.getString('longitude').toString()}");
    print("Latitiude ${Prefrences.getString('latitude').toString()}");
    _getZipCodeFromCoordinates(double.parse(Latitiude), double.parse(Longitude));
  }

  void initState() {
    _loadData();
    getData();
    profileData(context);
    selectedDate = DateTime.now();//DateTime.parse(widget.pastart).isBefore(DateTime.now()) ? DateTime.now() : DateTime.parse(widget.pastart);
    selectedDate1 = DateTime.now().add(Duration(days: 1));//DateTime.parse(widget.paend);
    var diff = selectedDate1.difference(selectedDate).inDays;
    print("Product ID : ${widget.productID}");
    print("User ID : ${widget.vendorID}");
    print("Acc Id : ${widget.vendorAccountId}");
    print("Acc email : ${widget.vendorPayPalEmail}");
    print("pastart: ${widget.pastart}");
    print("paend : ${widget.paend}");
    print("dc : ${widget.delivery_charges}");
    print("security_deposit ${widget.security_deposit}");
    pre();
    // print("_CurrentAddressController.text ${_CurrentAddressController.text}");
    super.initState();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String userID = "";
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate().then((value) async {
      token = value.token.toString();
      userID = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      print("User: ${userID}");
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  var JebbyFee;

  //  void dispose() {
  //   _locationController.dispose();
  //   super.dispose();
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
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Align(
                alignment: Alignment.center,
                child: ApiRepository.shared.getProductsByIdList!.data![1].images!.length > 0
                    ? SizedBox(
                        height: 150,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => SizedBox(
                                  width: 10,
                                ),
                            itemCount: ApiRepository.shared.getProductsByIdList!.data![1].images!.length,
                            itemBuilder: (context, int index) {
                              var img = ApiRepository.shared.getProductsByIdList?.data?[1].images?[index].path;
                              return Container(
                                child: CachedNetworkImage(
                                  imageUrl: AppUrl.baseUrlM + img.toString(),
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(), // Loading spinner
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ), // Display an error icon
                                ),
                              );
                            }),
                      )
                    : Text("No Images"),
              ),
              // Container(
              //   width: 391,
              //   height: 223,
              //   decoration:
              //       BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: Colors.black.withOpacity(0.11))),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 20),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.end,
              //           children: [
              //             Container(
              //               width: 90,
              //               height: 135,
              //               child: Image.asset(
              //                 "assets/slicing/Layer 4@3x.png",
              //                 fit: BoxFit.fill,
              //               ),
              //             ),
              //             Container(
              //               width: 128,
              //               height: 170,
              //               child: Image.asset(
              //                 "assets/slicing/Layer 4@3x.png",
              //                 fit: BoxFit.fill,
              //               ),
              //             ),
              //             Container(
              //               width: 90,
              //               height: 135,
              //               child: Image.asset(
              //                 "assets/slicing/Layer 4@3x.png",
              //                 fit: BoxFit.fill,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 5,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ApiRepository.shared.getProductsByIdList!.data![0].name.toString(),
                    style: TextStyle(fontSize: 28, color: Colors.black, fontFamily: "Inter, Regular"),
                  ),
                  RatingBarIndicator(
                    rating: double.parse(ApiRepository.shared.getProductsByIdList!.data![0].stars.toString()),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 15,
                    direction: Axis.horizontal,
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rental Price",
                    style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: "Inter, Regular"),
                  ),
                  Text(
                    "\$${widget.price} / day",
                    style: TextStyle(fontSize: 25, color: Colors.black, fontFamily: "Inter, ExtraBold"),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                // margin: EdgeInsets.only(left: 7),
                //width: res_width * 0.01,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rent Start',
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context);
                            fromdate = myFormat.format(selectedDate);
                          },
                          child: Container(
                            width: res_width * 0.425,
                            height: res_height * 0.06,
                            decoration: BoxDecoration(
                              // color: Colors.orange,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    myFormat1.format(selectedDate),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   width: res_width * 0.38,
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Original Return',
                            style: TextStyle(
                              fontSize: 19,
                            )),
                        GestureDetector(
                          onTap: () {
                            _selectDate1(context);
                            todate = myFormat.format(selectedDate1);
                          },
                          child: Container(
                            width: res_width * 0.425,
                            height: res_height * 0.06,
                            decoration: BoxDecoration(
                              // color: Colors.orange,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    myFormat1.format(selectedDate1),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 365,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            width: 1,
                            color: Color(0xffFEB038),
                          ),
                        ),
                        child: TextFormField(
                          controller: nameController,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10, top: 5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      "Email",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: 365,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: Color(0xffFEB038),
                        ),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10, top: 5),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
              // SizedBox(
              //   height: 15,
              // ),
              // Row(
              //   children: [
              //     // SizedBox(
              //     //   height: 10,
              //     // ),
              //     Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //       Text(
              //         "Shipping Address",
              //         style: TextStyle(fontSize: 17, color: Colors.black),
              //       ),
              //       SizedBox(
              //         height: 5,
              //       ),
              //       Container(
              //         width: 365,
              //         height: 58,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(16),
              //           border: Border.all(
              //             width: 1,
              //             color: Color(0xffFEB038),
              //           ),
              //         ),
              //         child: TextFormField(
              //           controller: ShippingAddressController,
              //           style: TextStyle(
              //             fontSize: 17,
              //             color: Colors.black,
              //           ),
              //           keyboardType: TextInputType.text,
              //           decoration: InputDecoration(
              //             disabledBorder: InputBorder.none,
              //             errorBorder: InputBorder.none,
              //             border: InputBorder.none,
              //             contentPadding: EdgeInsets.only(left: 10, top: 5),
              //           ),
              //         ),
              //       ),
              //     ]),
              //   ],
              // ),
              // SizedBox(
              //   height: 3,
              // ),
              // TxtfldforLocation("Current Address", _CurrentAddressController),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Text(
                      'Current Address',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.005,
                    ),
                    Container(
                      // height: 70,
                      width: res_width * 0.89,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _onChanged2();
                          });
                        },
                        maxLines: 1,
                        controller: _CurrentAddressController,
                        decoration: InputDecoration(
                          // hintText:placholder,
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
                  ],
                ),
              ),
              SizedBox(
                // height: res_height * 0.05,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: _placeList1.length,
                    itemBuilder: ((context, index) {
                      String name = _placeList1[index]["description"];

                      if (_CurrentAddressController.text.isEmpty) {
                        return Text("");
                      } else if (name.toLowerCase().contains(_CurrentAddressController.text.toLowerCase())) {
                        return ListTile(
                          onTap: () async {
                            _locationController.text = _placeList1[index]["description"];
                            _CurrentAddressController.text = _placeList1[index]["description"];
                            List<Location> location = await locationFromAddress(_placeList1[index]["description"]);
                            setState(() {
                              // _CurrentAddressController.removeListener(() {});
                              Latitiude = location.last.latitude.toString();
                              Longitude = location.last.longitude.toString();
                              print("Latitude: ${location.last.latitude.toString()}");
                              print("Longitude: ${location.last.longitude.toString()}");
                              _getZipCodeFromCoordinates(location.last.latitude, location.last.longitude);
                              _placeList1 = [];
                            });
                          },
                          leading: CircleAvatar(child: Icon(Icons.pin_drop, color: Colors.white)),
                          title: Text(_placeList1[index]["description"]),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    })),
              ),
              SizedBox(
                height: 5,
              ),
              // TxtfldforLocation("Shipping Address", _locationController),
              // SizedBox(
              //   // height: res_height * 0.05,
              // child:
              // ListView.builder(
              //     shrinkWrap: true,
              //     physics: ScrollPhysics(),
              //     itemCount: _placeList.length,
              //     itemBuilder: ((context, index) {
              //       String name = _placeList[index]["description"];

              //       if (_locationController.text.isEmpty) {
              //         return Text("");
              //       } else if (name.toLowerCase().contains(_locationController.text.toLowerCase())) {
              //         return ListTile(
              //           onTap: () async {
              //             _locationController.text = _placeList[index]["description"];
              //             List<Location> location = await locationFromAddress(_placeList[index]["description"]);
              //             setState(() {
              //               _locationController.removeListener(() {});
              //               Latitiude = location.last.latitude.toString();
              //               Longitude = location.last.longitude.toString();
              //               print("Latitude: ${location.last.latitude.toString()}");
              //               print("Longitude: ${location.last.longitude.toString()}");

              //               // Use geocoding to get the ZIP code
              //               _getZipCodeFromCoordinates(location.last.latitude, location.last.longitude);
              //               _placeList = [];
              //             });
              //           },
              //           leading: CircleAvatar(child: Icon(Icons.pin_drop, color: Colors.white)),
              //           title: Text(_placeList[index]["description"]),
              //         );
              //       } else {
              //         return SizedBox.shrink();
              //       }
              //     })),
              // ),
              SizedBox(
                height: 20,
              ),

              Column(
                children: [
                  // Text(
                  //   "Owner Info",
                  //   style: TextStyle(fontSize: 24, color: Colors.black, fontFamily: "Inter, Bold"),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: 67,
                          height: 67,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: widget.vendorImage == ""
                              ? Image.asset("assets/slicing/blankuser.jpeg", fit: BoxFit.fill)
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    AppUrl.baseUrlM + ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString(),
                                    // fit: BoxFit.contain,
                                  ),
                                )),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vendorName == "" ? "Vendor" : widget.vendorName,
                            style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: "Inter, Bold"),
                          ),
                          // Text(
                          //   widget.vendorAddress == "" ? "" : widget.vendorAddress,
                          //   style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.53), fontFamily: "Inter, Light"),
                          // ),
                          // Text(
                          //   widget.cell == "" ? "" : widget.cell,
                          //   style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: "Inter, Light"),
                          // )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              // SizedBox(
              //   height: 30,
              // ),
              // Row(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           onlinepay = false;
              //           print("LBD");
              //           // cod = false;
              //         });
              //       },
              //       child: Container(
              //         height: 19,
              //         width: 19,
              //         decoration: BoxDecoration(
              //             shape: BoxShape.circle, border: Border.all(color: onlinepay == false ? Color(0xff303030) : Colors.black, width: 3)),
              //         child: Icon(
              //           Icons.circle_rounded,
              //           color: onlinepay == false ? Color(0xff303030) : Colors.white,
              //           size: 13,
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       width: 20,
              //     ),
              //     Text(
              //       "Online Payment",
              //       style: TextStyle(fontSize: 21, color: Colors.black, fontFamily: "Inter, Regular"),
              //     ),
              //     SizedBox(
              //       width: 20,
              //     ),
              //     // GestureDetector(
              //     //   onTap: () {
              //     //     setState(() {
              //     //       onlinepay = true;
              //     //       print("COD");
              //     //       // cod = true;
              //     //     });
              //     //   },
              //     //   child: Container(
              //     //     height: 19,
              //     //     width: 19,
              //     //     decoration: BoxDecoration(
              //     //         shape: BoxShape.circle, border: Border.all(color: onlinepay == true ? Color(0xff303030) : Colors.black, width: 3)),
              //     //     child: Icon(
              //     //       Icons.circle_rounded,
              //     //       color: onlinepay == true ? Color(0xff303030) : Colors.white,
              //     //       size: 13,
              //     //     ),
              //     //   ),
              //     // ),
              //     // SizedBox(
              //     //   width: 20,
              //     // ),
              //     // Text(
              //     //   "COD",
              //     //   style: TextStyle(fontSize: 21, color: Colors.black, fontFamily: "Inter, Regular"),
              //     // ),
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      DateTime normalizedSelectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

                      int diff = selectedDate1.difference(normalizedSelectedDate).inDays + 1;
                      print("diff $diff");
                      // print(_locationController.text.toString());
                      // print(Latitiude);
                      // print(Longitude);
                      // print(selectedDate); start
                      print("selectedDate1 $selectedDate1");
                      print("selectedDate $selectedDate");
                      // int diff = selectedDate1.difference(selectedDate).inDays;
                      // print("diff $diff");
                      int amount = int.parse(widget.price.toString()) * diff;
                      print("amount $amount");
                      // print( DateFormat('yyyy-MM-dd').format(selectedDate));
                      //         .toString(),);
                      //         .format(selectedDate)
                      //         .toString(),)
                      if (onlinepay == true) {
                        print(DateTime.parse(selectedDate.toString()).runtimeType);
                        if (DateTime.parse(selectedDate.toString()).difference(DateTime.parse(selectedDate1.toString())).inMilliseconds >= 0) {
                          final snackBar = new SnackBar(content: new Text("Please Enter Valid End Date"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          // Utils.flushBarErrorMessage(
                          //     'Please Enter Valid End Date', context);
                        } else if (emailController.text.isNotEmpty &&
                            _locationController.text.toString().isNotEmpty &&
                            nameController.text.isNotEmpty) {
                          final snackBar = new SnackBar(content: new Text("Please Wait"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          ApiRepository.shared.postOrder(
                              context,
                              userID,
                              widget.productID,
                              DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
                              DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
                              fullname,
                              emailController.text.toString(),
                              _locationController.text.toString(),
                              Latitiude,
                              Longitude,
                              widget.route == "simple" ? 0 : amount,
                              _CurrentAddressController.text.toString(),
                              Latitiude,
                              Longitude);
                          Map data = {
                            "user_id": userID,
                            "product_id": widget.productID,
                            "rent_start": DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
                            "original_return": DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
                            "name": fullname,
                            "email": emailController.text.toString(),
                            "location": _locationController.text.toString(),
                            "latitude": Latitiude,
                            "longitude": Longitude,
                            "nego_price": widget.route == "simple" ? 0 : amount,
                            "shipping_address": _CurrentAddressController.text.toString()
                          };
                          print("data ====> $data");
                        } else {
                          String message = "Fields Cannot Be Empty";
                          if (_locationController.text.toString().isEmpty) {
                            message = "Please enter location";
                          }
                          final snackBar = new SnackBar(content: new Text(message));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        if (DateTime.parse(selectedDate.toString()).difference(DateTime.parse(selectedDate1.toString())).inMilliseconds >= 0) {
                          final snackBar = new SnackBar(content: new Text("Please Enter Valid End Date"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          // Utils.flushBarErrorMessage(
                          //     'Please Enter Valid End Date', context);
                        } else if (widget.vendorAccountId == "0" || widget.vendorAccountId == "" || widget.vendorAccountId == 0) {
                          final snackBar = new SnackBar(content: new Text("Online pay not available"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else if (emailController.text.isNotEmpty &&
                            _locationController.text.toString().isNotEmpty &&
                            nameController.text.isNotEmpty) {
                          Get.to(() => CheckoutScreen(
                              userID,
                              widget.productID,
                              DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
                              DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
                              widget.vendorName,
                              widget.vendorAddress,
                              widget.cell,
                              widget.vendorImage,
                              widget.vendorID,
                              widget.pastart,
                              widget.paend,
                              widget.price,
                              // amount,
                              widget.vendorAccountId,
                              widget.vendorPayPalEmail,
                              fullname,
                              emailController.text.toString(),
                              _locationController.text.toString(),
                              Latitiude,
                              Longitude,
                              widget.route == "simple" ? 0 : amount,
                              widget.delivery_charges,
                              JebbyFee,
                              widget.security_deposit,
                              zipCode,
                              countryCode));
                        } else {
                          String message = "Fields Cannot Be Empty";
                          if (_locationController.text.toString().isEmpty) {
                            message = "Please enter location";
                          }
                          final snackBar = new SnackBar(content: new Text(message));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Container(
                      width: 310,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xffFEB038),
                      ),
                      child: Center(
                        child: Text(
                          "Order Now",
                          style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Inter, Bold"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
            ]),
          ),
        ),
      ),
    );
  }

// Future<void> initPaymentSheet() async {
//     try {
//       // 1. create payment intent on the server
//       final data = await _createTestPaymentSheet();

//       // 2. initialize the payment sheet
//      await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           // Enable custom flow
//           customFlow: true,
//           // Main params
//           merchantDisplayName: 'Flutter Stripe Store Demo',
//           paymentIntentClientSecret: data['paymentIntent'],
//           // Customer keys
//           customerEphemeralKeySecret: data['ephemeralKey'],
//           customerId: data['customer'],
//           // Extra options
//           // testEnv: true,
//           // applePay: true,
//           // googlePay: true,
//           // style: ThemeMode.dark,
//           // merchantCountryCode: 'DE',
//         ),
//       );
//       setState(() {
//         _ready = true;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       rethrow;
//     }
// }

  TxtfldforLocation(txt, _controller) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: res_height * 0.02,
          ),
          Text(
            txt,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: res_height * 0.005,
          ),
          Container(
            // height: 70,
            width: res_width * 0.89,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _onChanged();
                });
              },
              maxLines: 1,
              controller: _locationController,
              decoration: InputDecoration(
                // hintText:placholder,
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
        ],
      ),
    );
  }
}
