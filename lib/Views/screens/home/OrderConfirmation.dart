import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/reOrderPayment.dart';
import 'package:jared/res/app_url.dart';
import 'package:jared/view_model/getTax_modal.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../view_model/apiServices.dart';

class OrderConfirmationScreen extends StatefulWidget {
  var image;
  var name;
  var price;
  var orderId;
  var prodId;
  var location;
  var long;
  var lat;
  var username;
  var userid;
  var vendorID;

  OrderConfirmationScreen(
      {this.image, this.name, this.price, this.orderId, this.prodId, this.location, this.long, this.lat, this.username, this.userid, this.vendorID});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getProducts() {
    ApiRepository.shared.getProductsById(
        (list) => {
              if (this.mounted)
                {
                  if (list.data!.length == 0)
                    {
                      setState(() {
                        isLoading = false;
                        isError = false;
                      }),
                    }
                  else
                    {
                      setState(() {
                        isLoading = false;
                        isError = false;
                      }),
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    isLoading = false;
                    isError = true;
                  })
                }
            },
        widget.prodId.toString());
  }

  late var vendorAccountId;
  late var vendorPPEmail;
  bool orderVisibility = false;
  var _locationController = TextEditingController();

  var newLocation = "";

  void getUserData() {
    ApiRepository.shared.userCredential(
        (List) => {
              if (this.mounted)
                {
                  if (List.data!.length == 0)
                    {}
                  else
                    {
                      setState(() {
                        vendorAccountId = ApiRepository.shared.getUserCredentialModelList!.data![0].accountId.toString();
                        vendorPPEmail = ApiRepository.shared.getUserCredentialModelList!.data![0].paypalEmail.toString();
                        orderVisibility = true;
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {}),
                },
            },
        widget.vendorID.toString());
  }

  var Latitiude = "";
  var Longitude = "";
  var uuid = new Uuid();
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';

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

  String? zipCode;
  String? countryCode;
  Future<void> _getZipCodeFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        zipCode = placemark.postalCode ?? '';
        countryCode = placemark.isoCountryCode ?? '';
        getSalesTax(placemark.postalCode ?? '');
        print("Country Code: $countryCode");
        print("ZIP Code: $zipCode");
      } else {
        print("ZIP Code not found.");
      }
    } catch (e) {
      print("Error getting ZIP Code: $e");
    }
  }

  double taxValue = 0;
  Future<void> getSalesTax(zipcode) async {
    String apiKey = dotenv.env['apiKey'] ?? 'No secret key found';
    final apiUrl = 'https://api.taxjar.com/v2/rates?zip=${zipcode}'; // API endpoint URL

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    // print("response ${response.body}");

    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);
      // Access the tax rates
      final taxRates = jsonResponse['rate']['combined_rate'];
      // Use taxRates for further processing
      setState(() {
        // taxRate = double.parse(taxRates);
        taxValue = double.parse(taxRates);
      });
      print("taxRates $taxValue");
    } else {
      // Handle errors here
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  var JebbyFee = 0;
  dynamic array = [];
  late Map<String, dynamic> _data;

  Future<void> _loadData() async {
    try {
      final data = await GetJebbyfee.fetchData();
      setState(() {
        _data = data;
        array = _data['data'];
      });
      JebbyFee = array.length > 0 ? int.parse(array[0]['jebby_fees'].toString()) : 0;
      print("array ===>  ${JebbyFee}");
    } catch (e) {
      print('error $e');
    }
  }

  bool locationVisibility = false;

  void initState() {
    _loadData();
    getUserData();
    getProducts();
    _getZipCodeFromCoordinates(widget.lat, widget.long);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Confirmation",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            borderRadius: BorderRadius.circular(50),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Contbox(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 390,
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              child: Text(
                                widget.username,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 300,
                              child: Text(
                                widget.location,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  locationVisibility = true;
                                });
                                // Get.to(() => ShippingAddressScreen(
                                //       location: widget.location.toString(),
                                //     ));
                              },
                              child: Container(
                                child: Text(
                                  "Change",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        locationVisibility ? TxtfldforLocation("Location", _locationController) : Text(""),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .1,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _placeList.length,
                              itemBuilder: ((context, index) {
                                String name = _placeList[index]["description"];

                                if (_locationController.text.isEmpty) {
                                  return Text("");
                                } else if (name.toLowerCase().contains(_locationController.text.toLowerCase())) {
                                  return ListTile(
                                    onTap: () async {
                                      _locationController.text = _placeList[index]["description"];
                                      List<Location> location = await locationFromAddress(_placeList[index]["description"]);

                                      setState(() {
                                        _locationController.removeListener(() {});
                                        Latitiude = location.last.latitude.toString();
                                        Longitude = location.last.longitude.toString();
                                        print("Latitude: ${location.last.latitude.toString()}");
                                        print("Longitude: ${location.last.longitude.toString()}");
                                        _getZipCodeFromCoordinates(location.last.latitude, location.last.longitude);
                                        _placeList = [];
                                      });
                                    },
                                    leading: CircleAvatar(child: Icon(Icons.pin_drop, color: Colors.white)),
                                    title: Text(_placeList[index]["description"]),
                                  );
                                } else {
                                  return Container();
                                }
                              })),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                ),
                subs("Sub Total", "${widget.price} \$"),
                subs("Sales Tax", "${taxValue * 100} \$"),
                subs("Jebby Fee", "${int.parse(widget.price) * JebbyFee / 100} \$"),
                subs("Total", "${(int.parse(widget.price) + (int.parse(widget.price) * JebbyFee / 100) + (taxValue * 100)).round()} \$"),
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    if (orderVisibility) {
                      ApiRepository.shared.reOrderStripePayment(widget.price, vendorAccountId, context, widget.orderId,
                          newLocation == "" ? widget.location : newLocation, ((int.parse(widget.price) * JebbyFee / 100) + (taxValue * 100)).round());
                      //  Get.to(() => ReOrderPayment(
                      //           accountId: vendorAccountId,
                      //           paypalMail: vendorPPEmail,
                      //           price: widget.price,
                      //           orderId: widget.orderId,
                      //           location: newLocation == "" ? widget.location : newLocation,
                      //           applicationFee: ((int.parse(widget.price) * JebbyFee / 100) +  (taxValue * 100)).round()
                      //         ));
                    }
                  },
                  child: Container(
                    height: 58,
                    width: 371,
                    child: Center(
                      child: Text(
                        'Pay Now',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: orderVisibility ? kprimaryColor : kprimaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Contbox() {
    return Column(
      children: [
        Container(
          width: 391,
          height: 169,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.network(AppUrl.baseUrlM + widget.image.toString()),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 159,
                              child: Text(
                                widget.name,
                                style: TextStyle(fontSize: 14),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "${widget.price} \$",
                            style: TextStyle(fontSize: 14),
                          ),
                          isLoading
                              ? Container()
                              : Row(
                                  children: [
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
                                    Text(
                                      "(${ApiRepository.shared.getProductsByIdList!.data![0].length.toString()}) Reviews",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Container(
                //       height: 44,
                //       width: 170,
                //       child: Center(
                //         child: Text(
                //           'Type Review',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 19),
                //         ),
                //       ),
                //       decoration: BoxDecoration(
                //           color: kprimaryColor,
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //     Container(
                //       height: 44,
                //       width: 170,
                //       child: Center(
                //         child: Text(
                //           'Reorder',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 19),
                //         ),
                //       ),
                //       decoration: BoxDecoration(
                //           color: kprimaryColor,
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  subs(
    txt,
    txt2,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              txt,
            ),
            Text(
              txt2,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: 399,
          height: 1,
          color: Colors.grey,
        )
      ],
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
                  value != "" ? newLocation = value : null;
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
