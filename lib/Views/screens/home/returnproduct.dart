import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/res/app_url.dart';
import 'package:jared/view_model/getTax_modal.dart';

import 'package:http/http.dart' as http;

class ReturnProductScreen extends StatefulWidget {
  const ReturnProductScreen({super.key});

  @override
  State<ReturnProductScreen> createState() => _ReturnProductScreenState();
}

class _ReturnProductScreenState extends State<ReturnProductScreen> {

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  
   dynamic filterarray = [];
  dynamic array = [];
  late Map<String, dynamic> _data;

  Future<void> _loadData() async {
    try {
      final data = await GetreturnProduct.fetchData();
      setState(() {
        _data = data;
        filterarray = _data['data'];
        isLoading = false;
      });
      array = filterarray.where((data) => data['complete_date'] != '0').toList();
      print("filterarray ===>  ${filterarray}");
      print("array ===>  ${array}");
    } catch (e) {
      print('error $e');
    }
  }

  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Return Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: 
      // isError
      //     ? Center(child: Text("Some Error Occured While Loading Data"))
      //     : 
          isLoading
              ? Center(child: Text("Loading"))
              : array.length == 0
                  ? Center(child: Text("No Return Product Found"))
                  : Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 20),
                              Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: array.length,
                                    itemBuilder: (context, int index) {
                                      var name = array[index]['product_name'];
                                      var date = array[index]['complete_date'].isEmpty ? "" : DateFormat('yyyy-MM-dd').format(DateTime.parse(array?[index]?['complete_date']));
                                      var id = array[index]['id'];
                                      var image = array[index]['product_image'];
                                      var Return = array[index]['retrurn'];
                                      return Gesture1(name, date, id, image, Return);
                                    }),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Gesture1(name, date, id, image, Return) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: 391,
          height: 195,
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
                        child: Image.network(AppUrl.baseUrlM + image)),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                              width: 159,
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 14),
                              )),
                          Text(
                            date.toString(),
                            style: TextStyle(fontSize: 14),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: 8),
                    Return == 0
                        ? Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ReturnProduct(id);
                              },
                              child: Container(
                                height: 44,
                                child: Center(
                                  child: Text(
                                    'Return',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                  ),
                                ),
                                decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          )
                        : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                null;
                              },
                              child: Container(
                                height: 44,
                                child: Center(
                                  child: Text(
                                    'Return',
                                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 19),
                                  ),
                                ),
                                decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          )
                    // : Center(child: Text("Negotiated Product"))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void ReturnProduct(id) async {
     String Url = dotenv.env['baseUrlM'] ?? 'No url found';
    setState(() {
      isLoading = true;
    });
    print(id);
    final String SeenMessageUrl = "${Url}/orderReturn";
    var data = {
      "id": id,
    };
    print(data);
    try {
      final response = await http.post(
        Uri.parse(SeenMessageUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      final responseBody = jsonDecode(response.body);
      print("response ${responseBody["message"]}");

      if (responseBody["message"].toString() == 'product has been returned') {
        final snackBar = new SnackBar(content: new Text("product has been returned"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _loadData();
          isLoading = false;
        });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ReturnProductScreen()),
        // );
      } else {
        final snackBar = new SnackBar(content: new Text(responseBody["message"].toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
          isLoading = false;
        });
      print(err);
      final snackBar = new SnackBar(content: new Text('Something went wrong plz check your internet connection'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
