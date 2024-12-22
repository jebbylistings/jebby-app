import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Address",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 90,
              ),
              Txtfld("Country/Religion", "United State Of America"),
              Txtfld("Personal Info", "Contact Name"),
              SizedBox(
                height: 10,
              ),
              fieldss("Phone Number"),
              // SizedBox(
              //   height: 10,
              // ),
              Txtfld("Address", "Street House/appartment"),
              SizedBox(
                height: 10,
              ),
              fieldss("City"),
              SizedBox(
                height: 10,
              ),
              fieldss("Zipcode"),
              SizedBox(
                height: 30,
              ),

              Container(
                child: Text(
                  "Set as default shipping address",
                  style: TextStyle(color: Colors.grey, fontSize: 17),
                ),
              ),
              SizedBox(
                height: 80,
              ),
              Container(
                height: 58,
                width: 391,
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                ),
                decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.circular(14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Txtfld(
    txt,
    tf,
  ) {
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          SizedBox(
            height: res_height * 0.005,
          ),
          Container(
            height: 50,
            width: res_width * 0.9,
            child: TextField(
              decoration: InputDecoration(
                hintText: tf,
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

  fieldss(
    tf,
  ) {
    return Container(
      height: 50,
      width: 369,
      child: TextField(
        decoration: InputDecoration(
          hintText: tf,
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
    );
  }
}
