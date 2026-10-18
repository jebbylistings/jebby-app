import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jebby/views/screens/home/messages.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:provider/provider.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../models/user_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../models/get_all_messages_model.dart' as msg_model;
import '../../../models/get_chat_history_model.dart' as datamodel;
import '../../../models/product_chat_context.dart';
import '../../../utils/api_datetime.dart';

class _CachedThreadInquiry {
  const _CachedThreadInquiry({
    required this.content,
    required this.recipientId,
  });

  final String content;
  final String recipientId;
}

const _chatCardBorder = Color(0xFFE3E6EC);
const _chatTimeBlue = Color(0xFF5B8DEF);
const _noMessageAsset = 'assets/images/nomessage.png';
const _chatListHorizontalMargin = 12.0;
const _chatScreenHorizontalPadding = 20.0;

String _formatChatListTime(String? raw) {
  final dt = parseApiDateTime(raw);
  if (dt == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(dt.year, dt.month, dt.day);
  final diffDays = today.difference(messageDay).inDays;
  if (diffDays == 0) {
    return DateFormat.jm().format(dt);
  }
  if (diffDays == 1) return 'Yesterday';
  if (diffDays < 7) return '$diffDays days ago';
  return DateFormat('MMM d').format(dt);
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    this.showBackButton = false,
    this.messageSenderName,
  });

  /// When true (e.g. opened from provider drawer), shows a leading back affordance.
  final bool showBackButton;

  /// Sender name from a message notification (`You have a new message from …`).
  final String? messageSenderName;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  /// 0 = Renter threads, 1 = Earner threads (listing-side conversations).
  int _segmentTab = 0;

  /// 0 = All, 1 = Unread, 2 = Favorites, 3 = Archive.
  int _filterChip = 0;
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
          if (!_openedFromMessageNotification) {
            _applyDefaultTab();
          }
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

  final Map<String, _CachedThreadInquiry> _threadInquiryCache = {};
  bool _resolvingInquiries = false;

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
          if (_openedFromMessageNotification) {
            _applyDefaultTab();
          }
        } else {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = false;
          });
          _resolveThreadInquiries().then((_) {
            if (mounted) _applyTabForNotificationContext();
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

  TextStyle _nunito({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.jebbyTextPrimary,
      height: height,
    );
  }

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  Widget _pageHeader({required bool showBack}) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chat',
          style: _nunito(
            size: 22,
            weight: FontWeight.w800,
            color: AppColors.jebbyTextPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Stay connected with renters and Earners.',
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
      ],
    );

    if (!showBack) {
      return titleColumn;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: titleColumn,
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleBack,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  String? _inquiryContentFor(datamodel.Data e) {
    final peerId = e.id.toString();
    final cached = _threadInquiryCache[peerId];
    if (cached != null) return cached.content;

    final inquiry = (e.lastInquiryMessage ?? '').trim();
    if (inquiry.isNotEmpty) return inquiry;
    return e.lastMessage;
  }

  bool _isProviderTabConversation(datamodel.Data e) {
    if (sourceId.isEmpty) return false;
    final inquiryContent = _inquiryContentFor(e);
    return ProductChatContext.isProviderTabThread(
      inquiryContent: inquiryContent,
      currentUserId: sourceId,
    );
  }

  Future<void> _resolveThreadInquiries() async {
    if (sourceId.isEmpty || _resolvingInquiries) return;
    final raw = ApiRepository.shared.getChatsHistoryModelList?.data;
    if (raw == null || raw.isEmpty) return;

    _resolvingInquiries = true;
    for (final e in raw) {
      final peerId = e.id.toString();
      if (_threadInquiryCache.containsKey(peerId)) continue;
      if ((e.lastInquiryMessage ?? '').trim().isNotEmpty) continue;
      if (ProductChatContext.tryParsePayload(e.lastMessage) != null) continue;
      await _fetchThreadInquiry(peerId);
    }
    _resolvingInquiries = false;
    if (mounted) setState(() {});
  }

  Future<void> _fetchThreadInquiry(String peerId) async {
    final completer = Completer<void>();
    ApiRepository.shared.getMessagesApi(
      sourceId,
      peerId,
      (res) {
        final meta = _extractLatestInquiry(res.data);
        if (meta != null) {
          _threadInquiryCache[peerId] = meta;
        }
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  _CachedThreadInquiry? _extractLatestInquiry(List<msg_model.Data>? messages) {
    if (messages == null || messages.isEmpty) return null;

    final sorted = List<msg_model.Data>.from(messages);
    sorted.sort((a, b) {
      final ta = parseApiDateTime(a.createdAt) ?? DateTime(1970);
      final tb = parseApiDateTime(b.createdAt) ?? DateTime(1970);
      return ta.compareTo(tb);
    });

    for (var i = sorted.length - 1; i >= 0; i--) {
      final m = sorted[i];
      final content = (m.content ?? '').toString();
      final ctx = ProductChatContext.tryParsePayload(content);
      if (ctx != null) {
        final recipientId = m.recipientId?.toString() ?? ctx.recipientId;
        return _CachedThreadInquiry(
          content: content,
          recipientId: recipientId,
        );
      }

      final productId = m.productId;
      final messageRecipientId = m.recipientId;
      if (productId != null && productId > 0 && messageRecipientId != null) {
        final rid = messageRecipientId.toString();
        // Product inquiries are sent to the vendor; listing owner is recipient (or self when vendor).
        final vendorId = rid == sourceId ? sourceId : rid;
        return _CachedThreadInquiry(
          content: ProductChatContext.syntheticPayload(
            productId: productId,
            vendorUserId: vendorId,
            recipientId: rid,
          ),
          recipientId: rid,
        );
      }
    }
    return null;
  }

  bool _isRenterTabConversation(datamodel.Data e) => !_isProviderTabConversation(e);

  List<datamodel.Data> _chatsForProviderTab(List<datamodel.Data> items) {
    return items.where(_isProviderTabConversation).toList();
  }

  List<datamodel.Data> _chatsForRenterTab(List<datamodel.Data> items) {
    return items.where(_isRenterTabConversation).toList();
  }

  bool get _openedFromMessageNotification =>
      (widget.messageSenderName ?? '').trim().isNotEmpty;

  void _applyDefaultTab() {
    if (!mounted || role == null) return;
    final index = role == '1' ? 1 : 0;
    if (_segmentTab != index) {
      setState(() => _segmentTab = index);
    }
  }

  List<datamodel.Data> _applyMessageFilter(List<datamodel.Data> items) {
    switch (_filterChip) {
      case 1:
        return items.where((e) => (e.count ?? 0) > 0).toList();
      case 2:
      case 3:
        return <datamodel.Data>[];
      default:
        return items;
    }
  }

  String _emptyLabelForFilter({required bool earnerSegment}) {
    switch (_filterChip) {
      case 1:
        return 'No unread messages';
      case 2:
        return 'No favorite chats yet';
      case 3:
        return 'No archived chats';
      default:
        return earnerSegment ? 'No Earner chats' : 'No Renter chats';
    }
  }

  datamodel.Data? _findNotificationThread(List<datamodel.Data> items) {
    final senderName = (widget.messageSenderName ?? '').trim().toLowerCase();
    if (senderName.isEmpty) return null;

    final matches = items
        .where(
          (entry) =>
              (entry.name ?? '').toString().trim().toLowerCase() == senderName,
        )
        .toList();
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;

    matches.sort((a, b) {
      final unreadDiff = (b.count ?? 0).compareTo(a.count ?? 0);
      if (unreadDiff != 0) return unreadDiff;
      final tb = parseApiDateTime(b.lastMessageTime) ?? DateTime(1970);
      final ta = parseApiDateTime(a.lastMessageTime) ?? DateTime(1970);
      return tb.compareTo(ta);
    });
    return matches.first;
  }

  void _applyTabForNotificationContext() {
    if (!mounted || sourceId.isEmpty) return;
    if (!_openedFromMessageNotification) return;

    final raw = ApiRepository.shared.getChatsHistoryModelList?.data;
    if (raw == null || raw.isEmpty) {
      _applyDefaultTab();
      return;
    }

    final thread = _findNotificationThread(raw);
    if (thread == null) {
      _applyDefaultTab();
      return;
    }

    final index = _isProviderTabConversation(thread) ? 1 : 0;
    if (_segmentTab != index) {
      setState(() => _segmentTab = index);
    }
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

  Widget _roleSegmentedControl() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _chatCardBorder),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _RoleSegmentOption(
              label: 'Renter',
              selected: _segmentTab == 0,
              onTap: () => setState(() => _segmentTab = 0),
            ),
          ),
          Expanded(
            child: _RoleSegmentOption(
              label: 'Earner',
              selected: _segmentTab == 1,
              onTap: () => setState(() => _segmentTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noChatsEmptyState({required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _chatListHorizontalMargin),
      child: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: const Alignment(0, -0.35),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _chatScreenHorizontalPadding - _chatListHorizontalMargin,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _noMessageAsset,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 96,
                        color: AppColors.jebbyBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _messageFilterChips() {
    const labels = ['All', 'Unread', 'Favorites', 'Archive'];
    return Row(
      children: List.generate(labels.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: index == 3 ? 0 : 4),
            child: _ChatFilterChip(
              label: labels[index],
              selected: _filterChip == index,
              onTap: () => setState(() => _filterChip = index),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _pageHeader(showBack: widget.showBackButton),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchPill(
                controller: _searchController,
                onChanged: (v) {
                  setState(() => searchText = v.toLowerCase());
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _roleSegmentedControl(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _messageFilterChips(),
            ),
            const SizedBox(height: 16),
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
        child: CircularProgressIndicator(
          color: AppColors.jebbyBlue,
          strokeWidth: 2.4,
        ),
      );
    }
    final items = _visibleChats();
    if (isEmpty || items.isEmpty) {
      return _noChatsEmptyState(message: 'No messages');
    }

    final segmentItems = _segmentTab == 0
        ? _chatsForRenterTab(items)
        : _chatsForProviderTab(items);
    final filtered = _applyMessageFilter(segmentItems);
    return _buildChatList(
      filtered,
      emptyLabel: _emptyLabelForFilter(earnerSegment: _segmentTab == 1),
    );
  }

  Widget _buildChatList(List<datamodel.Data> items, {required String emptyLabel}) {
    if (items.isEmpty) {
      return _noChatsEmptyState(message: emptyLabel);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _chatListHorizontalMargin,
        6,
        _chatListHorizontalMargin,
        24,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: _chatCardBorder,
      ),
      itemBuilder: (context, index) {
        final element = items[index];
        final name = element.name;
        final image = element.image.toString();
        final targetId = element.id.toString();
        final count = element.count ?? 0;
        final lastMessage = (element.lastMessage ?? '').toString();
        final displayName =
            (name == null || name.toString().trim().isEmpty)
                ? 'User'
                : name.toString();

        return _ChatListTile(
          name: displayName,
          imageUrl: image.isEmpty ? null : AppUrl.baseUrlM + image,
          lastMessage: lastMessage,
          timeLabel: _formatChatListTime(element.lastMessageTime),
          unreadCount: count,
          onTap: () {
            _pollTimer?.cancel();
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => Chat(targetId)))
                .then((_) {
                  if (!mounted) return;
                  get_chat_history();
                  _startPoll();
                });
          },
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _chatCardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.jebbyBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.jebbyTextPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted.withValues(alpha: 0.75),
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

class _RoleSegmentOption extends StatelessWidget {
  const _RoleSegmentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.jebbyBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.jebbyTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatFilterChip extends StatelessWidget {
  const _ChatFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.jebbyBlue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: selected ? BorderSide.none : const BorderSide(color: _chatCardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.jebbyTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final VoidCallback onTap;

  String get _preview {
    final text = ProductChatContext.formatLastMessagePreview(lastMessage);
    if (text.length <= 80) return text;
    return '${text.substring(0, 77)}…';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _chatScreenHorizontalPadding - _chatListHorizontalMargin,
            16,
            _chatScreenHorizontalPadding - _chatListHorizontalMargin,
            16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.jebbyTextPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (timeLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _chatTimeBlue,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.jebbyBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
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

  static const Color _fill = AppColors.jebbySoftBlue;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: _fill,
        child: Icon(
          Icons.person_rounded,
          color: AppColors.jebbyBlue,
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
                  color: AppColors.jebbyBlue,
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
                    color: AppColors.jebbyBlue.withValues(alpha: 0.5),
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
