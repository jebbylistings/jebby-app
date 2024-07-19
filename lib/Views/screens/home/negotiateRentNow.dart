// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:intl/intl.dart';
// import 'package:jared/Services/provider/sign_in_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// import '../../../model/user_model.dart';
// import '../../../res/app_url.dart';
// import '../../../view_model/apiServices.dart';
// import '../../../view_model/user_view_model.dart';
// import '../../helper/colors.dart';
// import 'SelectPaymentMethod.dart';

// class NegotiateRentNow extends StatefulWidget {
//   var id;
//   NegotiateRentNow({this.id});

//   @override
//   State<NegotiateRentNow> createState() => _NegotiateRentNowState();
// }

// class _NegotiateRentNowState extends State<NegotiateRentNow> {
//   bool ProdLoader = true;
//   bool ProdError = false;
//   bool emptyProd = false;

//   late var prodID;

//   var pastart = "2023-01-01";
//   var paend = "2023-01-01";
//   late var price;

//   void getProducts() {
//     ApiRepository.shared.getProductsById(
//         (list) => {
//               if (this.mounted)
//                 {
//                   if (list.data!.length == 0)
//                     {
//                       setState(() {
//                         ProdLoader = false;
//                         ProdError = false;
//                         emptyProd == true;
//                       }),
//                     }
//                   else
//                     {
//                       print("Product ID --> ${ApiRepository.shared.getProductsByIdList?.data![0].productId}"),
//                       setState(() {
//                         pastart = ApiRepository.shared.getProductsByIdList!.data![0].pastart.toString();
//                         paend = ApiRepository.shared.getProductsByIdList!.data![0].paend.toString();
//                         prodID = ApiRepository.shared.getProductsByIdList!.data![0].productId.toString();
//                         price = ApiRepository.shared.getProductsByIdList!.data![0].price.toString();
//                         ProdLoader = false;
//                         ProdError = false;
//                         emptyProd == false;
//                       }),
//                     }
//                 }
//             },
//         (error) => {
//               if (error != null)
//                 {
//                   setState(() {
//                     ProdLoader = true;
//                     ProdError = true;
//                     emptyProd = false;
//                   })
//                 }
//             },
//         widget.id.toString());
//   }

//   bool onlinepay = false;
//   bool cod = false;

//   var fromdate;
//   var todate;

//   DateTime selectedDate = DateTime.now();
//   DateTime selectedDate1 = DateTime.now();

//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();

//   var _locationController = TextEditingController();
//   var Latitiude = "";
//   var Longitude = "";
//   var uuid = new Uuid();
//   List<dynamic> _placeList = [];
//   String _sessionToken = '1234567890';

//   Future<void> _selectDate1(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.parse(pastart),
//       firstDate: DateTime.parse(pastart),
//       lastDate: DateTime.parse(paend),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate1 = picked;
//       });
//     }
//   }

//   var myFormat = DateFormat('yyyy-MM-dd');
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context, initialDate: DateTime.parse(pastart), firstDate: DateTime.parse(pastart), lastDate: DateTime.parse(paend));
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   _onChanged() {
//     if (_sessionToken == null) {
//       setState(() {
//         _sessionToken = uuid.v4();
//       });
//     }
//     getSuggestion(_locationController.text);
//   }

//   void getSuggestion(String input) async {
//     String type = '(regions)';

//     try {
//       String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//       String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
//       var response = await http.get(Uri.parse(request));
//       var data = jsonDecode(response.body);
//       // log('mydata');
//       // log(response.body.toString());
//       if (response.statusCode == 200) {
//         setState(() {
//           _placeList = json.decode(response.body)['predictions'];
//         });
//       } else {
//         throw Exception('Failed to load predictions');
//       }
//     } catch (e) {
//       // toastMessage('success');
//     }
//   }

//   void initState() {
//     getData();
//     profileData(context);
//     getProducts();
//     super.initState();
//   }

//   Future getData() async {
//     final sp = context.read<SignInProvider>();
//     final usp = context.read<UserViewModel>();
//     usp.getUser();
//     sp.getDataFromSharedPreferences();
//   }

//   Future<UserModel> getUserDate() => UserViewModel().getUser();

//   String? token;
//   String userID = "";
//   String? fullname;
//   String? email;
//   String? role;
//   void profileData(BuildContext context) async {
//     getUserDate().then((value) async {
//       token = value.token.toString();
//       userID = value.id.toString();
//       fullname = value.name.toString();
//       email = value.email.toString();
//       role = value.role.toString();
//       getUserData();
//       print("User: ${userID}");
//     }).onError((error, stackTrace) {
//       if (kDebugMode) {
//         print(error.toString());
//       }
//     });
//   }

//   bool userLoader = true;
//   bool userError = false;
//   bool userEmpty = false;

//   String vendorName = "";
//   String vendorAddress = "";
//   String cell = "";
//   String vendorImage = "";
//   late var vendorBackImage;
//   late var vendorAccountId;
//   late var vendorPPEmail;

//   void getUserData() {
//     ApiRepository.shared.userCredential(
//         (List) => {
//               if (this.mounted)
//                 {
//                   if (List.data!.length == 0)
//                     {
//                       setState(() {
//                         print("EMPTY USER DATA");
//                         userLoader = false;
//                         userError = false;
//                         userEmpty = true;
//                         vendorName = "Vendor";
//                         vendorAddress = "";
//                         cell = "";
//                         vendorImage = "";
//                         vendorBackImage = "";
//                       })
//                     }
//                   else
//                     {
//                       setState(() {
//                         userError = false;
//                         userLoader = false;
//                         userEmpty = false;
//                         vendorName = ApiRepository.shared.getUserCredentialModelList!.data![0].name.toString();
//                         vendorAddress = ApiRepository.shared.getUserCredentialModelList!.data![0].address.toString();
//                         cell = ApiRepository.shared.getUserCredentialModelList!.data![0].number.toString();
//                         vendorImage = ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString();
//                         vendorBackImage = ApiRepository.shared.getUserCredentialModelList!.data![0].backImage.toString();
//                         vendorAccountId = ApiRepository.shared.getUserCredentialModelList!.data![0].accountId.toString();
//                         vendorPPEmail = ApiRepository.shared.getUserCredentialModelList!.data![0].paypalEmail.toString();
//                       })
//                     }
//                 }
//             },
//         (error) => {
//               if (error != null)
//                 {
//                   setState(() {
//                     userError = true;
//                     userLoader = false;
//                     userEmpty = false;
//                     vendorName = "Vendor";
//                     vendorAddress = "";
//                     cell = "";
//                     vendorImage = "";
//                     vendorBackImage = "";
//                   }),
//                 },
//             },
//         userID);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: GestureDetector(
//           onTap: () {
//             Get.back();
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(17.0),
//             child: Container(
//               child: Icon(
//                 Icons.arrow_back,
//                 color: Colors.black,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: ProdError ? Center(child: Text("Error in loading data")) :
//       ProdLoader ? Center(child: Text("Loading")) :
//       emptyProd ? Center(child: Text("Product Not Found")) :
//        Container(
//         width: double.infinity,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: SingleChildScrollView(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Align(
//                 alignment: Alignment.center,
//                 child: ApiRepository.shared.getProductsByIdList!.data![1].images!.length > 0
//                     ? SizedBox(
//                         height: 150,
//                         child: ListView.separated(
//                             scrollDirection: Axis.horizontal,
//                             shrinkWrap: true,
//                             separatorBuilder: (context, index) => SizedBox(
//                                   width: 10,
//                                 ),
//                             itemCount: ApiRepository.shared.getProductsByIdList!.data![1].images!.length,
//                             itemBuilder: (context, int index) {
//                               var img = ApiRepository.shared.getProductsByIdList?.data?[1].images?[index].path;
//                               return Container(
//                                 child: Image.network(
//                                   AppUrl.baseUrlM + img.toString(),
//                                   fit: BoxFit.fill,
//                                 ),
//                               );
//                             }),
//                       )
//                     : Text("No Images"),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     ApiRepository.shared.getProductsByIdList!.data![0].name.toString(),
//                     style: TextStyle(fontSize: 28, color: Colors.black, fontFamily: "Inter, Regular"),
//                   ),
//                   RatingBarIndicator(
//                     rating: double.parse(ApiRepository.shared.getProductsByIdList!.data![0].stars.toString()),
//                     itemBuilder: (context, index) => Icon(
//                       Icons.star,
//                       color: Colors.amber,
//                     ),
//                     itemCount: 5,
//                     itemSize: 15,
//                     direction: Axis.horizontal,
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 12,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Rental Price",
//                     style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: "Inter, Regular"),
//                   ),
//                   Text(
//                     "${price} \$",
//                     style: TextStyle(fontSize: 25, color: Colors.black, fontFamily: "Inter, ExtraBold"),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Container(
//                 // margin: EdgeInsets.only(left: 7),
//                 //width: res_width * 0.01,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Rent Start',
//                           style: TextStyle(
//                             fontSize: 19,
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             _selectDate(context);
//                             fromdate = myFormat.format(selectedDate);
//                           },
//                           child: Container(
//                             width: res_width * 0.425,
//                             height: res_height * 0.06,
//                             decoration: BoxDecoration(
//                               // color: Colors.orange,
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     myFormat.format(selectedDate),
//                                     style: TextStyle(fontSize: 11),
//                                   ),
//                                   Icon(
//                                     Icons.calendar_month,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     // SizedBox(
//                     //   width: res_width * 0.38,
//                     // ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Original Return',
//                             style: TextStyle(
//                               fontSize: 19,
//                             )),
//                         GestureDetector(
//                           onTap: () {
//                             _selectDate1(context);
//                             todate = myFormat.format(selectedDate1);
//                           },
//                           child: Container(
//                             width: res_width * 0.425,
//                             height: res_height * 0.06,
//                             decoration: BoxDecoration(
//                               // color: Colors.orange,
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     myFormat.format(selectedDate1),
//                                     style: TextStyle(fontSize: 11),
//                                   ),
//                                   Icon(
//                                     Icons.calendar_month,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Name",
//                         style: TextStyle(fontSize: 17, color: Colors.black),
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Container(
//                         width: 365,
//                         height: 58,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             width: 1,
//                             color: Color(0xffFEB038),
//                           ),
//                         ),
//                         child: TextFormField(
//                           controller: nameController,
//                           style: TextStyle(
//                             fontSize: 17,
//                             color: Colors.black,
//                           ),
//                           keyboardType: TextInputType.text,
//                           decoration: InputDecoration(
//                             disabledBorder: InputBorder.none,
//                             errorBorder: InputBorder.none,
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.only(left: 10, top: 5),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(
//                       "Email",
//                       style: TextStyle(fontSize: 17, color: Colors.black),
//                     ),
//                     SizedBox(
//                       height: 5,
//                     ),
//                     Container(
//                       width: 365,
//                       height: 58,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           width: 1,
//                           color: Color(0xffFEB038),
//                         ),
//                       ),
//                       child: TextFormField(
//                         controller: emailController,
//                         style: TextStyle(
//                           fontSize: 17,
//                           color: Colors.black,
//                         ),
//                         keyboardType: TextInputType.text,
//                         decoration: InputDecoration(
//                           disabledBorder: InputBorder.none,
//                           errorBorder: InputBorder.none,
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.only(left: 10, top: 5),
//                         ),
//                       ),
//                     ),
//                   ]),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TxtfldforLocation("Location", _locationController),
//               SizedBox(
//                 height: res_height * 0.15,
//                 child: ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _placeList.length,
//                     itemBuilder: ((context, index) {
//                       String name = _placeList[index]["description"];

//                       if (_locationController.text.isEmpty) {
//                         return Text("");
//                       } else if (name.toLowerCase().contains(_locationController.text.toLowerCase())) {
//                         return ListTile(
//                           onTap: () async {
//                             _locationController.text = _placeList[index]["description"];
//                             List<Location> location = await locationFromAddress(_placeList[index]["description"]);
//                             setState(() {
//                               _locationController.removeListener(() {});
//                               Latitiude = location.last.latitude.toString();
//                               Longitude = location.last.longitude.toString();
//                               print("Latitude: ${location.last.latitude.toString()}");
//                               print("Longitude: ${location.last.longitude.toString()}");
//                               _placeList = [];
//                             });
//                           },
//                           leading: CircleAvatar(child: Icon(Icons.pin_drop, color: Colors.white)),
//                           title: Text(_placeList[index]["description"]),
//                         );
//                       } else {
//                         return Container();
//                       }
//                     })),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Column(
//                 children: [
//                   Text(
//                     "Owner Info",
//                     style: TextStyle(fontSize: 24, color: Colors.black, fontFamily: "Inter, Bold"),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                           width: 67,
//                           height: 67,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                           ),
//                           child: vendorImage == ""
//                               ? Image.asset("assets/slicing/blankuser.jpeg", fit: BoxFit.fill)
//                               : Image.network(
//                                   AppUrl.baseUrlM + ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString(),
//                                   fit: BoxFit.contain,
//                                 )),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             vendorName == "" ? "Vendor" : vendorName,
//                             style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: "Inter, Bold"),
//                           ),
//                           Text(
//                             vendorAddress == "" ? "" : vendorAddress,
//                             style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.53), fontFamily: "Inter, Light"),
//                           ),
//                           Text(
//                             cell == "" ? "" : cell,
//                             style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: "Inter, Light"),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         onlinepay = false;
//                         print("LBD");
//                         // cod = false;
//                       });
//                     },
//                     child: Container(
//                       height: 19,
//                       width: 19,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle, border: Border.all(color: onlinepay == false ? Color(0xff303030) : Colors.black, width: 3)),
//                       child: Icon(
//                         Icons.circle_rounded,
//                         color: onlinepay == false ? Color(0xff303030) : Colors.white,
//                         size: 13,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     "Online Payment",
//                     style: TextStyle(fontSize: 21, color: Colors.black, fontFamily: "Inter, Regular"),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         onlinepay = true;
//                         print("COD");
//                         // cod = true;
//                       });
//                     },
//                     child: Container(
//                       height: 19,
//                       width: 19,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle, border: Border.all(color: onlinepay == true ? Color(0xff303030) : Colors.black, width: 3)),
//                       child: Icon(
//                         Icons.circle_rounded,
//                         color: onlinepay == true ? Color(0xff303030) : Colors.white,
//                         size: 13,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     "COD",
//                     style: TextStyle(fontSize: 21, color: Colors.black, fontFamily: "Inter, Regular"),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 15,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       int diff = selectedDate1.difference(selectedDate).inDays + 1;
//                       int amount = int.parse(price.toString()) * diff;
//                       print(amount);
//                       if (onlinepay == true) {
//                         if (emailController.text.isNotEmpty && _locationController.text.toString().isNotEmpty && nameController.text.isNotEmpty) {
//                           final snackBar = new SnackBar(content: new Text("Please Wait"));
//                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                           ApiRepository.shared.postOrder(
//                               context,
//                               userID,
//                               widget.id,
//                               DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
//                               DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
//                               fullname,
//                               emailController.text.toString(),
//                               _locationController.text.toString(),
//                               Latitiude,
//                               Longitude);
//                         } else {
//                           final snackBar = new SnackBar(content: new Text("Fields Cannot Be Empty"));
//                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         }
//                       } else {
//                         if (vendorAccountId == "0" ||
//                             vendorPPEmail == "0" ||
//                             vendorAccountId == "" ||
//                             vendorPPEmail == "" ||
//                             vendorAccountId == 0 ||
//                             vendorPPEmail == 0) {
//                           final snackBar = new SnackBar(content: new Text("Online pay not available"));
//                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         } else if (emailController.text.isNotEmpty &&
//                             _locationController.text.toString().isNotEmpty &&
//                             nameController.text.isNotEmpty) {
//                           Get.to(() => SelectPaymentMethodScreen(
//                               amount,
//                               vendorAccountId,
//                               vendorPPEmail,
//                               userID,
//                               widget.id,
//                               DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
//                               DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
//                               fullname,
//                               emailController.text.toString(),
//                               _locationController.text.toString(),
//                               Latitiude,
//                               Longitude));
//                         } else {
//                           final snackBar = new SnackBar(content: new Text("Fields Cannot Be Empty"));
//                           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                         }
//                       }
//                     },
//                     child: Container(
//                       width: 310,
//                       height: 58,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: Color(0xffFEB038),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Order Now",
//                           style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Inter, Bold"),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 50,
//               ),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   TxtfldforLocation(txt, _controller) {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: res_height * 0.02,
//           ),
//           Text(txt),
//           SizedBox(
//             height: res_height * 0.005,
//           ),
//           Container(
//             height: 70,
//             width: res_width * 0.9,
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _onChanged();
//                 });
//               },
//               maxLines: 1,
//               controller: _locationController,
//               decoration: InputDecoration(
//                 // hintText:placholder,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: kprimaryColor, width: 1),
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: kprimaryColor, width: 1),
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
