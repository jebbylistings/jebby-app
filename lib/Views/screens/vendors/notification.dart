import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/screens/vendors/OrderReq.dart';
import 'package:jebby/Views/screens/vendors/negotiationRequest.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/deleteNotificationModel.dart';
import '../../../model/getNotificationModel.dart';
import '../../../model/user_model.dart' hide Data;
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../home/Messages(32).dart';

class VendorNotifications extends StatefulWidget {
  const VendorNotifications({super.key});

  @override
  State<VendorNotifications> createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    await usp.getUpdatedUser();
    await sp.getDataFromSharedPreferences();
    profileImage = (usp.image ?? sp.imageUrl ?? '').toString();
    if (mounted) {
      setState(() {});
    }
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;
  String? profileImage;
  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          if (mounted) {
            setState(() {});
          }

          // seenNotification();

          getNotifications();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  Future<GetNotificationModel> notifications(
    id,
    onResponse(GetNotificationModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllNotificationForApp + sourceId.toString()),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        // ApiRepository.shared.checkApiStatus(true, "getNotifications");
        var data = GetNotificationModel.fromJson(jsonDecode(response.body));

        ApiRepository.shared.getNotifications(data);

        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    return GetNotificationModel();
  }

  Future<DeleteNotificationModel> deleteNotification(id, ind) async {
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(
      Uri.parse(AppUrl.deleteNotification),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        notifications(id, (List) {
          if (this.mounted) {
            setState(() {});
          }
        }, (error) {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return DeleteNotificationModel();
  }

  seenNotification(id) {
    ApiRepository.shared.seenoneNotification(id);
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isEmpty = true;
              isLoading = false;
              isError = false;
            });
          } else {
            setState(() {
              isEmpty = false;
              isLoading = false;
              isError = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isEmpty = false;
            isLoading = true;
            isError = true;
          });
        }
      },
    );
  }

  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsData =
        ApiRepository.shared.getNotificationModelList?.data ?? [];
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: (){
            Get.back();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildUserAvatar(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationsData.isEmpty
              ? Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: _buildGroupedNotificationSections(notificationsData),
                ),
    );
  }

  List<Widget> _buildGroupedNotificationSections(List<Data> data) {
    final Map<String, List<Data>> grouped = {};
    for (final item in data) {
      final createdAtRaw = item.createdAt?.toString();
      final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
      final key = _sectionLabel(createdAt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final List<Widget> sections = [];
    grouped.forEach((sectionTitle, items) {
      sections.add(
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 32 / 2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(items.length, (index) {
                final item = items[index];
                return _notificationTile(
                  item,
                  showDivider: index != items.length - 1,
                );
              }),
            ],
          ),
        ),
      );
    });
    return sections;
  }

  String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d == today) return "Today";
    if (d == yesterday) return "Yesterday";
    return DateFormat('MMM dd yyyy, EEEE').format(date);
  }

  Widget _notificationTile(Data data, {required bool showDivider}) {
    final name = (data.name ?? '').toString();
    final desc = (data.description ?? '').toString();
    final id = (data.id ?? '').toString();
    final seen = data.seen_one.toString();
    final date = data.createdAt?.toString() ?? '';
    final formattedDate = DateFormat('hh:mm a')
        .format(DateTime.tryParse(date) ?? DateTime.now());
    final prodId = data.productId.toString();
    final status = data.status;
    final price = data.price.toString();
    final negoId = data.negoId;

    return InkWell(
      onTap: () {
        seenNotification(id);
        if (name == "message") {
          Get.to(() => MessagesScreen());
        } else if (name == "order") {
          Get.to(() => OrderRequestScreen());
        } else if (name == "negotiation") {
          Get.to(
            () => NegotiationRequest(
              price: price,
              status: status,
              productId: prodId,
              negoId: negoId,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: seen == "0"
                        ? const Color(0xFFF59D0A)
                        : const Color(0xFFF2D04F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name.capitalizeFirst ?? '',
                              style: TextStyle(
                                fontSize: 31 / 2,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B1B1F),
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Color(0xFF7C7C84),
                              fontSize: 26 / 2,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          color: Color(0xFF6D6D75),
                          fontSize: 16,
                          height: 1.3,
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showDivider) ...[
              const SizedBox(height: 10),
              const Divider(
                thickness: 1,
                height: 1,
                color: Color(0xFFE2E2E8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final image = (profileImage ?? '').trim();
    final bool hasImage = image.isNotEmpty && image.toLowerCase() != 'null';
    final String imageUrl =
        image.startsWith('http') ? image : '${AppUrl.baseUrlM}$image';

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : const Icon(
              Icons.person,
              color: Colors.black54,
              size: 20,
            ),
    );
  }
}
