import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/screens/home/Messages.dart';
import 'package:jebby/res/app_url.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';
import '../../../model/getChatHistoryModel.dart' as datamodel;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          get_chat_history();
          seenNotification();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  void seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  void get_chat_history() {
    ApiRepository.shared.chatsHistory(
      sourceId.toString(),
      (payload) {
        if (!mounted) return;
        if (payload.data == null || payload.data!.isEmpty) {
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
      },
      (error) {
        if (error != null && mounted) {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = true;
          });
        }
      },
    );
  }

  Timer? _pollTimer;

  void _startPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => get_chat_history(),
    );
  }

  final TextEditingController _searchController = TextEditingController();
  String searchText = "";

  List<datamodel.Data> _visibleChats() {
    final raw = ApiRepository.shared.getChatsHistoryModelList?.data;
    if (raw == null) return [];
    final rev = raw.reversed.toList();
    if (searchText.isEmpty) return rev;
    final q = searchText.toLowerCase();
    return rev
        .where((e) => (e.name ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _startPoll();
    getData();
    profileData(context);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Chat',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: _SearchPill(
                controller: _searchController,
                onChanged: (v) {
                  setState(() => searchText = v.toLowerCase());
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isError) {
      return Center(
        child: Text(
          'Something went wrong while loading chats.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black54),
        ),
      );
    }
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    final items = _visibleChats();
    if (isEmpty || items.isEmpty) {
      return Center(
        child: Text(
          'No messages',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(15, 1, 15, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final element = items[index];
        final name = element.name;
        final image = element.image.toString();
        final targetId = element.id.toString();
        final count = element.count ?? 0;
        final lastMessage = (element.lastMessage ?? '').toString();
        final displayName =
            (name == null || name.toString().trim().isEmpty)
                ? 'Vendor'
                : name.toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ChatListTile(
            name: displayName,
            imageUrl: image.isEmpty ? null : AppUrl.baseUrlM + image,
            lastMessage: lastMessage,
            unreadCount: count,
            onTap: () {
              _pollTimer?.cancel();
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => Chat(targetId))).then((
                _,
              ) {
                if (!mounted) return;
                // Periodic timer’s first tick is delayed; refresh immediately
                // so last-message preview matches what was sent in the thread.
                get_chat_history();
                _startPoll();
              });
            },
          ),
        );
      },
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.unreadCount,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final String lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  String get _preview {
    if (lastMessage.length <= 80) return lastMessage;
    return '${lastMessage.substring(0, 77)}…';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(imageUrl: imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6B70),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.imageUrl});

  final String? imageUrl;

  static const Color _fill = Color(0xFFFFF4E8);

  @override
  Widget build(BuildContext context) {
    const size = 54.0;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: _fill,
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primaryColor.withValues(alpha: 0.85),
          size: 30,
        ),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => ColoredBox(
                color: _fill,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryColor.withValues(alpha: 0.85),
                  size: 30,
                ),
              ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: _fill,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
