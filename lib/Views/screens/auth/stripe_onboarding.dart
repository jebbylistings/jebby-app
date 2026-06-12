import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/screens/onboarding/stripe_welcome.dart';
import 'package:jebby/view_model/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legacy entry point — redirects to the new Start Earning onboarding flow.
class StripeOnboardingScreen extends StatefulWidget {
  final String userId;
  final String verificationStatus;
  final bool isFromTransactions;

  const StripeOnboardingScreen({
    Key? key,
    required this.userId,
    this.verificationStatus = '',
    this.isFromTransactions = false,
  }) : super(key: key);

  @override
  State<StripeOnboardingScreen> createState() => _StripeOnboardingScreenState();
}

class _StripeOnboardingScreenState extends State<StripeOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = widget.userId.isNotEmpty
        ? widget.userId
        : (prefs.getString('id') ?? '');
    final name = prefs.getString('fullname') ?? '';
    final email = prefs.getString('email') ?? '';

    final controller = ensureOnboardingController();
    await controller.loadAndReconcile(
      userId: userId,
      name: name,
      email: email,
      phone: prefs.getString('phoneNumber'),
    );

    if (!mounted) return;

    if (controller.state.isComplete && !widget.isFromTransactions) {
      controller.navigateToStep(10);
      return;
    }

    if (widget.isFromTransactions) {
      Get.off(() => const StripeWelcomeScreen(isFromTransactions: true));
      return;
    }

    await controller.startOrResume();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
