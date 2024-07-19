import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../../view_model/apiServices.dart';

class AddProduct2Screen extends StatefulWidget {
  var user_id;
  var SecurityDeposite;

  AddProduct2Screen({this.user_id, this.SecurityDeposite});

  @override
  State<AddProduct2Screen> createState() => _AddProduct2ScreenState();
}

class _AddProduct2ScreenState extends State<AddProduct2Screen> {
  bool add_button = false;
  int _groupValue = -1;
  String dropdownValue = 'One';
  var _locationController = TextEditingController();
  var Latitiude;
  var Longitude;
  var uuid = new Uuid();
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';
  var proAvaStarDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var nextDate= DateTime.now().add(Duration(days: 1));
  var proAvaEndDate = "";
  var disAvaStarDate = "2023-09-01";
  var disAvaEndDate = "2023-12-31";
  DateTime? selDate;
  bool isError = false;
  bool isLoading = true;
  var productID;
  var categoryID;
  late int freePickUp = 1;
  late int locationBasedDelivery = 0;
  TextEditingController price_1_Controller = TextEditingController();
  TextEditingController price_2_Controller = TextEditingController();
  TextEditingController discountController = TextEditingController();

  void initState() {
    getLastVendorProduct();
    proAvaEndDate = DateFormat('yyyy-MM-dd').format(nextDate);

    super.initState();
  }

  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_locationController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = dotenv.env['kPLACES_API_KEY'] ?? 'No secret key found';
    String type = '(regions)';

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
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

  getLastVendorProduct() {
    ApiRepository.shared.getLastProductByVendorId((list) {
      if (list.data == null) {
        productID = ApiRepository.shared.lastVendorProductList?.data?.id;
        categoryID =
            ApiRepository.shared.lastVendorProductList?.data?.subcategoryId;
        print("product id --> ${productID}");
        print("product id --> ${categoryID}");
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        productID = ApiRepository.shared.lastVendorProductList?.data?.id;
        categoryID =
            ApiRepository.shared.lastVendorProductList?.data?.subcategoryId;
        print("product id --> ${productID}");
        print("product id --> ${categoryID}");
        setState(() {
          isLoading = false;
        });
      }
    }, (error) {
      if (this.mounted) {
        if (error != null) {
          setState(() {
            isLoading = false;
            isError = true;
            print("Error:  ${error}");
          });
        }
      }
    }, widget.user_id);
  }

  addProd2() async {
    setState(() {
      add_button = true;
    });

    if (!productID.toString().isEmpty &&
        !widget.user_id.toString().isEmpty &&

        !categoryID.toString().isEmpty &&
        !proAvaStarDate.toString().isEmpty &&
        !proAvaEndDate.toString().isEmpty &&


        !Latitiude.toString().isEmpty &&
        !Longitude.toString().isEmpty &&
        _locationController.text.toString().isNotEmpty
        ) {
          if(DateTime.parse(proAvaStarDate.toString()).isAfter(DateTime.parse(proAvaEndDate.toString())) ||
    DateTime.parse(proAvaStarDate.toString()).isAtSameMomentAs(DateTime.parse(proAvaEndDate.toString()))){
            final snackBar = new SnackBar(content: new Text("End Date must be greater than Start Date"));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print('End Date must be greater than Start Date');
          }
      else{
        ApiRepository.shared.postProductInfo(
          productID.toString(),
          widget.user_id.toString(),
          // price_1_Controller.text.toString(),
          "0", //price1
          categoryID,
          freePickUp,
          locationBasedDelivery,
          proAvaStarDate.toString(),
          proAvaEndDate.toString(),
          // disAvaStarDate.toString(),
          proAvaStarDate.toString(), // discount ava
          // disAvaEndDate.toString(),
          proAvaEndDate.toString(), // discount end
          // price_2_Controller.text.toString(),
          "0", //price2
          // discountController.text.toString(),
          "0", //discount
          Latitiude.toString(),
          Longitude.toString(),
          widget.SecurityDeposite.toString(),
          (list) {},
          (error) {});
      // Get.to(() => GeneratePromoCode());
      var postData = {
        "product_id": productID.toString(),
        "user_id": widget.user_id.toString(),
        "price": "0",
        "per": 1,
        "subcat_id": categoryID,
        "fp": freePickUp.toString(),
        "lbd": locationBasedDelivery.toString(),
        "pastart": proAvaStarDate.toString(),
        "paend": proAvaEndDate.toString(),
        "dastart": proAvaStarDate.toString(),
        "daend": proAvaEndDate.toString(),
        "price1": "0",
        "discount": "0",
        "latitude": Latitiude.toString(),
        "longitude": Longitude.toString(),
        "security_deposit":widget.SecurityDeposite.toString(),
      };
      print("Posting Data $postData");
      // print(postData);

      final snackBar = new SnackBar(content: new Text("Uploaded"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {

      String message= "Fields Cannot Be Empty";
      if(_locationController.text.toString().isEmpty){
        message="Please enter location";
      }
      final snackBar =
          new SnackBar(content: new Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }
    setState(() {
      add_button = false;
    });
  }

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
          'General Information',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          //     keyboardType: TextInputType.number,
                          //     controller: price_1_Controller,
                          //     decoration: InputDecoration(
                          //       hintText: '500 \$',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(15.0),
                          //       ),
                          //       enabledBorder: const OutlineInputBorder(
                          //         borderSide: const BorderSide(
                          //             color: kprimaryColor, width: 1),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(15)),
                          //       ),
                          //       focusedBorder: const OutlineInputBorder(
                          //         borderSide: const BorderSide(
                          //             color: kprimaryColor, width: 1),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(15)),
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
                          TxtfldforLocation("Location", _locationController),
                          SizedBox(
                            height: res_height * .1,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: _placeList.length,
                                itemBuilder: ((context, index) {
                                  String name =
                                      _placeList[index]["description"];

                                  if (_locationController.text.isEmpty) {
                                    return Text("");
                                  } else if (name.toLowerCase().contains(
                                      _locationController.text.toLowerCase())) {
                                    return ListTile(
                                      onTap: () async {
                                        _locationController.text =
                                            _placeList[index]["description"];
                                        List<Location> location =
                                            await locationFromAddress(
                                                _placeList[index]
                                                    ["description"]);
                                        // log("Latitiude : " + location.last.latitude.toString());
                                        // log("Longitude : " + location.last.longitude.toString());

                                        setState(() {
                                          _locationController
                                              .removeListener(() {});
                                          Latitiude =
                                              location.last.latitude.toString();
                                          Longitude = location.last.longitude
                                              .toString();
                                          print(
                                              "Latitude: ${location.last.latitude.toString()}");
                                          print(
                                              "Longitude: ${location.last.longitude.toString()}");
                                          _placeList = [];
                                        });
                                      },
                                      leading: CircleAvatar(
                                          child: Icon(Icons.pin_drop,
                                              color: Colors.white)),
                                      title: Text(
                                          _placeList[index]["description"]),
                                    );
                                  } else {
                                    return Container();
                                  }
                                })),
                          ),

                          // Text('Per'),
                          // SizedBox(
                          //   height: res_height * 0.005,
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 5),
                          //   child: Center(
                          //     child: Container(
                          //       child: TextField(
                          // child: DropdownButtonFormField(
                          //   hint: Text(
                          //       'Select option'), // Not necessary for Option 1

                          //   items: [
                          //     {"value": "Login", "label": "Login"},
                          //     {"value": "Create", "label": "Create"},
                          //     {"value": "Read", "label": "Read"},
                          //     {"value": "Update", "label": "Update"},
                          //     {"value": "Delete", "label": "Delete"},
                          //     {"value": "Print", "label": "Print"},
                          //     {"value": "Email", "label": "Email"},
                          //     {"value": "Sms", "label": "Sms"},
                          //     {
                          //       "value": "Upload Image",
                          //       "label": "Upload Image"
                          //     },
                          //     {"value": "Read All", "label": "Read All"}
                          //   ].map((category) {
                          //     return new DropdownMenuItem(
                          //         value: category['value'],
                          //         child: Text(
                          //           category['label'].toString(),
                          //           style: TextStyle(
                          //               color: Color(0xffbdbdbd),
                          //               fontFamily: 'UbuntuRegular'),
                          //         ));
                          //   }).toList(),
                          //   onChanged: (newValue) {
                          //     setState(() {
                          //       var _selectActionsText;
                          //       _selectActionsText.text = newValue;
                          //     });
                          //   },
                          //         decoration: new InputDecoration(
                          //           border: new OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
                          //               const Radius.circular(15.0),
                          //             ),
                          //           ),
                          //           enabledBorder: new OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
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
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
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
                          // Text('Add Category'),
                          // SizedBox(
                          //   height: res_height * 0.005,
                          // ),
                          // // dropdown('Select'),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 5),
                          //   child: Center(
                          //     child: Container(
                          //       child: DropdownButtonFormField(
                          //         hint: Text(
                          //             'Select option'), // Not necessary for Option 1

                          //         items: [
                          //           {"value": "Login", "label": "Login"},
                          //           {"value": "Create", "label": "Create"},
                          //           {"value": "Read", "label": "Read"},
                          //           {"value": "Update", "label": "Update"},
                          //           {"value": "Delete", "label": "Delete"},
                          //           {"value": "Print", "label": "Print"},
                          //           {"value": "Email", "label": "Email"},
                          //           {"value": "Sms", "label": "Sms"},
                          //           {
                          //             "value": "Upload Image",
                          //             "label": "Upload Image"
                          //           },
                          //           {"value": "Read All", "label": "Read All"}
                          //         ].map((category) {
                          //           return new DropdownMenuItem(
                          //               value: category['value'],
                          //               child: Text(
                          //                 category['label'].toString(),
                          //                 style: TextStyle(
                          //                     color: Color(0xffbdbdbd),
                          //                     fontFamily: 'UbuntuRegular'),
                          //               ));
                          //         }).toList(),
                          //         onChanged: (newValue) {
                          //           setState(() {
                          //             var _selectActionsText;
                          //             _selectActionsText.text = newValue;
                          //           });
                          //         },
                          //         decoration: new InputDecoration(
                          //           border: new OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
                          //               const Radius.circular(15.0),
                          //             ),
                          //           ),
                          //           enabledBorder: new OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
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
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius: const BorderRadius.all(
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
                                    freePickUp = newValue;
                                    print("FREE PICKUP ${freePickUp}");
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
                                    locationBasedDelivery = newValue;
                                    print(
                                        "LOCATION BASED DELIVERY ${locationBasedDelivery}");
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: res_height * 0.005,
                          ),
                          itemdtl('Product Availibility', "1"),
                          SizedBox(
                            height: res_height * 0.005,
                          ),
                          // itemdtl('Discount Availibility', "2"),
                          // SizedBox(
                          //   height: res_height * 0.02,
                          // ),
                          // GestureDetector(
                          //   onTap: () {
                          //     Get.to(() => GeneratePromoCode());
                          //   },
                          //   child: Center(
                          //     child: Container(
                          //       width: 398,
                          //       height: 58,
                          //       decoration: BoxDecoration(
                          //           color: kprimaryColor,
                          //           borderRadius: BorderRadius.circular(12)),
                          //       child: Center(
                          //         child: Text(
                          //           'Add Promo Code',
                          //           style: TextStyle(
                          //               fontWeight: FontWeight.bold, fontSize: 15),
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
                          //   height: 75,
                          //   width: res_width * 0.7,
                          //   child: TextField(
                          //     keyboardType: TextInputType.number,
                          //     controller: price_2_Controller,
                          //     decoration: InputDecoration(
                          //       hintText: 'Enter Price',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(15.0),
                          //       ),
                          //       enabledBorder: const OutlineInputBorder(
                          //         borderSide: const BorderSide(
                          //             color: kprimaryColor, width: 1),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(15)),
                          //       ),
                          //       focusedBorder: const OutlineInputBorder(
                          //         borderSide: const BorderSide(
                          //             color: kprimaryColor, width: 1),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(15)),
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
                          // Row(
                          //   children: [
                          //     Container(
                          //       height: 50,
                          //       width: res_width * 0.4,
                          //       child: TextField(
                          //         keyboardType: TextInputType.number,
                          //         controller: discountController,
                          //         decoration: InputDecoration(
                          //           // hintText: '%',
                          //           border: OutlineInputBorder(
                          //             borderRadius: BorderRadius.circular(15.0),
                          //           ),
                          //           enabledBorder: const OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius:
                          //                 BorderRadius.all(Radius.circular(15)),
                          //           ),
                          //           focusedBorder: const OutlineInputBorder(
                          //             borderSide: const BorderSide(
                          //                 color: kprimaryColor, width: 1),
                          //             borderRadius:
                          //                 BorderRadius.all(Radius.circular(15)),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
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
                      //         SizedBox(
                      //           width: res_width * 0.05,
                      //         ),
                      //         Text(
                      //           '%',
                      //           style:
                      //               TextStyle(fontSize: 25, color: Colors.grey),
                      //         )
                      //       ],
                      //     ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.25,
                    ),
                    GestureDetector(
                      onTap: () {
                        add_button ? null : addProd2();
                      },
                      child: Center(
                        child: Container(
                          width: 380,
                          height: 58,
                          decoration: BoxDecoration(
                              color: add_button
                                  ? kprimaryColor.withOpacity(0.5)
                                  : kprimaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              add_button ? "Uploading" : 'Next',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
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
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: kprimaryColor, width: 1)),
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
            items: <String>['1', '2', '3', '4']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
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
                                      value == "1"
                                          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(proAvaStarDate)).toString()
                                          : DateFormat('dd/MM/yyyy').format(DateTime.parse(disAvaStarDate)).toString()
                                          ,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
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
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              print(pickedDate);
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate!);
                              print(formattedDate);
                              setState(() {
                                if (value == "1") {
                                  proAvaStarDate = formattedDate.toString();
                                } else {
                                  disAvaStarDate = formattedDate.toString();
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
                                child:
                                    Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3)),
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
                                      // DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                      value == "1"
                                          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(proAvaEndDate)).toString()
                                          : DateFormat('dd/MM/yyyy').format(DateTime.parse(disAvaEndDate)).toString(),
                                    style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () async {
                              // DateTime nextDate = DateTime.now().add(Duration(days: 1)); // Calculate the next date

                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: nextDate,
                                firstDate: nextDate,
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
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if(pickedDate!=null){
                                print(pickedDate);
                                nextDate=pickedDate;
                                String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                                print(formattedDate);
                                setState(() {
                                  if (value == "1") {
                                    proAvaEndDate = formattedDate.toString();
                                  } else {
                                    disAvaEndDate = formattedDate.toString();
                                  }
                                });

                              }

                              // if (picked != null && picked != selectedDate) {
                              //   setState(() {
                              //     selectedDate = picked;
                              //   });}
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child:
                                    Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3)),
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

  _myRadioButton({title, value, onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
      activeColor: kprimaryColor,
    );
  }

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
          Text(txt),
          SizedBox(
            height: res_height * 0.005,
          ),
          Container(
            height: 70,
            width: res_width * 0.9,
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
