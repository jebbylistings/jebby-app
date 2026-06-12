import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/onboarding/onboarding_scaffold.dart';
import 'package:jebby/Views/screens/vendors/addproduct.dart';
import 'package:jebby/Views/screens/vendors/vendorhome.dart';
import 'package:jebby/view_model/onboarding_controller.dart';

class AllSetScreen extends StatefulWidget {
  const AllSetScreen({super.key});

  @override
  State<AllSetScreen> createState() => _AllSetScreenState();
}

class _AllSetScreenState extends State<AllSetScreen> {
  late final OnboardingController _controller =
      ensureOnboardingController();
  bool _isCompleting = true;

  @override
  void initState() {
    super.initState();
    _finalizeOnboarding();
  }

  Future<void> _finalizeOnboarding() async {
    await _controller.advanceTo(10);
    await _controller.completeProviderRole();
    if (mounted) setState(() => _isCompleting = false);
  }

  void _listFirstItem() {
    Get.offAll(() => VendrosHomeScreen());
    Get.to(() => AddProductScreen());
  }

  void _maybeLater() {
    Get.offAll(() => VendrosHomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 10,
      title: 'All Set',
      showBackButton: false,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFBA104).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(44),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFFFBA104),
              size: 56,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "You're all set!",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your account is verified and ready to start earning.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const _SuccessCheckItem(label: 'Identity verified'),
          const SizedBox(height: 12),
          const _SuccessCheckItem(label: 'Payouts set up'),
          const SizedBox(height: 12),
          const _SuccessCheckItem(label: 'Account activated'),
          const SizedBox(height: 40),
        ],
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            OnboardingPrimaryButton(
              label: 'List Your First Item',
              isLoading: _isCompleting,
              onPressed: _isCompleting ? null : _listFirstItem,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isCompleting ? null : _maybeLater,
              child: Text(
                'Maybe Later',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCheckItem extends StatelessWidget {
  final String label;

  const _SuccessCheckItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 22),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
