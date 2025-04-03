import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactSupport extends StatefulWidget {
  const ContactSupport({Key? key}) : super(key: key);

  @override
  State<ContactSupport> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
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
          'Contact Support',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Support',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: res_height * 0.04),
              Text(
                'At JEBBY, we are committed to providing you with the best rental experience possible. If you have any questions, concerns, or need assistance with our service, please don\'t hesitate to reach out to our dedicated support team. We\'re here to help you!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Text(
                'How to Contact Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: res_height * 0.02),

              Text(
                '1. In-App Support:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Text(
                '• Open the JEBBY app.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Go to the top left bar to open the slider section.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Click on "Provide Feedback.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Follow the prompts to describe your issue or inquiry.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Our support team will respond to you as soon as possible via the app\'s messaging system or in your email.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
               SizedBox(height: res_height * 0.02),

              Text(
                '2. Email Support:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Text(
                '• You can also reach us via email at [support@jebbylistings.com].',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Please include your name, contact information, and a detailed description of your issue or question.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
               Text(
                '• Our support team will respond to your email within [response time] during our business hours.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.04),
              Text(
                'Sincerely, The JEBBY Support Team',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
