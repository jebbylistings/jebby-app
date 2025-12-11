import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FAQs extends StatefulWidget {
  const FAQs({Key? key}) : super(key: key);

  @override
  State<FAQs> createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  String? role;
  Future getData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    role = sp.getString('role');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'FAQs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child:
                role == '1'
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: res_height * 0.04),
                        Container(
                          child: Text(
                            'Jebby Providers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),

                        Container(
                          child: Text(
                            "Get the answers you're looking for below. Can't find what you need? Send us an email and we will happily help!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff524034),
                            ),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Container(
                          child: Text(
                            'What is Jebby?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby is the #1 rental service marketplace offering thousands of items from A to Z. Jebby is a downloadable computer software platform for connecting people who want to rent out their possessions with people who want to rent said possessions instead of buying them. Our platform is a tool for you to make passive income by renting your Items.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Jebby fits into a rapidly emerging group of businesses known as "platforms” or “marketplace businesses'
                          '. Companies like Airbnb, Ebay, Turo and Uber fit into these categories. They create value by facilitating exchanges between two or more interdependent groups, usually ‘consumers’ and ‘producers’. At Jebby, Providers are given an Account where they can manage and control their items for rent.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What are Jebby Providers?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby Providers are independent business owners who rent, deliver, set up and clean items that they own. Jebby Providers are gig-economy moms, dads, retirees or best friend teams who are building a rental business on the Jebby platform.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Is there a fee to start?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "No. We decided that high fees for starting wouldn’t be a part of our business.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How do I create my Jebby Store?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Simply just download the App, Create an Account and agree to the policies. Then start building your business by listing items to rent",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Where do I deliver?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You decide. Most Jebby Providers deliver about 5-10 miles around where they live, and this is completely up to you. This is your business decision and will vary based on the size of the city in which you live and how much you want to be in the car. You also set the delivery rates.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How long does it take to get paid?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You are paid 24 hours after the rental period begins. It takes approximately 2 business days for the payment to show in your bank account.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How much money do I make?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby is one of the highest side gig income opportunities! On average, our Providers are earning over \$1,000 a month.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How will my performance be evaluated?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby is the leading rental platform and we pride ourselves on providing outstanding customer service. We expect exceptional service and professionalism from all Providers and that all Providers follow our core values of personalized customer service, reliability, responsiveness, friendliness and positive communication. Performance is provided by renters with a rating system.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What do I get from Jebby when I become a Provider?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You get to be part of the largest A-Z gear rental platform.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Is this my own business?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "As a Jebby Provider, you are an independent business Owner. This means you get to design your own business and are not an employee of Jebby. This is your business - exciting right? With the Jebby platform, we are dedicated to providing friendly and personalized customer service. You will agree to abide by the Jebby guidelines and to follow our Terms of Service.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How many items can I list?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "As a Jebby Provider, you can list as many items as you want to rent.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Can I set a minimum rental period?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Absolutely! When setting up your item rental, designate whether or not the rental item has a minimum period requirement.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What happens if my item is lost/damaged/stolen?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Item renters are responsible for returning items on time, in the condition they were received. If an item is either not returned on time, damaged or lost/stolen, the renter is responsible for the replacement of the item for the fair market value. See Provider Guarantee for more details.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.04),
                        Text(
                          'Does Jebby charge any fees?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby charges the provider a Service Charge as payment for use of the service. Services Charges will be automatically deducted from the payment received by the renter and the remaining balance will be deposited into your bank account. Jebby will charge a Service Charge to the provider for rental fees, delivery fees and damage waiver charges.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Do I need to pay taxes?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Jebby does not automatically collect any sales taxes required as they vary from area to area. Jebby is not responsible for determining how much to collect, collecting or paying sales tax, you are.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.04),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: res_height * 0.04),
                        Container(
                          child: Text(
                            'For Renters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),

                        Container(
                          child: Text(
                            "Get the answers you're looking for below. Can't find what you need? Send us an email and we will be happy to help! ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff524034),
                            ),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Container(
                          child: Text(
                            'How far ahead should I make my reservation?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "The sooner, the better! Items are available on a first come, first served basis. Peak times typically are around Holidays, Winter and Summer. ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Can I pay when the reservation starts?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "No. We require full payment at the time of booking. We block off your items for you and are not making the items you’ve reserved available to other potential renters for the same time period you have reserved—kind of like a vacation rental reservation ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What forms of payment do you accept?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "We accept Visa, MasterCard, American Express, JCB, Discover. We use Stripe as our payment processor.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How do you calculate the number of days in a rental?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "We count each day that you have an item as one day.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "For example, if you are planning to rent an item starting early evening on Monday and keep it until the following Monday morning, we would count that as 8 days.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Is there a minimum rental period?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Providers have the option of setting minimum rental periods for each listing. Be sure to check the item description to see if there is a minimum rental period.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Where are items picked up/delivered?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Once you complete your order your Jebby Provider will be in contact to arrange specific delivery details. Each provider sets the terms on how their item will be delivered or if it can be picked up, along with any associated fees.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How much does delivery cost?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Each Independent Jebby Provider sets their own delivery rates and the locations to which they deliver. There may be extra fees for same day delivery, delivery outside of normal business hours, or on holidays. Please check with the Provider or the item description you would like to rent to get the most accurate delivery costs.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What is included in the delivery fee?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "The delivery fee includes delivery, setup of most items, and pickup at the completion of a reservation.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'How do I view or modify my Jebby reservation?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You may log into your Jebby account to view or modify your reservation for any reason (add items, remove items, extend dates, change dates or delivery address, etc). Changes must be made at least 48 prior to the rental start date. Some requested changes may need to be approved by the Provider. In such a case, an email will be sent notifying you of the accepted or rejected changes. If you would like to make a change within 48 hours of the start of your rental, please call, email or text the provider. The credit card you used to originally place your reservation will be charged for the changes. If you prefer to use a different card, you may enter that info when making or requesting the changes.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Reservation date extensions requested less than 24 hours prior to the originally scheduled pick up time may be subject to additional fees ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What happens if I damage the gear, return it very dirty or lose the gear?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You are responsible for the gear once it is delivered to you, and it must be returned in the condition it was received. If items are returned damaged or not as they were received, you will be charged additional fees. In the event that an item cannot be fully cleaned or repaired, you will be charged the fair market value to replace the item.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What is the Jebby service charge?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "To help cover the costs of running Jebby, including processing fees and customer support, we charge customers a service charge of 10% every time a reservation is made through the Jebby platform. The amount of this service charged is based on the reservation subtotal of rental and delivery charges (before other fees and taxes). The exact amount of the service fee is displayed before a customer pays for their rental and is also displayed in the cart, delivery information, billing information and payment pages.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'What is your cancellation policy?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "You may cancel all or any portion of your reservation up to 48 hours before the rental reservation start time. If you cancel more than 48 hours before the reservation you will receive a full refund. If you cancel less than 48 hours before the reservation you will forfeit the full payment.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff524034),
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          'Can I cancel a reservation myself?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: res_height * 0.02),
                        Text(
                          "Yes. You may log into your Jebby account to cancel your reservation. Once you have successfully logged in, click the “Cancel Order” button.",
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
      ),
    );
  }
}
