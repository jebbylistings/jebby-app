import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../models/get_all_messages_model.dart' as msg_model;
import '../../../models/product_chat_context.dart';
import '../../../models/user_model.dart';
import '../../../constants/app_url.dart';
import '../../../constants/color.dart';
import '../../../utils/api_datetime.dart';
import '../../../utils/order_status.dart';
import '../../../utils/public_location.dart';
import '../../../utils/rental_date.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../../view_models/user_view_model.dart';
import 'package:jebby/views/screens/home/product_details.dart' deferred as product_detail;
import 'package:jebby/views/screens/reservations/rental_request_review.dart';
import 'package:jebby/views/screens/reservations/reservation_detail.dart';

const _chatThreadDivider = Color(0xFFE3E6EC);
const _chatIncomingBubble = Colors.white;
const _chatComposerFieldBg = Color(0xFFF1F5F9);
const _threadListingCardBg = Color(0xFFE7EFFB);
const _badgePendingBg = AppColors.primaryColorLight;
const _badgePendingFg = AppColors.jebbyAccentOrange;

class _ThreadOrderSnapshot {
  const _ThreadOrderSnapshot({
    required this.orderId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.orderStatus,
  });

  final int orderId;
  final String rentalStartDate;
  final String rentalEndDate;
  final String orderStatus;
}

class Chat extends StatefulWidget {
  const Chat(this.targetID, {super.key, this.productContext});

  final dynamic targetID;
  final ProductChatContext? productContext;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _sendMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _pollTimer;

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? phoneNumber;
  String? role;

  String _peerDisplayName = '';
  String _targetImage = '';
  String _peerAddress = '';

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  /// Detects new/changed thread so we only auto-scroll when messages update.
  String? _lastMessagesFingerprint;

  bool _productContextSent = false;

  ProductChatContext? _displayProductContext;
  String? _enrichingProductId;
  _ThreadOrderSnapshot? _threadOrder;
  String? _fetchingThreadOrderKey;

  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData(BuildContext context) {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          phoneNumber = value.phoneNumber.toString();
          email = value.email.toString();
          role = value.role.toString();
          if (mounted) {
            setState(() {});
            _maybeFetchThreadOrder(_displayProductContext);
          }
          getUserData();
          getMessageApi();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  void getMessageApi() {
    if (sourceId.isEmpty || widget.targetID.toString().isEmpty) return;
    ApiRepository.shared.getMessagesApi(
      sourceId.toString(),
      widget.targetID.toString(),
      (res) {
        if (!mounted) return;
        final newFp = _fingerprintMessages(res.data);
        final changed = _lastMessagesFingerprint != newFp;

        if (res.data == null || res.data!.isEmpty) {
          setState(() {
            isLoading = false;
            isEmpty = true;
            isError = false;
          });
          _updateDisplayProductContext(const []);
          if (changed) {
            _lastMessagesFingerprint = newFp;
            _scheduleScrollToBottom();
          }
          _maybeSendProductContext(const []);
        } else {
          setState(() {
            isLoading = false;
            isError = false;
            isEmpty = false;
          });
          _updateDisplayProductContext(res.data!);
          if (changed) {
            _lastMessagesFingerprint = newFp;
            _scheduleScrollToBottom();
          }
          _maybeSendProductContext(res.data!);
        }
      },
      (error) {
        if (!mounted) return;
        if (error != null) {
          setState(() {
            isLoading = false;
            isError = true;
            isEmpty = false;
          });
        }
      },
    );
  }

  void sendMessage(String msg, {String? productId}) {
    if (msg.trim().isEmpty) return;
    final effectiveProductId = productId ?? widget.productContext?.productId;
    ApiRepository.shared.postMessage(
      msg.trim(),
      sourceId.toString(),
      widget.targetID.toString(),
      productId: effectiveProductId,
    );
  }

  void _maybeSendProductContext(List<msg_model.Data> existing) {
    final ctx = widget.productContext;
    if (ctx == null || _productContextSent || sourceId.isEmpty) return;
    if (ProductChatContext.threadHasProduct(
      contents: existing.map((m) => m.content),
      productIds: existing.map((m) => m.productId),
      productId: ctx.productId,
    )) {
      _productContextSent = true;
      return;
    }
    _productContextSent = true;
    sendMessage(ctx.toPayload(), productId: ctx.productId);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) getMessageApi();
    });
  }

  void getUserData() {
    ApiRepository.shared.userCredential(
      (List) {
        if (!mounted) return;
        if (List.data == null || List.data!.isEmpty) {
          setState(() {});
        } else {
          setState(() {});
        }
      },
      (error) {
        if (error != null && mounted) setState(() {});
      },
      sourceId.toString(),
    );
  }

  void getTargetData() {
    ApiRepository.shared.userCredential(
      (List) {
        if (!mounted) return;
        if (List.data == null || List.data!.isEmpty) {
          setState(() {
            _peerDisplayName = 'Chat';
            _targetImage = '';
            _peerAddress = '';
          });
        } else {
          final row = List.data![0];
          setState(() {
            _peerDisplayName =
                (row.name ?? '').toString().trim().isEmpty
                    ? 'Chat'
                    : (row.name ?? '').toString().trim();
            _targetImage = (row.profileImage ?? '').toString();
            _peerAddress = (row.address ?? '').toString().trim();
          });
        }
      },
      (error) {
        if (error != null && mounted) {
          setState(() => _peerDisplayName = 'Chat');
        }
      },
      widget.targetID.toString(),
    );
  }

  void _startPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && sourceId.isNotEmpty) getMessageApi();
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
    getTargetData();
    _startPoll();
    if (widget.productContext != null) {
      _displayProductContext = widget.productContext;
      _updateDisplayProductContext(const []);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _sendMessageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _nunito({
    double size = 15,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.jebbyTextPrimary,
    double height = 1.35,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  String _firstName(String? full) {
    if (full == null || full.trim().isEmpty) return 'You';
    return full.trim().split(RegExp(r'\s+')).first;
  }

  String _peerFirstName() => _firstName(_peerDisplayName);

  String _avatarUrl(String rel) {
    final t = rel.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('http')) return t;
    return '${AppUrl.baseUrlM}$t';
  }

  List<msg_model.Data> _messagesChronological() {
    final raw = ApiRepository.shared.getAllMessagesModelList?.data;
    return _sortMessagesChronological(raw);
  }

  List<msg_model.Data> _sortMessagesChronological(List<msg_model.Data>? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = List<msg_model.Data>.from(raw);
    list.sort((a, b) {
      final ta = parseApiDateTime(a.createdAt) ?? DateTime(1970);
      final tb = parseApiDateTime(b.createdAt) ?? DateTime(1970);
      return ta.compareTo(tb);
    });
    return list;
  }

  String _fingerprintMessages(List<msg_model.Data>? data) {
    final sorted = _sortMessagesChronological(data);
    if (sorted.isEmpty) return 'empty';
    final last = sorted.last;
    return '${sorted.length}_${last.id}_${last.createdAt}_${last.content}';
  }

  ProductChatContext? _mergedProductContextFromMessages(
    List<msg_model.Data> msgs,
  ) {
    ProductChatContext? merged = widget.productContext;
    for (final m in msgs) {
      final ctx = ProductChatContext.tryParsePayload(m.content);
      if (ctx == null) continue;
      merged =
          merged == null
              ? ctx
              : ProductChatContext.mergePreferFilled(merged, ctx);
    }
    return merged;
  }

  void _updateDisplayProductContext(List<msg_model.Data> msgs) {
    final base = _mergedProductContextFromMessages(msgs);
    if (base == null) {
      if (_displayProductContext != null) {
        setState(() => _displayProductContext = null);
      }
      return;
    }

    final needsDescription = base.description.trim().isEmpty;
    final needsLocation = base.locationLine.trim().isEmpty;
    if (needsDescription || needsLocation) {
      _fetchProductEnrichment(base);
      return;
    }

    if (_displayProductContext != base) {
      setState(() => _displayProductContext = base);
    }
    _maybeFetchThreadOrder(base);
  }

  _ThreadOrderSnapshot? _orderFromProductContext(ProductChatContext ctx) {
    final id = int.tryParse(ctx.orderId.trim());
    if (id == null) return null;
    return _ThreadOrderSnapshot(
      orderId: id,
      rentalStartDate: ctx.rentalStartDate.trim(),
      rentalEndDate: ctx.rentalEndDate.trim(),
      orderStatus: OrderStatus.normalize(ctx.orderStatus),
    );
  }

  void _maybeFetchThreadOrder(ProductChatContext? ctx) {
    if (ctx == null || sourceId.isEmpty) return;
    final fromCtx = _orderFromProductContext(ctx);
    if (fromCtx != null) {
      if (_threadOrder?.orderId != fromCtx.orderId) {
        setState(() => _threadOrder = fromCtx);
      }
      return;
    }

    final productId = int.tryParse(ctx.productId.trim());
    final peerId = widget.targetID.toString().trim();
    if (productId == null || peerId.isEmpty) return;

    final key = '${ctx.productId}_$peerId';
    if (_fetchingThreadOrderKey == key) return;
    _fetchingThreadOrderKey = key;

    final amVendor = ctx.vendorUserId.trim() == sourceId.trim();
    if (amVendor) {
      ApiRepository.shared.getVenodorOrders(
        sourceId,
        (res) {
          _fetchingThreadOrderKey = null;
          if (!mounted) return;
          final snap = _pickThreadOrder(
            orders: res.data ?? [],
            productId: productId,
            peerUserId: peerId,
            amVendor: true,
          );
          if (snap != null) setState(() => _threadOrder = snap);
        },
        (_) {
          _fetchingThreadOrderKey = null;
        },
        updateCache: false,
      );
    } else {
      ApiRepository.shared.getAllOrdersByUserId(
        sourceId,
        (res) {
          _fetchingThreadOrderKey = null;
          if (!mounted) return;
          final snap = _pickThreadOrder(
            orders: res.data ?? [],
            productId: productId,
            peerUserId: peerId,
            amVendor: false,
          );
          if (snap != null) setState(() => _threadOrder = snap);
        },
        (_) {
          _fetchingThreadOrderKey = null;
        },
      );
    }
  }

  _ThreadOrderSnapshot? _pickThreadOrder({
    required List<dynamic> orders,
    required int productId,
    required String peerUserId,
    required bool amVendor,
  }) {
    final matches = <dynamic>[];
    for (final o in orders) {
      if (o.productId != productId) continue;
      if (amVendor) {
        if (o.userId?.toString() != peerUserId) continue;
      } else {
        if (o.vendorId?.toString() != peerUserId) continue;
      }
      matches.add(o);
    }
    if (matches.isEmpty) return null;

    int score(dynamic o) {
      final status = OrderStatus.normalize(o.orderStatus?.toString());
      if (OrderStatus.isNewBooking(status)) return 0;
      if (OrderStatus.isPending(status)) return 1;
      if (OrderStatus.isCompleted(status)) return 3;
      return 2;
    }

    matches.sort((a, b) {
      final sa = score(a);
      final sb = score(b);
      if (sa != sb) return sa.compareTo(sb);
      final ca = parseApiDateTime(a.createdAt?.toString()) ?? DateTime(1970);
      final cb = parseApiDateTime(b.createdAt?.toString()) ?? DateTime(1970);
      return cb.compareTo(ca);
    });

    final best = matches.first;
    final id = best.id;
    if (id == null) return null;
    final orderId = id is int ? id : int.tryParse(id.toString());
    if (orderId == null || orderId <= 0) return null;
    return _ThreadOrderSnapshot(
      orderId: orderId,
      rentalStartDate: (best.rentalStartDate ?? '').toString(),
      rentalEndDate: (best.rentalEndDate ?? '').toString(),
      orderStatus: OrderStatus.normalize(best.orderStatus?.toString()),
    );
  }

  void _fetchProductEnrichment(ProductChatContext base) {
    final id = base.productId.trim();
    if (id.isEmpty || _enrichingProductId == id) return;
    _enrichingProductId = id;

    ApiRepository.shared.getProductsById(
      (list) {
        _enrichingProductId = null;
        if (!mounted) return;

        var enriched = base;
        if (list.data != null && list.data!.isNotEmpty) {
          final p = list.data!.first;
          final summary = ProductChatContext.summaryFromDescription(
            p.description?.toString(),
          );
          final city =
              PublicLocation.cityStateLine(p.address?.toString()) ?? '';
          var locationLine = base.locationLine.trim();
          if (locationLine.isEmpty && city.isNotEmpty) {
            locationLine =
                p.hasPickup
                    ? '$city · Available for pickup today'
                    : city;
          }

          String firstImage = base.image.trim();
          if (firstImage.isEmpty &&
              p.images != null &&
              p.images!.isNotEmpty) {
            firstImage = (p.images!.first.path ?? '').toString();
          }

          enriched = ProductChatContext(
            productId: base.productId,
            name:
                base.name.trim().isNotEmpty
                    ? base.name
                    : (p.name ?? '').toString(),
            price:
                base.price.trim().isNotEmpty
                    ? base.price
                    : (p.price ?? '').toString(),
            image: firstImage,
            vendorUserId: base.vendorUserId,
            recipientId: base.recipientId,
            description:
                base.description.trim().isNotEmpty ? base.description : summary,
            locationLine: locationLine,
            orderId: base.orderId,
            rentalStartDate: base.rentalStartDate,
            rentalEndDate: base.rentalEndDate,
            orderStatus: base.orderStatus,
          );
        }

        setState(() => _displayProductContext = enriched);
        _maybeFetchThreadOrder(enriched);
      },
      (_) {
        _enrichingProductId = null;
        if (mounted) setState(() => _displayProductContext = base);
      },
      id,
    );
  }

  List<msg_model.Data> _textMessages(List<msg_model.Data> msgs) {
    return msgs
        .where((m) => ProductChatContext.tryParsePayload(m.content) == null)
        .toList();
  }

  String _peerSubtitle(ProductChatContext? productCtx) {
    if (productCtx != null && sourceId.isNotEmpty) {
      final amVendor =
          productCtx.vendorUserId.trim() == sourceId.trim();
      return amVendor ? 'Renter' : 'Earner';
    }
    return '';
  }

  bool _isMessageReadByRecipient(msg_model.Data m) {
    if (m.senderId.toString() != sourceId.toString()) return false;
    return m.isShow == 1;
  }

  String _formatDateSeparator(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final dayLabel =
        day == today
            ? 'Today'
            : day == today.subtract(const Duration(days: 1))
            ? 'Yesterday'
            : DateFormat('EEE').format(dt);
    return '$dayLabel · ${DateFormat('MMM d').format(dt)}';
  }

  List<_ChatThreadItem> _buildThreadItems(List<msg_model.Data> msgs) {
    final textMsgs = _textMessages(msgs);
    if (textMsgs.isEmpty) return const [];

    final items = <_ChatThreadItem>[];
    DateTime? lastDay;

    for (var i = 0; i < textMsgs.length; i++) {
      final m = textMsgs[i];
      final dt = parseApiDateTime(m.createdAt);
      if (dt != null) {
        final day = DateTime(dt.year, dt.month, dt.day);
        if (lastDay == null || day != lastDay) {
          items.add(_ChatThreadItem.date(_formatDateSeparator(dt)));
          lastDay = day;
        }
      }
      final isMe = m.senderId.toString() == sourceId.toString();
      items.add(
        _ChatThreadItem.message(
          m,
          isMe: isMe,
          showRead: _isMessageReadByRecipient(m),
        ),
      );
    }
    return items;
  }

  void _scrollToBottom() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(max);
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _messagesChronological();
    final productCtx =
        _displayProductContext ?? _mergedProductContextFromMessages(msgs);
    final threadItems = _buildThreadItems(msgs);
    final peerName =
        _peerDisplayName.isEmpty ? 'Chat' : _peerDisplayName;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChatThreadHeader(
            displayName: peerName,
            subtitle: _peerSubtitle(productCtx),
            imageUrl: _avatarUrl(_targetImage),
            showAvatar: !isLoading,
            onBack: () => Get.back(),
          ),
          if (productCtx != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _ThreadListingCard(
                product: productCtx,
                order: _threadOrder ?? _orderFromProductContext(productCtx),
                isVendorTab: productCtx.vendorUserId.trim() == sourceId.trim(),
              ),
            ),
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Text(
                        'Loading…',
                        style: _nunito(
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                    )
                    : isError
                    ? Center(
                      child: Text(
                        'Could not load messages',
                        style: _nunito(
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                    )
                    : threadItems.isEmpty && productCtx == null
                    ? _EmptyThreadBody()
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: threadItems.length,
                      itemBuilder: (context, index) {
                        final item = threadItems[index];
                        if (item.isDate) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16, top: 8),
                            child: _DateSeparator(label: item.dateLabel!),
                          );
                        }
                        final m = item.message!;
                        final content = (m.content ?? '').toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _MessageRow(
                            content: content,
                            createdAt: m.createdAt,
                            isMe: item.isMe!,
                            showRead: item.showRead,
                          ),
                        );
                      },
                    ),
          ),
          _Composer(
            controller: _sendMessageController,
            peerFirstName: _peerFirstName(),
            onSend: () {
              final text = _sendMessageController.text;
              if (text.trim().isEmpty) return;
              sendMessage(text);
              _sendMessageController.clear();
              getMessageApi();
              _scheduleScrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}

class _ChatThreadItem {
  const _ChatThreadItem._({
    this.dateLabel,
    this.message,
    this.isMe,
    this.showRead = false,
  });

  final String? dateLabel;
  final msg_model.Data? message;
  final bool? isMe;
  final bool showRead;

  bool get isDate => dateLabel != null;

  factory _ChatThreadItem.date(String label) =>
      _ChatThreadItem._(dateLabel: label);

  factory _ChatThreadItem.message(
    msg_model.Data msg, {
    required bool isMe,
    required bool showRead,
  }) => _ChatThreadItem._(
    message: msg,
    isMe: isMe,
    showRead: showRead,
  );
}

class _ChatThreadHeader extends StatelessWidget {
  const _ChatThreadHeader({
    required this.displayName,
    required this.subtitle,
    required this.imageUrl,
    required this.showAvatar,
    required this.onBack,
  });

  final String displayName;
  final String subtitle;
  final String imageUrl;
  final bool showAvatar;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      color: AppColors.jebbyBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                JebbyFlowBackButton(onTap: onBack),
                const SizedBox(width: 12),
                if (showAvatar) ...[
                  _HeaderAvatar(imageUrl: imageUrl),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jebbyTextPrimary,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _chatThreadDivider),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.jebbyTextMuted,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
      ],
    );
  }
}

class _EmptyThreadBody extends StatelessWidget {
  const _EmptyThreadBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Start your chat',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.jebbyTextMuted,
        ),
      ),
    );
  }
}

String _formatChatRentalRange(String? start, String? end) {
  final s = rentalDateToDateTime(start);
  final e = rentalDateToDateTime(end);
  if (s == null && e == null) return '';
  if (s != null && e == null) {
    return DateFormat('MMM d, yyyy').format(s);
  }
  if (s == null && e != null) {
    return DateFormat('MMM d, yyyy').format(e);
  }
  if (s!.year == e!.year && s.month == e.month) {
    return '${DateFormat('MMM d').format(s)} -${DateFormat('d, yyyy').format(e)}';
  }
  if (s.year == e.year) {
    return '${DateFormat('MMM d').format(s)} - ${DateFormat('MMM d, yyyy').format(e)}';
  }
  return '${DateFormat('MMM d, yyyy').format(s)} - ${DateFormat('MMM d, yyyy').format(e)}';
}

class _ThreadListingCard extends StatelessWidget {
  const _ThreadListingCard({
    required this.product,
    required this.isVendorTab,
    this.order,
  });

  final ProductChatContext product;
  final bool isVendorTab;
  final _ThreadOrderSnapshot? order;

  String _resolveImageUrl() {
    final rel = product.image.trim();
    if (rel.isEmpty) return '';
    if (rel.startsWith('http')) return rel;
    return '${AppUrl.baseUrlM}$rel';
  }

  Future<void> _openProduct() async {
    await product_detail.loadLibrary();
    final price = int.tryParse(product.price.trim()) ?? 0;
    final image = product.image.trim();
    Get.to(
      () => product_detail.ProductDetailScreen(
        product.productId,
        product.name,
        price,
        '0',
        image,
        product.vendorUserId,
        '',
        0,
        sourceId: 'chat',
      ),
    );
  }

  void _openPrimaryAction() {
    final snap = order;
    if (snap != null && snap.orderId > 0) {
      final status = OrderStatus.normalize(snap.orderStatus);
      if (isVendorTab && OrderStatus.isNewBooking(status)) {
        Get.to(() => RentalRequestReviewScreen(orderId: snap.orderId));
        return;
      }
      Get.to(() => ReservationDetailScreen(orderId: snap.orderId));
      return;
    }
    _openProduct();
  }

  String? _actionLabel() {
    final snap = order;
    if (snap != null && snap.orderId > 0) {
      final status = OrderStatus.normalize(snap.orderStatus);
      if (isVendorTab && OrderStatus.isNewBooking(status)) {
        return 'View request';
      }
      return 'View reservation';
    }
    return 'View listing';
  }

  String? _badgeLabel() {
    final snap = order;
    if (snap == null || snap.orderId <= 0) return null;
    final status = OrderStatus.normalize(snap.orderStatus);
    if (OrderStatus.isNewBooking(status)) return 'Request Pending';
    return OrderStatus.displayLabel(status);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl();
    final dateLine = _formatChatRentalRange(
      order?.rentalStartDate ?? product.rentalStartDate,
      order?.rentalEndDate ?? product.rentalEndDate,
    );
    final badge = _badgeLabel();
    final actionLabel = _actionLabel();

    return Material(
      color: _threadListingCardBg,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child:
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                        : ColoredBox(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey.shade400,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.trim().isNotEmpty ? product.name : 'Listing',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.jebbyTextPrimary,
                      height: 1.25,
                    ),
                  ),
                  if (dateLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (badge != null) ...[
                    const SizedBox(height: 8),
                    _ThreadStatusBadge(label: badge),
                  ],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: _openPrimaryAction,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.jebbyBlue,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.jebbyBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThreadStatusBadge extends StatelessWidget {
  const _ThreadStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _badgePendingBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 14, color: _badgePendingFg),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _badgePendingFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.jebbySoftBlue,
            backgroundImage:
                hasUrl ? CachedNetworkImageProvider(imageUrl) : null,
            onBackgroundImageError: hasUrl ? (_, __) {} : null,
            child:
                hasUrl
                    ? null
                    : const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.jebbyBlue,
                      size: 26,
                    ),
          ),
        ],
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.content,
    required this.createdAt,
    required this.isMe,
    this.showRead = false,
  });

  final String content;
  final String? createdAt;
  final bool isMe;
  final bool showRead;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width * 0.82;
    final timeStr = formatApiTime(createdAt);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 6),
      bottomRight: Radius.circular(isMe ? 6 : 20),
    );

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.jebbyBlue : _chatIncomingBubble,
        borderRadius: radius,
        boxShadow: [
          if (!isMe)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: isMe ? Colors.white : AppColors.jebbyTextPrimary,
        ),
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          bubble,
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                  ),
                ),
                if (isMe && showRead) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppColors.jebbyBlue,
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'Read',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.peerFirstName,
    required this.onSend,
  });

  static const double _barHeight = 48;

  final TextEditingController controller;
  final String peerFirstName;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: _chatThreadDivider),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: _barHeight,
                      decoration: BoxDecoration(
                        color: _chatComposerFieldBg,
                        borderRadius: BorderRadius.circular(_barHeight / 2),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: controller,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.center,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jebbyTextPrimary,
                          height: 1.2,
                        ),
                        cursorColor: AppColors.jebbyBlue,
                        decoration: InputDecoration(
                          hintText: 'Message $peerFirstName…',
                          hintStyle: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.grey.shade500,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: _barHeight,
                    child: Material(
                      color: AppColors.jebbyBlue,
                      borderRadius: BorderRadius.circular(_barHeight / 2),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onSend,
                        borderRadius: BorderRadius.circular(_barHeight / 2),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              'Send',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageModel {
  String? Message;
  String? type;

  MessageModel({this.Message, this.type});
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
