import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../../../view_model/apiServices.dart';

class InsuranceAndIndemnification extends StatefulWidget {
  const InsuranceAndIndemnification({Key? key}) : super(key: key);

  @override
  State<InsuranceAndIndemnification> createState() =>
      _InsuranceAndIndemnificationState();
}

class _InsuranceAndIndemnificationState
    extends State<InsuranceAndIndemnification> {

  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  getInsurance(){
    ApiRepository.shared.insurance(
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
    getInsurance();
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
              'Insurance & Indemnifications \n Policy',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
            ),
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
          Html(data: ApiRepository.shared.getInsuranceModelList!.data![0].description.toString(),)),
              // Container(
              //   child: Text(
              //     isLoading ? "Loading" : ApiRepository.shared.getInsuranceModelList!.data![0].description.toString(),
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
              //     Get.to(() => TransportAndInstallationPolicy());
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
