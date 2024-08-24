import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/controller/bottomcontroller.dart';
import 'package:jared/Views/screens/home/filteredData.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FilterScreeen extends StatefulWidget {
  const FilterScreeen({super.key});

  @override
  State<FilterScreeen> createState() => _FilterScreeenState();
}

class _FilterScreeenState extends State<FilterScreeen> {
  var fromDate = null;
  var toDate = null;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();

  // late var fromDate;
  // late var toDate;

  bool notSearch = true;

  double _value = 20;

  double _Pvalue = 50;
  double _Rvalue = 20;

  var radius = 0;
  var price = 0;
  late String url;
  var _locationController = TextEditingController();
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';
  var uuid = new Uuid();
  var Latitiude;
  var Longitude;
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
  late var selected_sub_id = null;
  bool isError = false;
  bool isLoading = true;
  bool sub_categoryLoader = true;
  bool sub_categoryError = false;
  bool subCategoryVisibility = false;
  bool filteredData = false;
  bool filteredError = false;
  bool emptyFilteredData = false;
  late var snackBar;

  bool radiusVisibility = false;

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
      var data = json.decode(response.body);
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

  getCategory() {
    ApiRepository.shared.getCategoryList(
        (List) => {
              if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      setState(() {
                        dropdownValue = items.first;
                        isLoading = false;
                        isError = true;
                      }),
                    }
                  else
                    {
                      name_length =
                          ApiRepository.shared.categoryList?.data?.length,
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
                      sub_items = [],
                      sub_items_id = [],
                      sub_length =
                          ApiRepository.shared.subCategoryList?.data?.length,
                      for (int i = 0; i < sub_length!; i++)
                        {
                          sub_name = ApiRepository
                              .shared.subCategoryList?.data?[i].name,
                          sub_id =
                              ApiRepository.shared.subCategoryList?.data?[i].id,
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

  getData(url) {
    
    setState(() {
      filteredData = true;
    });
    ApiRepository.shared.filteredData(
        (List) => {
              if (this.mounted)
                {
                  if (List.data!.length == 0)
                    {
                      setState(() {
                        emptyFilteredData = true;
                        filteredData = false;
                        filteredError = false;
                      }),
                      snackBar =
                          new SnackBar(content: new Text("No data found")),
                      ScaffoldMessenger.of(context).showSnackBar(snackBar),
                    }
                  else
                    {
                      setState(() {
                        
                        emptyFilteredData = false;
                        filteredData = false;
                        filteredError = false;
                        filteredData = false;
                        Latitiude = null;
                        Longitude = null;
                        radius = 0;
                        price = 0;
                        toDate = null;
                        fromDate = null;
                        _Pvalue = 50;
                        _Rvalue = 20;
                      }),
                      Get.to(() => FilteredData(
                            subCatname: sub_dropdownvalue,
                          ))
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    filteredError = true;
                  }),
                  snackBar = new SnackBar(content: new Text("Error Occured")),
                  ScaffoldMessenger.of(context).showSnackBar(snackBar)
                },
            },
        url);
    setState(() {
      filteredData = false;
    });
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate1 = picked;
        toDate = DateFormat('yyyy-MM-dd').format(selectedDate1);
        
      });
    }
  }

  var myFormat = DateFormat('yyyy-MM-dd');
  var myFormat1 = DateFormat('dd/MM/yyyy');
  var myFormat2 = DateFormat('MM/dd/yyyy');
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fromDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        
      });
    }
  }

  void initState() {
    getCategory();
    super.initState();
  }
  final bottomctrl = Get.put(BottomController());
  @override
  Widget build(BuildContext context) {
    var res_height = MediaQuery.of(context).size.height;
    var res_width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              bottomctrl.navBarChange(0);
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Filter',
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  Text(
                    "Reset",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          Latitiude = null;
                          Longitude = null;
                          _locationController.text = "";
                          radius = 0;
                          price = 0;
                          toDate = null;
                          fromDate = null;
                          _Pvalue = 50;
                          _Rvalue = 20;
                          selectedDate = DateTime.now();
                          selectedDate1 = DateTime.now();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        body: notSearch
            ? Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: res_height * 0.015,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          //width: res_width * 0.01,
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Date From : ',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectDate(context);
                                      fromDate = myFormat.format(selectedDate);
                                    },
                                    child: Container(
                                      width: res_width * 0.225,
                                      decoration: BoxDecoration(
                                        // color: Colors.orange,
                                        border:
                                            Border.all(color: kprimaryColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            myFormat2.format(selectedDate),
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: res_width * 0.02,
                              ),
                              Row(
                                children: [
                                  Text('To : ',
                                      style: TextStyle(
                                        fontSize: 13,
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      _selectDate1(context);
                                      toDate = myFormat.format(selectedDate1);
                                    },
                                    child: Container(
                                      width: res_width * 0.225,
                                      decoration: BoxDecoration(
                                        // color: Colors.orange,
                                        border:
                                            Border.all(color: Colors.orange),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            myFormat2.format(selectedDate1),
                                            style: TextStyle(fontSize: 11),
                                          ),
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
                          height: res_height * 0.02,
                        ),
                        TxtfldforLocation("Location", _locationController),
                        SizedBox(
                          // height: _locationController.text.isNotEmpty ?res_height * .15 : res_height * .03,
                          child: 
                          ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: _placeList.length,
                              itemBuilder: ((context, index) {
                                String name = _placeList[index]["description"];

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
                                              _placeList[index]["description"]);
                                      // log("Latitiude : " + location.last.latitude.toString());
                                      // log("Longitude : " + location.last.longitude.toString());

                                      setState(() {
                                        _locationController
                                            .removeListener(() {});
                                        Latitiude =
                                            location.last.latitude.toString();
                                        Longitude =
                                            location.last.longitude.toString();
                                        
                                        _placeList = [];
                                      });
                                    },
                                    leading: CircleAvatar(
                                        child: Icon(Icons.pin_drop,
                                            color: Colors.white)),
                                    title:
                                        Text(_placeList[index]["description"]),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              })),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          child: Text(
                            "Set Distance",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 30,
                                  width: 371,
                                  child: CupertinoSlider(
                                    thumbColor: Colors.white,
                                    activeColor: Colors.black,
                                    min: 0.0,
                                    max: 1000.0,
                                    value: _Rvalue,
                                    onChanged: (value) {
                                      setState(() {
                                        _Rvalue = value;
                                        radius =
                                            int.parse(value.toStringAsFixed(0));
                                      });
                                    },
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              radius == 0 ? "0" : "${radius.toString()} mi",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            Text(
                              "1000mi",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          child: Text(
                            "Categories",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          height: 50,
                          width: res_width * 0.9,
                          child: isLoading
                              ? Center(
                                  child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator()),
                                )
                              : FutureBuilder(builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                  return DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    style:
                                        const TextStyle(color: kprimaryColor),
                                    underline: Container(
                                      height: 2,
                                      color: kprimaryColor,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownValue = value!;
                                        
                                        
                                        selected_id = items_id[
                                            items.indexOf(dropdownValue)];
                                        sub_id = [];
                                        sub_items = [];
                                        getSubCategory(selected_id);
                                      });
                                    },
                                    items: items.map<DropdownMenuItem<String>>(
                                        (String value) {
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
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Text("Please Select The Category"))
                              : Visibility(
                                  visible: subCategoryVisibility,
                                  child: FutureBuilder(builder:
                                      (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                    return DropdownButton<String>(
                                      value: sub_dropdownvalue,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style:
                                          const TextStyle(color: kprimaryColor),
                                      underline: Container(
                                        height: 2,
                                        color: kprimaryColor,
                                      ),
                                      onChanged: (String? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          sub_dropdownvalue = value!;
                                          
                                          selected_sub_id = sub_items_id[
                                              sub_items
                                                  .indexOf(sub_dropdownvalue)];
                                        });
                                      },
                                      items: sub_items
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    );
                                  }, future: null,),
                                ),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          child: Text(
                            "Price range",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 30,
                                  width: 371,
                                  child: CupertinoSlider(
                                    thumbColor: Colors.white,
                                    activeColor: Colors.black,
                                    min: 0,
                                    max: 1000,
                                    value: _Pvalue,
                                    onChanged: (value) {
                                      setState(() {
                                        _Pvalue = value;
                                        price =
                                            int.parse(value.toStringAsFixed(0));
                                      });
                                    },
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price == 0 ? "0" : "${price.toString()} \$",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            Text(
                              "\$1000",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Center(
                          child: Container(
                            width: 76,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFF4285F4),
                                // color: Color(0xff321A08),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Center(
                              child: Text(
                                price == 0 ? "0 \$" : "${price.toString()} \$",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        // Container(
                        //   child: Text(
                        //     "Brands",
                        //     style: TextStyle(
                        //         color: Colors.black,
                        //         fontSize: 21,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        SizedBox(
                          height: res_height * 0.08,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                filteredData = true;
                              });
                               String Url = dotenv.env['baseUrlM'] ?? 'No url found';
                              if(DateTime.parse(selectedDate.toString()).compareTo(DateTime.parse(selectedDate1.toString())) > 0){
                                var snackBar = new SnackBar(
                                        content: new Text(
                                            "Please Select Valid End Date"));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    setState(() {
                                filteredData = false;
                              });
                              }
                                if (Latitiude == null) {
                                  if (radius != 0) {
                                    var snackBar = new SnackBar(
                                        content: new Text(
                                            "Please Select Location With Radius"));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    setState(() {
                                      filteredData = false;
                                    });
                                  } 
                                  else {
                                    if (price == 0 && fromDate == null) {
                                      url =
                                          "${Url}/getProductSearching/null/null/null/null/null/${selected_sub_id}/null";
                                     
                                      getData(url);
                                    } else if (price != 0 && fromDate == null) {
                                      url =
                                          "${Url}/getProductSearching/null/null/null/null/null/${selected_sub_id}/${price}";
                                     
                                      getData(url);
                                    } else if (price == 0 && fromDate != null) {
                                      url =
                                          "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/null/null/null/${selected_sub_id}/null";
                                     
                                      getData(url);
                                    } else if (price != 0 && fromDate != null) {
                                      url =
                                          "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/null/null/null/${selected_sub_id}/${price}";
                                     
                                      getData(url);
                                    }
                                  }
                                } // empty <location and radius> with price check

                                else {
                                  if (radius != 0) {
                                    if (price == 0 && fromDate == null) {
                                      url =
                                          "${Url}/getProductSearching/null/null/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/null";
                                     
                                      getData(url);
                                    } else if (price != 0 && fromDate == null) {
                                      url =
                                          "${Url}/getProductSearching/null/null/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/${price}";
                                     
                                      getData(url);
                                    } else if (price == 0 && fromDate != null) {
                                      url =
                                          "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/null";
                                     
                                      getData(url);
                                    } else if (price != 0 && fromDate != null) {
                                      url =
                                          "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/${price}";
                                     
                                      getData(url);
                                    }
                                  } else {
                                    var snackBar = new SnackBar(
                                        content: new Text(
                                            "Please Select Radius With Location"));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    setState(() {
                                      filteredData = false;
                                    });
                                  }
                                }
                            },
                            child: Container(
                              height: 58,
                              width: 380,
                              child: Center(
                                child: Text(
                                  filteredData ? "Loading" : 'Find',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: kprimaryColor,
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                child: Text("Searched"),
              )
              );
  }

  Fields() {
    return Container(
      child: TextFormField(
        autocorrect: false,
        // controller: userEmailController,
        // validator: (text) {
        //   if (text == null ||
        //       text.isEmpty ||
        //       !text.contains("@")) {
        //     return 'Enter correct email';
        //   }
        //   return null;
        // },
        style: TextStyle(color: Colors.grey),
        decoration: InputDecoration(
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
            filled: true,
            hintStyle: TextStyle(color: Colors.grey),
            hintText: "United State Of America",
            fillColor: Colors.white),
      ),
    );
  }

  Brands(
    img,
  ) {
    return Container(
      width: 71,
      height: 71,
      decoration: BoxDecoration(
          border: Border.all(color: kprimaryColor),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Image.asset(
        img,
        scale: 2.3,
      ),
    );
  }

  TxtfldforLocation(txt, _controller) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Center(
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
                style: TextStyle(fontWeight: FontWeight.bold),
                onChanged: (value) {
                  setState(() {
                    _onChanged();
                    value == "" ? {Latitiude = null, Longitude = null} : null;
                    
                  });
                },
                maxLines: 1,
                controller: _locationController,
                decoration: InputDecoration(
                   suffixIcon: Icon(Icons.location_pin, color: kprimaryColor),
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
                  // hintStyle: TextStyle(fontWeight: FontWeight.bold),
                  // hintText: "New York, NY,USA",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
