import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String _bannerAsset = 'assets/images/about-banner.png';
  static const String _supportEmail = 'support@jebbylistings.com';
  static const double _horizontalPadding = 20;

  static TextStyle _nunito({
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
                4,
                _horizontalPadding,
                0,
              ),
              child: SizedBox(
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    JebbyFlowBackButton(onTap: _handleBack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'About Jebby',
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: _nunito(
                          size: 22,
                          weight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  0,
                  _horizontalPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AboutBanner(bannerAsset: _bannerAsset, nunito: _nunito),
                    const SizedBox(height: 28),
                    Text(
                      'What you need, when you need it.',
                      style: _nunito(
                        size: 20,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'I connect people who need items for a short time with local providers who own them. '
                      'Instead of buying something you\'ll only use occasionally, rent it simply, securely, and on your schedule.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Planning an event, tackling a home project, or trying gear before you buy? '
                      'I\'ll help you find what you need from trusted local providers.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Two ways to be part of Jebby.',
                      style: _nunito(
                        size: 20,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Need it for a little while? Or have it to share?',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      badge: 'FOR RENTERS',
                      heading: 'Bring your plans to life.',
                      items: const [
                        _AboutFeatureItem(
                          icon: Icons.search_rounded,
                          title: 'Discover something nearby',
                          body: 'Browse categories and find items near you.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.assignment_outlined,
                          title: 'Know before you book',
                          body:
                              'View product details, pricing, and availability.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.calendar_month_outlined,
                          title: 'Make it fit your plans',
                          body: 'Book rentals with clear start and end dates.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Keep everything together',
                          body:
                              'Manage orders, payments, and notifications in one place.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.description_outlined,
                          title: 'Rent with clarity',
                          body: 'Read policies and agreements before you rent.',
                        ),
                      ],
                      nunito: _nunito,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      badge: 'FOR EARNERS',
                      heading: 'Your items. New possibilities.',
                      items: const [
                        _AboutFeatureItem(
                          icon: Icons.public_outlined,
                          title: 'Share what you own',
                          body:
                              'List your items and set your own rental terms.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Stay on top of your rentals',
                          body:
                              'Manage listings, orders, and customer messages.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.credit_card_outlined,
                          title: 'Get paid securely',
                          body:
                              'Receive payments through our secure checkout flow.',
                        ),
                        _AboutFeatureItem(
                          icon: Icons.storefront_outlined,
                          title: 'Grow your rental business',
                          body: 'Build on a trusted marketplace platform.',
                        ),
                      ],
                      nunito: _nunito,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Why Jebby?',
                      style: _nunito(
                        size: 20,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Like other modern marketplaces, Jebby connects customers with independent providers. '
                      'Our goal is to make renting easy, transparent, and reliable for everyone.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _WhiteCard(
                      child: Column(
                        children: [
                          _AboutFeatureRow(
                            item: const _AboutFeatureItem(
                              icon: Icons.verified_user_outlined,
                              title: 'Trust',
                              body:
                                  'Verified listings, clear policies, and structured rental agreements.',
                            ),
                            nunito: _nunito,
                          ),
                          const SizedBox(height: 20),
                          _AboutFeatureRow(
                            item: const _AboutFeatureItem(
                              icon: Icons.smartphone_outlined,
                              title: 'Convenience',
                              body:
                                  'Search, book, and manage your rentals right from your phone.',
                            ),
                            nunito: _nunito,
                          ),
                          const SizedBox(height: 20),
                          _AboutFeatureRow(
                            item: const _AboutFeatureItem(
                              icon: Icons.groups_outlined,
                              title: 'Community',
                              body:
                                  'Support local providers and make sustainable sharing part of everyday life.',
                            ),
                            nunito: _nunito,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SupportCard(
                      email: _supportEmail,
                      onEmailTap: _emailSupport,
                      nunito: _nunito,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'You\'re part of what makes Jebby, Jebby.',
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 18,
                        weight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Thank you for being part of the Jebby community.',
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your rental buddy, Jebby',
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w700,
                        color: AppColors.jebbyBlue,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBanner extends StatelessWidget {
  const _AboutBanner({required this.bannerAsset, required this.nunito});

  final String bannerAsset;
  final TextStyle Function({
    required double size,
    FontWeight weight,
    Color? color,
    double? height,
  })
  nunito;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final textWidth = width * 0.58;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                bannerAsset,
                width: width,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              Positioned(
                left: 20,
                top: 40,
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, I\'m Jebby.',
                      style: nunito(
                        size: 22,
                        weight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                        height: 1.15,
                      ),
                    ),
                    Text(
                      'Your rental buddy.',
                      style: nunito(
                        size: 22,
                        weight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A little help for your next big idea.',
                      style: nunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: const Color(0xFF4E5E74),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AboutFeatureItem {
  const _AboutFeatureItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.badge,
    required this.heading,
    required this.items,
    required this.nunito,
  });

  final String badge;
  final String heading;
  final List<_AboutFeatureItem> items;
  final TextStyle Function({
    required double size,
    FontWeight weight,
    Color? color,
    double? height,
  })
  nunito;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionBadge(label: badge, nunito: nunito),
          const SizedBox(height: 12),
          Text(
            heading,
            style: nunito(size: 18, weight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _AboutFeatureRow(item: items[i], nunito: nunito),
          ],
        ],
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.label, required this.nunito});

  final String label;
  final TextStyle Function({
    required double size,
    FontWeight weight,
    Color? color,
    double? height,
  })
  nunito;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: nunito(
          size: 11,
          weight: FontWeight.w800,
          color: AppColors.jebbyBlue,
          height: 1.0,
        ),
      ),
    );
  }
}

class _AboutFeatureRow extends StatelessWidget {
  const _AboutFeatureRow({required this.item, required this.nunito});

  final _AboutFeatureItem item;
  final TextStyle Function({
    required double size,
    FontWeight weight,
    Color? color,
    double? height,
  })
  nunito;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.jebbySoftBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(item.icon, size: 22, color: AppColors.jebbyBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: nunito(size: 16, weight: FontWeight.w800, height: 1.25),
              ),
              const SizedBox(height: 4),
              Text(
                item.body,
                style: nunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.email,
    required this.onEmailTap,
    required this.nunito,
  });

  final String email;
  final VoidCallback onEmailTap;
  final TextStyle Function({
    required double size,
    FontWeight weight,
    Color? color,
    double? height,
  })
  nunito;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.earnerBannerBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.headset_mic_outlined,
                  size: 22,
                  color: AppColors.jebbyBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Need a hand? We\'re here.',
                    style: nunito(
                      size: 18,
                      weight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Questions about your account, an order, or a listing? Our support team is here to help.',
            style: nunito(
              size: 14,
              weight: FontWeight.w600,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onEmailTap,
            child: Text(
              email,
              style: nunito(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.jebbyBlue,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll get back to you as soon as possible.',
            style: nunito(
              size: 14,
              weight: FontWeight.w600,
              color: const Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onEmailTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.jebbyBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Email support',
                style: nunito(
                  size: 16,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
