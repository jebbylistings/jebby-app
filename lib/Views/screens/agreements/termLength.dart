import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../../view_model/apiServices.dart';

class TermLength extends StatefulWidget {
  const TermLength({Key? key}) : super(key: key);

  @override
  State<TermLength> createState() => _TermLengthState();
}

class _TermLengthState extends State<TermLength> {

  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getTerm(){
    ApiRepository.shared.termLength(
      (List)=>{
         if (this.mounted)
                {
                  if (List.status == 0)
                    {
                      setState((){
                        isLoading = false;
                        emptyData = true;
                        isError = false;
                      })
                    }
                  else
                    {
                     setState((){
                        isLoading = false;
                        emptyData = false;
                        isError = false;
                      })
                    }
                }
      }, 
      (error)=>{
          if (error != null)
                {
                  setState(() {
                   isLoading = false;
                   isError = true;
                   emptyData = false;
                  }),
                },
      });
  }

  void initState(){
    getTerm();
    super.initState();
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
          'Copyright Policy',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
            color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoading ?
              Container(child: Text('Loading'),) :
              Container(
                child: 
          Html(data: ApiRepository.shared.getTermLengthModelList!.data![0].description.toString(),)),
              // Container(
              //   child: Text(
              //     isLoading ? "Loading" :
              //     ApiRepository.shared.getTermLengthModelList!.data![0].description.toString(),
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Color(0xff524034),
              //     ),
              //     textAlign: TextAlign.justify,
              //   ),
              // ),
              SizedBox(height: res_height * 0.04),
              // GestureDetector(
              //   onTap: (() {
              //     Get.to(() => RentalFeesAndDeposit());
              //   }),
              //   child: Container(
              //     height: res_height * 0.06,
              //     width: res_width * 0.8,
              //     child: Center(
              //       child: Text(
              //         'Agree',
              //         style:
              //             TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              //       ),
              //     ),
              //     decoration: BoxDecoration(
              //         color: kprimaryColor,
              //         borderRadius: BorderRadius.circular(14)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
