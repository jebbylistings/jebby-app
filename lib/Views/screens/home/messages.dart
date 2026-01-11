import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/deleteNotificationModel.dart';
import '../../../model/getNotificationModel.dart';
import '../../../model/user_model.dart' as usermodel;
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../home/Messages(32).dart';
import '../profile/myprofile.dart';
import '../vendors/negotiationScreeen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String sourceId = "";
  bool isLoading = true;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();

    await sp.getDataFromSharedPreferences();
    usermodel.UserModel user = await usp.getUser();

    sourceId = user.id.toString();
    _getNotifications();
  }

  void _getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
          (data) {
        setState(() {
          isLoading = false;
          isEmpty = data.data!.isEmpty;
        });
      },
          (error) {
        setState(() {
          isLoading = false;
          isEmpty = true;
        });
      },
    );
  }

  void _seenNotification(id) {
    ApiRepository.shared.seenoneNotification(id);
  }

  Future<void> _deleteNotification(id) async {
    await http.post(
      Uri.parse(AppUrl.deleteNotification),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({"id": id}),
    );
    _getNotifications();
  }

  /// ---------------- DATE GROUPING ----------------

  String _groupTitle(DateTime date) {
    final now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) return "Today";
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return "Yesterday";
    }
    return DateFormat("MMM dd, yyyy").format(date);
  }

  Map<String, List<Data>> _groupNotifications(List<Data> list) {
    Map<String, List<Data>> grouped = {};

    for (var item in list) {
      if (item.name == "order") continue;

      DateTime date = DateTime.parse(item.createdAt!);
      String key = _groupTitle(date);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => MyProfileScreen()),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.person_outline, color: Colors.black),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
          ? const Center(child: Text("No Notifications"))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final notifications =
    ApiRepository.shared.getNotificationModelList!.data!;
    final grouped = _groupNotifications(notifications);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ...entry.value.map((item){return _notificationCard(item,entry.key);}).toList(),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _notificationCard(Data item,String title) {
    DateTime date = DateTime.parse(item.createdAt!);

    return GestureDetector(
      onTap: () {
        _seenNotification(item.id);

        if (item.name == "message") {
          Get.to(() => MessagesScreen());
        }
        else if (item.name == "negotiation")
        {
          Get.to(
                () => NegotiationScreen(
              prodId: item.productId,
              status: item.status,
              price: item.price,
              negoId: item.negoId.toString(),
              userId: item.userId.toString(),
            ),
          );
        }

      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Dot
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: item.seen_one == "0"
                        ? Colors.orange
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 12),

                /// Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Time + delete
                Column(
                  children: [
                    Text(
                      DateFormat("hh:mm a").format(date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // GestureDetector(
                    //   onTap: () => _deleteNotification(item.id),
                    //   child: const Icon(Icons.close, size: 18, color: Colors.grey),
                    // ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
