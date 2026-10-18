import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class FaqSection {
  const FaqSection({required this.title, required this.items});

  final String title;
  final List<FaqItem> items;
}

enum _FaqAudience { renter, earner }

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  static const String _supportEmail = 'support@jebbylistings.com';
  static const double _horizontalPadding = 20;
  static const Color _cardBorder = Color(0xFFE3E6EC);

  _FaqAudience _audience = _FaqAudience.renter;

  /// `'sectionIndex-itemIndex'` of the expanded FAQ, if any.
  String? _expandedKey;

  static const List<FaqSection> _renterSections = [
    FaqSection(
      title: 'Booking & payment',
      items: [
        FaqItem(
          question: 'How far ahead should I make my reservation?',
          answer:
              'The sooner, the better. Items are available on a first-come, first-served basis. '
              'Demand is usually highest around holidays, winter, and summer.',
        ),
        FaqItem(
          question: 'Can I pay when the reservation starts?',
          answer:
              'No. We require full payment at the time of booking. When you book, we hold those items for you '
              'and do not offer them to other renters for the same dates, similar to a vacation rental reservation.',
        ),
        FaqItem(
          question: 'What forms of payment do you accept?',
          answer:
              'We accept Visa, MasterCard, American Express, JCB, and Discover. Stripe processes all payments.',
        ),
      ],
    ),
    FaqSection(
      title: 'Rental & delivery',
      items: [
        FaqItem(
          question: 'How do you calculate the number of days in a rental?',
          answer:
              'We count each day that you have an item as one day. For example, if you rent an item starting '
              'early evening on Monday and return it the following Monday morning, that counts as 8 days.',
        ),
        FaqItem(
          question: 'Is there a minimum rental period?',
          answer:
              'Providers can set minimum rental periods for each listing. Check the item description for any minimum.',
        ),
        FaqItem(
          question: 'Where are items picked up/delivered?',
          answer:
              'After you complete your order, your provider will contact you to arrange pickup or delivery. '
              'Each provider sets their own handoff terms and related fees.',
        ),
        FaqItem(
          question: 'How much does delivery cost?',
          answer:
              'Each provider sets their own delivery rates and service areas. Extra fees may apply for same-day, '
              'after-hours, or holiday delivery. Check the listing or confirm with the provider for accurate costs.',
        ),
        FaqItem(
          question: 'What is included in the delivery fee?',
          answer:
              'When delivery applies, the fee typically includes delivery, setup of most items, and pickup at the end of the rental.',
        ),
      ],
    ),
    FaqSection(
      title: 'Changes & item care',
      items: [
        FaqItem(
          question: 'How do I view or modify my Jebby reservation?',
          answer:
              'Log into your Jebby account to view or change your reservation. Changes should be made at least '
              '48 hours before the rental start when possible; some changes need provider approval. Within 48 hours '
              'of the start time, contact the provider directly. Your original payment method is charged for approved changes.',
        ),
        FaqItem(
          question:
              'What happens if I damage, lose, or return gear in poor condition?',
          answer:
              'You are responsible for items once they are in your care. They must be returned in the condition received. '
              'Damage, loss, or excessive wear may result in additional charges, including fair market replacement cost when needed.',
        ),
      ],
    ),
    FaqSection(
      title: 'Fees & cancellation',
      items: [
        FaqItem(
          question: 'What is the Jebby service charge?',
          answer:
              'Jebby charges a service fee when you book through the platform to help cover processing and support. '
              'The fee is based on rental and applicable delivery charges; the exact amount is shown before you pay.',
        ),
        FaqItem(
          question: 'What is your cancellation policy?',
          answer:
              'You may cancel up to 48 hours before the rental start time for a full refund. Cancellations within '
              '48 hours of the start time are non-refundable unless otherwise stated in the listing or policy.',
        ),
        FaqItem(
          question: 'Can I cancel a reservation myself?',
          answer:
              'Yes. Log into your Jebby account, open the reservation, and follow the cancel option where available.',
        ),
      ],
    ),
  ];

  static const List<FaqSection> _earnerSections = [
    FaqSection(
      title: 'Listing & rental terms',
      items: [
        FaqItem(
          question: 'How do I start sharing my items?',
          answer:
              'Create a listing and set your rental terms. You can manage listings, bookings and messages, '
              'and receive payments through Jebby checkout.',
        ),
        FaqItem(
          question: 'Can I set a minimum rental period?',
          answer:
              'Yes. When you create or edit a listing, you can set a minimum rental period that renters must meet.',
        ),
      ],
    ),
    FaqSection(
      title: 'Delivery & pickup',
      items: [
        FaqItem(
          question: 'Who sets delivery and pickup terms?',
          answer:
              'You set delivery, pickup, and handoff terms for each listing including whether you offer delivery, '
              'pickup only, or both.',
        ),
        FaqItem(
          question: 'Can I set my delivery rates and areas?',
          answer:
              'Yes. You decide your service area and delivery rates. Most providers start with a range near where they live.',
        ),
        FaqItem(
          question: 'Can extra delivery fees apply?',
          answer:
              'You may charge additional fees for same-day requests, after-hours handoffs, holidays, or other special arrangements you define.',
        ),
        FaqItem(
          question: 'When do I arrange delivery with the renter?',
          answer:
              'After a booking is confirmed and payment is secured, coordinate the handoff through the app. '
              'Use messages and reservation details to agree on timing and location.',
        ),
      ],
    ),
    FaqSection(
      title: 'Reservation changes',
      items: [
        FaqItem(
          question: 'Do reservation changes need my approval?',
          answer:
              'Some renter-requested changes such as date extensions or item changes require your approval. '
              'You will be notified in the app when a change needs your response.',
        ),
      ],
    ),
  ];

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

  @override
  void initState() {
    super.initState();
    _expandedKey = '0-0';
    _loadDefaultAudience();
  }

  Future<void> _loadDefaultAudience() async {
    final sp = await SharedPreferences.getInstance();
    final role = sp.getString('role');
    if (!mounted) return;
    setState(() {
      if (role == '1') {
        _audience = _FaqAudience.earner;
      }
    });
  }

  List<FaqSection> get _sections =>
      _audience == _FaqAudience.renter ? _renterSections : _earnerSections;

  int get _questionCount =>
      _sections.fold(0, (sum, section) => sum + section.items.length);

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  void _setAudience(_FaqAudience audience) {
    if (_audience == audience) return;
    setState(() {
      _audience = audience;
      _expandedKey = '0-0';
    });
  }

  void _toggleExpanded(int sectionIndex, int itemIndex) {
    final key = '$sectionIndex-$itemIndex';
    setState(() {
      _expandedKey = _expandedKey == key ? null : key;
    });
  }

  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent('Jebby support')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                8,
                _horizontalPadding,
                0,
              ),
              child: _pageHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  20,
                  _horizontalPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Good questions.',
                      style: _nunito(
                        size: 26,
                        weight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Clear answers.',
                      style: _nunito(
                        size: 26,
                        weight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A little guidance for renting and earning.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    Text(
                      'Choose your side of the sharing.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _audienceToggle(),
                    const SizedBox(height: 30),
                    _audienceMetaRow(),
                    const SizedBox(height: 30),
                    ..._buildSectionWidgets(),
                    const SizedBox(height: 8),
                    _stillHaveQuestionFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          JebbyFlowBackButton(onTap: _handleBack),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'FAQs',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: _nunito(size: 22, weight: FontWeight.w800, height: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _audienceToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _RoleSegmentOption(
              label: 'Renter',
              selected: _audience == _FaqAudience.renter,
              onTap: () => _setAudience(_FaqAudience.renter),
            ),
          ),
          Expanded(
            child: _RoleSegmentOption(
              label: 'Earner',
              selected: _audience == _FaqAudience.earner,
              onTap: () => _setAudience(_FaqAudience.earner),
            ),
          ),
        ],
      ),
    );
  }

  Widget _audienceMetaRow() {
    final label =
        _audience == _FaqAudience.renter ? 'FOR RENTERS' : 'FOR EARNERS';
    return Row(
      children: [
        Text(
          label,
          style: _nunito(
            size: 12,
            weight: FontWeight.w800,
            color: AppColors.jebbyBlue,
            height: 1.0,
          ),
        ),
        const Spacer(),
        Text(
          '$_questionCount questions',
          style: _nunito(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionWidgets() {
    final widgets = <Widget>[];
    for (var s = 0; s < _sections.length; s++) {
      final section = _sections[s];
      if (s > 0) widgets.add(const SizedBox(height: 8));
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Text(
            section.title,
            style: _nunito(size: 17, weight: FontWeight.w800, height: 1.25),
          ),
        ),
      );
      for (var i = 0; i < section.items.length; i++) {
        final key = '$s-$i';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FaqAccordionTile(
              item: section.items[i],
              expanded: _expandedKey == key,
              cardBorder: _cardBorder,
              onToggle: () => _toggleExpanded(s, i),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _stillHaveQuestionFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Still have a question?',
            style: _nunito(size: 18, weight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 8),
          Text(
            'Can\'t find what you need? Email us and we\'ll be happy to help!',
            style: _nunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _emailSupport,
            child: Text(
              _supportEmail,
              style: _nunito(
                size: 15,
                weight: FontWeight.w700,
                color: AppColors.jebbyBlue,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqAccordionTile extends StatefulWidget {
  const _FaqAccordionTile({
    required this.item,
    required this.expanded,
    required this.cardBorder,
    required this.onToggle,
  });

  final FaqItem item;
  final bool expanded;
  final Color cardBorder;
  final VoidCallback onToggle;

  @override
  State<_FaqAccordionTile> createState() => _FaqAccordionTileState();
}

class _FaqAccordionTileState extends State<_FaqAccordionTile>
    with SingleTickerProviderStateMixin {
  static const Duration _animDuration = Duration(milliseconds: 280);

  late final AnimationController _controller;
  late final Animation<double> _expandCurve;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animDuration);
    _expandCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.expanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_FaqAccordionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: Text(
                        widget.item.question,
                        style: _nunito(
                          size: 16,
                          weight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  _ExpandToggleIcon(expanded: widget.expanded),
                ],
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandCurve.value,
                  child: FadeTransition(
                    opacity: _expandCurve,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        widget.item.answer,
                        style: _nunito(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                          height: 1.5,
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
    );
  }
}

class _ExpandToggleIcon extends StatelessWidget {
  const _ExpandToggleIcon({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: expanded
          ? Container(
              key: const ValueKey('expanded'),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.jebbyBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 20, color: Colors.white),
            )
          : Container(
              key: const ValueKey('collapsed'),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.jebbySoftBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.add, size: 22, color: AppColors.jebbyBlue),
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
