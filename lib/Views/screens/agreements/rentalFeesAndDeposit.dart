import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/agreements/insuranceAndIndemnifications.dart';

class RentalFeesAndDeposit extends StatefulWidget {
  const RentalFeesAndDeposit({Key? key}) : super(key: key);

  @override
  State<RentalFeesAndDeposit> createState() => _RentalFeesAndDepositState();
}

class _RentalFeesAndDepositState extends State<RentalFeesAndDeposit> {
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
          'Rental Fees & Deposit',
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
              Container(
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam in vehicula tortor, sollicitudin faucibus urna.Fusce ac felis nisl. Duis laoreet felis neque. Duis arcu orci, commodo quis mi a, elementum commodo sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tristique at nulla sed auctor. Sed pharetra eros a lacus consequat malesuada. Etiam iaculis mi ornare mollis porta. Vivamus eget massa leo. Nulla ac mi vestibulum, molestie felis et, posuere quam. Nam eget nulla suscipit metus pulvinar ornare sed ut ante.In hac habitasse platea dictumst. Donec ultricies urna nunc, vel tristique enim suscipit non. Quisque vulputate quam vitae felis gravida, id ultrices turpis euismod. Donec ut interdum nisl, sed iaculis lacus. Duis porttitor neque ut lacus pulvinar elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a ipsum dolor. Donec semper faucibus rhoncus. Ut neque felis, tincidunt vel aliquet eu, gravida ac nisi. Ut accumsan, ante ut pretium ultrices, erat odio scelerisque sem, a dapibus leo tortor et arcu.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam in vehicula tortor, sollicitudin faucibus urna.Fusce ac felis nisl. Duis laoreet felis neque. Duis arcu orci, commodo quis mi a, elementum commodo sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tristique at nulla sed auctor. Sed pharetra eros a lacus consequat malesuada. Etiam iaculis mi ornare mollis porta. Vivamus eget massa leo. Nulla ac mi vestibulum, molestie felis et, posuere quam. Nam eget nulla suscipit metus pulvinar ornare sed ut ante.In hac habitasse platea dictumst. Donec ultricies urna nunc, vel tristique enim suscipit non. Quisque vulputate quam vitae felis gravida, id ultrices turpis euismod. Donec ut interdum nisl, sed iaculis lacus. Duis porttitor neque ut lacus pulvinar elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a ipsum dolor. Donec semper faucibus rhoncus. Ut neque felis, tincidunt vel aliquet eu, gravida ac nisi. Ut accumsan, ante ut pretium ultrices, erat odio scelerisque sem, a dapibus leo tortor et arcu.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam in vehicula tortor, sollicitudin faucibus urna.Fusce ac felis nisl. Duis laoreet felis neque. Duis arcu orci, commodo quis mi a, elementum commodo sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tristique at nulla sed auctor. Sed pharetra eros a lacus consequat malesuada. Etiam iaculis mi ornare mollis porta. Vivamus eget massa leo. Nulla ac mi vestibulum, molestie felis et, posuere quam. Nam eget nulla suscipit metus pulvinar ornare sed ut ante.In hac habitasse platea dictumst. Donec ultricies urna nunc, vel tristique enim suscipit non. Quisque vulputate quam vitae felis gravida, id ultrices turpis euismod. Donec ut interdum nisl, sed iaculis lacus. Duis porttitor neque ut lacus pulvinar elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a ipsum dolor. Donec semper faucibus rhoncus. Ut neque felis, tincidunt vel aliquet eu, gravida ac nisi. Ut accumsan, ante ut pretium ultrices, erat odio scelerisque sem, a dapibus leo tortor et arcu.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam in vehicula tortor, sollicitudin faucibus urna.Fusce ac felis nisl. Duis laoreet felis neque. Duis arcu orci, commodo quis mi a, elementum commodo sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tristique at nulla sed auctor. Sed pharetra eros a lacus consequat malesuada. Etiam iaculis mi ornare mollis porta. Vivamus eget massa leo. Nulla ac mi vestibulum, molestie felis et, posuere quam. Nam eget nulla suscipit metus pulvinar ornare sed ut ante.In hac habitasse platea dictumst. Donec ultricies urna nunc, vel tristique enim suscipit non. Quisque vulputate quam vitae felis gravida, id ultrices turpis euismod. Donec ut interdum nisl, sed iaculis lacus. Duis porttitor neque ut lacus pulvinar elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a ipsum dolor. Donec semper faucibus rhoncus. Ut neque felis, tincidunt vel aliquet eu, gravida ac nisi. Ut accumsan, ante ut pretium ultrices, erat odio scelerisque sem, a dapibus leo tortor et arcu.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam in vehicula tortor, sollicitudin faucibus urna.Fusce ac felis nisl. Duis laoreet felis neque. Duis arcu orci, commodo quis mi a, elementum commodo sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tristique at nulla sed auctor. Sed pharetra eros a lacus consequat malesuada. Etiam iaculis mi ornare mollis porta. Vivamus eget massa leo. Nulla ac mi vestibulum, molestie felis et, posuere quam. Nam eget nulla suscipit metus pulvinar ornare sed ut ante.In hac habitasse platea dictumst. Donec ultricies urna nunc, vel tristique enim suscipit non. Quisque vulputate quam vitae felis gravida, id ultrices turpis euismod. Donec ut interdum nisl, sed iaculis lacus. Duis porttitor neque ut lacus pulvinar elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a ipsum dolor. Donec semper faucibus rhoncus. Ut neque felis, tincidunt vel aliquet eu, gravida ac nisi. Ut accumsan, ante ut pretium ultrices, erat odio scelerisque sem, a dapibus leo tortor et arcu..',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff524034),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(height: res_height * 0.04),
              GestureDetector(
                onTap: (() {
                  Get.to(() => InsuranceAndIndemnification());
                }),
                child: Container(
                  height: res_height * 0.06,
                  width: res_width * 0.8,
                  child: Center(
                    child: Text(
                      'Agree',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
