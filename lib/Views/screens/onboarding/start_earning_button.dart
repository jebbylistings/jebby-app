import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/widgets/earn_member_banner.dart';
import 'package:jebby/view_model/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartEarningButton extends StatefulWidget {
  const StartEarningButton({super.key});

  @override
  State<StartEarningButton> createState() => _StartEarningButtonState();
}

class _StartEarningButtonState extends State<StartEarningButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapController());
  }

  Future<void> _bootstrapController() async {
    final controller = ensureOnboardingController();
    if (controller.userId.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '';
    if (userId.isEmpty) return;

    await controller.loadAndReconcile(
      userId: userId,
      name: prefs.getString('fullname'),
      email: prefs.getString('email'),
      phone: prefs.getString('phoneNumber'),
    );
  }

  @override
  Widget build(BuildContext context) {
    ensureOnboardingController();

    return GetBuilder<OnboardingController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final state = controller.state;

        if (state.isComplete) {
          return const SizedBox.shrink();
        }

        final stepsRemaining = state.stepsRemaining;
        final filledSegments = _macroProgressFilled(state.onboardingStep);
        // Match drawer menu item width (see drawer.dart: res_width * 0.75).
        final cardWidth = MediaQuery.of(context).size.width * 0.75;

        return SizedBox(
          width: cardWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EarnMemberBanner(
                onTap: () => controller.startOrResume(),
              ),
              const SizedBox(height: 10),
              _StartEarningProgressCard(
                stepsRemaining: stepsRemaining,
                filledSegments: filledSegments,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Maps the 10-step flow onto 3 high-level phases shown in the design.
  static int _macroProgressFilled(int step) {
    if (step >= 4) return 1;
    return 0;
  }
}

class _StartEarningProgressCard extends StatelessWidget {
  final int stepsRemaining;
  final int filledSegments;

  const _StartEarningProgressCard({
    required this.stepsRemaining,
    required this.filledSegments,
  });

  static const int _totalSegments = 3;
  static const Color _trackColor = Color(0xFFE2E5EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
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
                decoration: BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: darkBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF4A4D55),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: "You're "),
                        TextSpan(
                          text: '$stepsRemaining',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: darkBlue,
                          ),
                        ),
                        const TextSpan(
                          text: ' steps away from earning with Jebby.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_totalSegments, (index) {
              final isFilled = index < filledSegments;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < _totalSegments - 1 ? 6 : 0,
                  ),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: isFilled ? darkBlue : _trackColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
