import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:provider/provider.dart';


import '../../../utils/utils.dart';
import '../../../view_model/auth_view_model.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
      final authViewMode = Provider.of<AuthViewModel>(context);

    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/slicing/bg2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        //backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Colors.transparent,

          elevation: 0,
          
           leading: GestureDetector(
            onTap: (){
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: res_height * 0.175,
              ),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email'),
                  SizedBox(
                    height: res_height * 0.01,
                  ),
                  Container(
                    width: res_width * 0.9,
                    child: TextFormField(
                      controller: _emailController,
                      autocorrect: false,
                      // controller: userEmailController,
                      validator: (text) {
                        if (text == null ||
                            text.isEmpty ||
                            !text.contains("@")) {
                          return 'Enter correct email';
                        }
                        return null;
                      },
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "Example@gmail.com",
                          fillColor: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: res_height * 0.015,
              ),
              GestureDetector(
                onTap: () {
                  if (_emailController.text.isEmpty ) {
                      Utils.flushBarErrorMessage('Please enter email', context);
                    }else{
                      Map data = {
                        'email' : _emailController.text.toString(),                    
                      };
                      authViewMode.forgetPasswordApi(data, context, "forgot");
                    }
                },
                child: Container(
                  height: res_height * 0.065,
                  width: res_width * 0.9,
                  child: Center(
                    child: Text(
                      'Continue',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              SizedBox(
                height: res_height * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
