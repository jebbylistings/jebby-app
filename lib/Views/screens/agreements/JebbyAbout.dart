import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
          'About App',
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
                'About JEBBY',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: res_height * 0.04),
              Text(
                'The Jebby Service is a downloadable computer software platform for connecting people who want to rent out their possessions with people who want to rent those possessions instead of buying them. Jebby’s online platform enables Users to rent out their items ("Providers") to other Users who desire to rent the Provider’s items ( "Renters") in exchange for payment of fees to the applicable Provider and Jebby. Each such transaction between Providers and Renters shall, for the purposes of these Terms, be referred to as a "Lending Transaction" and each item that is the subject of a Lending Transaction shall, for the purposes of these Terms, be referred to as an "Item".',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff524034),
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Text(
                'Your Jebby account gives you access to the services and functionality that we may establish and maintain from time to time and at our sole discretion. When creating your account, you must provide accurate and complete information, and you must keep this information up to date. You are solely responsible for the activity that occurs on your account, and you must keep your account password secure. We encourage you to use "strong" passwords (passwords that use a combination of upper and lower-case letters, numbers and symbols) with your account. We may maintain different types of accounts for different types of Users. If you open a Jebby account on behalf of a company, organization, or other entity, then: (i) "you" includes you and that entity; and (ii) you represent and warrant that you are an authorized representative of the entity with the authority to bind the entity to these Terms, and that you agree to these Terms on the entity\'s behalf. By connecting to the Jebby Service with a third-party service, you give us permission to access and use your information from that service as permitted by that service, and to store your log-in credentials for that service. You may never use another User\'s account. You must notify Jebby immediately of any breach of security or unauthorized use of your account. Jebby will not be liable for any losses caused by any unauthorized use of your account. You may control your user profile and how you interact with the Jebby Service by changing the settings in your profile page. By providing Jebby your email address you consent to Jebby using the email address to send you Jebby Service-related notices, including without limitation any notices required by law, in lieu of communication by postal mail. We may also use your email address to send you other messages, such as changes to features of the Jebby Service and special offers. If you do not want to receive such email messages, you may opt out or change your preferences in your profile page. Opting out may prevent you from receiving email messages regarding updates, improvements, or offers.',
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
