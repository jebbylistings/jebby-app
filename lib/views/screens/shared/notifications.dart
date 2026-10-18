import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/get_notification_model.dart';
import 'package:jebby/models/user_model.dart' as usermodel;
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/services/provider/sign_in_provider.dart';
import 'package:jebby/utils/api_datetime.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/view_models/user_view_model.dart';
import 'package:jebby/views/screens/reservations/reservation_detail.dart';
import 'package:jebby/views/screens/shared/chat.dart';
import 'package:jebby/views/screens/shared/settings.dart';
import 'package:jebby/views/screens/vendors/my_orders.dart';
import 'package:provider/provider.dart';

enum _NotificationFilter { all, unread }

/// Notifications for both renter and vendor flows.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.isVendor = false});

  final bool isVendor;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _attentionCardBg = Color(0xFFFFF9F0);
  static const Color _attentionIconBg = Color(0xFFFFF2D9);
  static const Color _attentionIconColor = Color(0xFFD9A54C);
  static const Color _attentionSubtitle = Color(0xFF8B7355);

  String sourceId = '';
  bool isLoading = true;
  bool isEmpty = false;
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();

    await usp.getUpdatedUser();
    await sp.getDataFromSharedPreferences();

    final usermodel.UserModel user = await usp.getUser();
    sourceId = user.id.toString();
    if (mounted) setState(() {});

    _getNotifications();
  }

  void _getNotifications() {
    setState(() => isLoading = true);
    ApiRepository.shared.notifications(
      sourceId,
      (data) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isEmpty = data.data == null || data.data!.isEmpty;
        });
      },
      (error) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isEmpty = true;
        });
      },
    );
  }

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
    } else if (widget.isVendor) {
      EarnerNavigation.goHome();
    }
  }

  bool _canPop() => Get.key.currentState?.canPop() ?? false;

  List<Data> _allVisibleItems() {
    final raw = ApiRepository.shared.getNotificationModelList?.data ?? [];
    if (widget.isVendor) return raw;
    return raw.where((e) {
      final name = (e.name ?? '').toString().toLowerCase();
      return name != 'order';
    }).toList();
  }

  bool _isUnread(Data data) => data.seen == 0;

  int get _unreadCount => _allVisibleItems().where(_isUnread).length;

  List<Data> _filteredItems() {
    final items = _allVisibleItems();
    if (_filter == _NotificationFilter.unread) {
      return items.where(_isUnread).toList();
    }
    return items;
  }

  bool _needsAttention(Data data) {
    if (!_isUnread(data)) return false;
    final name = (data.name ?? '').toString().toLowerCase();
    if (name == 'message') return false;
    if (_isInspectionAttention(data)) return true;
    if (data.orderId != null) return true;
    return {
      'booking_requested',
      'booking_request',
      'dispute_reported',
      'return_window_open',
      'payment_confirmed',
      'inspection_waiting',
      'inspection_started',
    }.contains(name);
  }

  bool _isInspectionAttention(Data data) {
    final name = (data.name ?? '').toString().toLowerCase();
    return name.contains('inspection') ||
        name.contains('pickup') ||
        name == 'return_window_open';
  }

  Future<void> _markAllRead() async {
    if (sourceId.isEmpty) return;
    await ApiRepository.shared.seenNotification(sourceId);
    if (mounted) _getNotifications();
  }

  void _seenNotification(dynamic id) {
    ApiRepository.shared.seenoneNotification(id);
  }

  String _notificationTitle(String? name) {
    final normalized = (name ?? '').toString().trim().toLowerCase();
    switch (normalized) {
      case 'booking_requested':
      case 'booking_request':
        return 'Booking requested';
      case 'booking_accepted':
        return 'Booking accepted';
      case 'booking_declined':
        return 'Booking declined';
      case 'booking_cancelled':
        return 'Booking cancelled';
      case 'payment_confirmed':
        return 'Payment confirmed';
      case 'return_window_open':
        return 'Return window open';
      case 'inspection_waiting':
      case 'inspection_started':
        return 'Pickup inspection ready';
      case 'dispute_reported':
        return 'Your issue is under review';
      case 'payout_released':
        return 'Payout released';
      case 'message':
        return 'Message';
      default:
        return name?.capitalizeFirst ?? 'Notification';
    }
  }

  String _relativeTime(String? raw) {
    final dt = parseApiDateTime(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dt);
  }

  String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  IconData _notificationIcon(String? name, {int? orderId}) {
    final normalized = (name ?? '').toString().toLowerCase();
    if (normalized == 'message') return Icons.chat_bubble_outline_rounded;
    if (normalized.contains('dispute') || normalized.contains('issue')) {
      return Icons.shield_outlined;
    }
    if (orderId != null ||
        normalized.contains('booking') ||
        normalized.contains('payment') ||
        normalized.contains('return')) {
      return Icons.verified_user_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  String? _actionLinkLabel(Data data) {
    final name = (data.name ?? '').toString().toLowerCase();
    if (name == 'message') return 'Open conversation';
    if (name.contains('dispute') || name.contains('issue')) return 'View issue';
    if (data.orderId != null) return 'View reservation';
    if (name.contains('booking') || name == 'order') return 'View order';
    if (data.productId != null) return 'View listing';
    return 'View details';
  }

  String? _primaryActionLabel(Data data) {
    if (!_needsAttention(data)) return null;
    final name = (data.name ?? '').toString().toLowerCase();
    if (_isInspectionAttention(data) ||
        name.contains('inspection') ||
        name.contains('pickup') ||
        name.contains('return_window')) {
      return 'Begin inspection';
    }
    if (name.contains('booking_request')) return 'Review booking';
    return null;
  }

  ({String title, String subtitle, String instruction}) _attentionContent(Data data) {
    final name = (data.name ?? '').toString().toLowerCase();
    final desc = (data.description ?? '').trim();

    final title = name.contains('return') || name == 'return_window_open'
        ? 'Return inspection ready'
        : _isInspectionAttention(data)
        ? 'Pickup inspection ready'
        : _notificationTitle(data.name);

    var subtitle = '';
    var instruction = 'Inspect together. Each person confirms.';

    if (desc.contains('\n')) {
      final parts =
          desc.split('\n').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
      if (parts.isNotEmpty) subtitle = parts.first;
      if (parts.length > 1) {
        instruction = parts.sublist(1).join(' ');
      }
    } else if (desc.contains(' · ')) {
      final parts = desc.split(' · ');
      subtitle = parts.first.trim();
      if (parts.length > 1) {
        instruction = parts.sublist(1).join(' · ').trim();
      }
    } else if (desc.isNotEmpty) {
      if (desc.toLowerCase().startsWith('inspect')) {
        instruction = desc;
      } else {
        subtitle = desc;
      }
    }

    return (title: title, subtitle: subtitle, instruction: instruction);
  }

  String? _messageSenderName(Data data) {
    final description = (data.description ?? '').trim();
    const prefix = 'You have a new message from ';
    if (!description.startsWith(prefix)) return null;
    final name = description.substring(prefix.length).trim();
    return name.isEmpty ? null : name;
  }

  void _onNotificationTap(Data data) {
    final name = (data.name ?? '').toString();
    _seenNotification(data.id);
    setState(() => data.seen = 1);

    if (name == 'message') {
      Get.to(
        () => MessagesScreen(
          showBackButton: widget.isVendor,
          messageSenderName: _messageSenderName(data),
        ),
      );
      return;
    }

    final orderId = data.orderId;
    if (orderId != null) {
      Get.to(() => ReservationDetailScreen(orderId: orderId));
      return;
    }

    if (name == 'order' && widget.isVendor) {
      Get.to(() => const VendorMyOrdersScreen());
    } else if ((name == 'booking_request' || name == 'booking_requested') &&
        widget.isVendor) {
      Get.to(() => const VendorMyOrdersScreen());
    }
  }

  Widget _attentionActionButton({
    required String label,
    required VoidCallback onPressed,
    double borderRadius = 14,
    double fontSize = 14,
  }) {
    return Center(
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.jebbyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: _nunito(
            size: fontSize,
            weight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_canPop() || widget.isVendor) ...[
          _backButton(),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: (_canPop() || widget.isVendor) ? 2 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isVendor
                      ? 'Keep your business moving.'
                      : 'Stay on top of what matters.',
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        _settingsButton(),
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

  Widget _settingsButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Get.to(() => SettingsScreen(showBackButton: true)),
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.settings_outlined,
            size: 20,
            color: AppColors.jebbyTextPrimary,
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    return Row(
      children: [
        Expanded(
          child: _filterChip(
            label: 'All',
            selected: _filter == _NotificationFilter.all,
            onTap: () => setState(() => _filter = _NotificationFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterChip(
            label: 'Unread ($_unreadCount)',
            selected: _filter == _NotificationFilter.unread,
            onTap: () => setState(() => _filter = _NotificationFilter.unread),
          ),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.jebbyBlue : AppColors.jebbySoftBlue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: Text(
              label,
              style: _nunito(
                size: 14,
                weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.jebbyTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _markAllReadLink() {
    if (_unreadCount == 0) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _markAllRead,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.jebbyBlue,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Mark all read',
          style: _nunito(size: 14, weight: FontWeight.w700, color: AppColors.jebbyBlue),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: _nunito(size: 16, weight: FontWeight.w800),
      ),
    );
  }

  Widget _attentionInspectionCard(Data data) {
    final content = _attentionContent(data);
    final time = _relativeTime(data.createdAt?.toString());
    final actionLabel = _primaryActionLabel(data) ?? 'Begin inspection';

    return Material(
      color: _attentionCardBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _onNotificationTap(data),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.jebbyBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _attentionIconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 24,
                      color: _attentionIconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                content.title,
                                style: _nunito(size: 16, weight: FontWeight.w800),
                              ),
                            ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: _nunito(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.jebbyTextMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (content.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            content.subtitle,
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: _attentionSubtitle,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          content.instruction,
                          style: _nunito(
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _attentionActionButton(
                label: actionLabel,
                onPressed: () => _onNotificationTap(data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(Data data, {bool attention = false}) {
    final unread = _isUnread(data);
    final name = (data.name ?? '').toString();
    final desc = (data.description ?? '').toString();
    final title = _notificationTitle(name);
    final actionLabel = _actionLinkLabel(data);
    final primaryAction = _primaryActionLabel(data);
    final time = _relativeTime(data.createdAt?.toString());

    final background = attention
        ? AppColors.earnerInfoBlue
        : unread
        ? AppColors.jebbySoftBlue.withValues(alpha: 0.55)
        : Colors.white;
    final borderColor = attention
        ? AppColors.jebbyBlue.withValues(alpha: 0.22)
        : unread
        ? AppColors.jebbyBlue.withValues(alpha: 0.12)
        : _cardBorder;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _onNotificationTap(data),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.jebbyBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: unread
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.jebbySoftBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _notificationIcon(name, orderId: data.orderId),
                      size: 20,
                      color: attention
                          ? AppColors.jebbyBlue
                          : AppColors.jebbyTextMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: _nunito(size: 15, weight: FontWeight.w800),
                              ),
                            ),
                            if (time.isNotEmpty)
                              Text(
                                time,
                                style: _nunito(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.jebbyTextMuted,
                                ),
                              ),
                          ],
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (primaryAction != null) ...[
                const SizedBox(height: 12),
                _attentionActionButton(
                  label: primaryAction,
                  onPressed: () => _onNotificationTap(data),
                ),
              ] else if (actionLabel != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.jebbyBlue,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyUnreadState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, constraints.maxHeight * 0.08, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.jebbySoftBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 40,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No unread notifications',
                    textAlign: TextAlign.center,
                    style: _nunito(size: 22, weight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You may still have actions to complete.',
                    textAlign: TextAlign.center,
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => setState(() => _filter = _NotificationFilter.all),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.jebbyBlue,
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View all notifications',
                          style: _nunito(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.jebbyBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyAllState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.jebbySoftBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: AppColors.jebbyBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              textAlign: TextAlign.center,
              style: _nunito(size: 22, weight: FontWeight.w800, height: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              'Updates about bookings, messages, and listings will appear here.',
              textAlign: TextAlign.center,
              style: _nunito(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotificationSections(List<Data> items) {
    final attention = items.where(_needsAttention).toList();
    final rest = items.where((e) => !_needsAttention(e)).toList();

    final Map<String, List<Data>> grouped = {};
    for (final item in rest) {
      final createdAt =
          parseApiDateTime(item.createdAt?.toString()) ?? DateTime.now();
      final key = _sectionLabel(createdAt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final widgets = <Widget>[];

    if (attention.isNotEmpty) {
      widgets.add(_sectionTitle('Needs your attention'));
      for (final item in attention) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _isInspectionAttention(item)
              ? _attentionInspectionCard(item)
              : _notificationCard(item, attention: true),
        ));
      }
      widgets.add(const SizedBox(height: 8));
    }

    grouped.forEach((sectionTitle, sectionItems) {
      widgets.add(_sectionTitle(sectionTitle));
      for (final item in sectionItems) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _notificationCard(item),
        ));
      }
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems();
    final showUnreadEmpty =
        !isLoading && _filter == _NotificationFilter.unread && filtered.isEmpty;
    final showAllEmpty = !isLoading && isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _pageHeader(),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _filterChips(),
                  const SizedBox(height: 6),
                  _markAllReadLink(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.jebbyBlue,
                        strokeWidth: 2.4,
                      ),
                    )
                  : showAllEmpty
                  ? _emptyAllState()
                  : showUnreadEmpty
                  ? _emptyUnreadState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: _buildNotificationSections(filtered),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
