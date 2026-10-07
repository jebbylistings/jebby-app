import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/view_models/listing_form_controller.dart';
import 'package:jebby/view_models/user_view_model.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/listing_kit.dart';
import 'package:jebby/views/screens/vendors/listing/listing_published.dart';
import 'package:jebby/views/screens/navigation/home_main.dart';
import 'package:jebby/views/screens/vendors/listing/listing_steps.dart';
import 'package:jebby/views/screens/vendors/my_products.dart';

class CreateListingScreen extends StatefulWidget {
  final String? editProductId;
  final bool popToProductsOnBack;
  final bool popToHomeOnBack;
  final int initialStep;

  const CreateListingScreen({
    super.key,
    this.editProductId,
    this.popToProductsOnBack = false,
    this.popToHomeOnBack = false,
    this.initialStep = 1,
  });

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  late final ListingFormController _controller;
  PageController? _pageController;
  int _step = 1;

  /// When set, Continue / back from an edited step returns to review (step 5).
  int? _resumeReviewAfterStep;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ListingFormController>()) {
      Get.delete<ListingFormController>();
    }
    _controller = Get.put(ListingFormController());
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final user = await UserViewModel().getUser();
    await _controller.bootstrap(
      editProductId: widget.editProductId,
      userId: user.id.toString(),
    );
    if (!mounted) return;
    final step = _controller.draft.currentStep.clamp(1, ListingStepLabels.totalSteps);
    _pageController?.dispose();
    _pageController = PageController(initialPage: step - 1);
    setState(() {
      _step = step;
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _onBack() async {
    final reviewStep = _resumeReviewAfterStep;
    if (reviewStep != null && _step != reviewStep) {
      _goToStep(reviewStep);
      return;
    }
    if (_step > 1) {
      _goToStep(_step - 1);
      return;
    }
    if (_controller.draft.isDirty) {
      final discard = await showListingDiscardDialog(context);
      if (discard == true) {
        await _controller.clearDraft();
        _popRoute();
      }
      return;
    }
    _popRoute();
  }

  void _popRoute() {
    if (widget.popToProductsOnBack) {
      Get.off(() => MyProductsScreen(side: false));
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAll(() => const MainScreen());
  }

  void _editFromReview(int step) {
    _resumeReviewAfterStep = ListingStepLabels.totalSteps;
    _goToStep(step);
  }

  void _goToStep(int step) {
    final next = step.clamp(1, ListingStepLabels.totalSteps);
    if (next == ListingStepLabels.totalSteps) {
      _resumeReviewAfterStep = null;
    }
    setState(() {
      _step = next;
      _controller.draft.currentStep = next;
    });
    _pageController?.animateToPage(
      next - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _controller.persistDraft();
    if (next == 4 && widget.editProductId == null) {
      _controller.prefillLocationFromUserProfileIfNeeded();
    }
  }

  String _subtitleForStep(int step) {
    if (step == ListingStepLabels.totalSteps) {
      return 'Review everything before publishing';
    }
    switch (step) {
      case 1:
        return 'Add photos and describe your item.';
      case 2:
        return 'Choose the category and condition.';
      case 3:
        return 'Set your daily price and security deposit.';
      case 4:
        return 'Review location, availability, and handoff.';
      default:
        return 'Build a listing renters can book';
    }
  }

  String _continueLabelForStep(int step) {
    if (_resumeReviewAfterStep != null) {
      return 'Return to review';
    }
    switch (step) {
      case 1:
        return 'Continue to category';
      case 2:
        return 'Continue to pricing';
      case 3:
        return 'Pickup & delivery';
      case 4:
        return 'Review your listing';
      default:
        return 'Continue';
    }
  }

  Future<void> _saveAndExit() async {
    _controller.draft.currentStep = _step;
    try {
      await _controller.persistDraft();
      _controller.draft.isDirty = false;
    } catch (_) {
      if (!mounted) return;
      showAppErrorSnackbar('Could not save your progress. Try again.');
      return;
    }
    if (!mounted) return;
    _popRoute();
    showAppSuccessSnackbar('Progress saved.');
  }

  Future<void> _continue() async {
    final err = _controller.validateStep(_step);
    if (err != null) {
      showAppErrorSnackbar(err);
      return;
    }
    await _controller.persistDraft();
    if (_step >= ListingStepLabels.totalSteps) return;
    final reviewStep = _resumeReviewAfterStep;
    if (reviewStep != null) {
      _goToStep(reviewStep);
      return;
    }
    _goToStep(_step + 1);
  }

  /// Persists the listing via productInsert/productUpdate with `listing_status: draft`.
  Future<void> _saveAsDraft() async {
    for (var s = 1; s <= 4; s++) {
      final err = _controller.validateStep(s);
      if (err != null) {
        showAppErrorSnackbar(err, title: 'Incomplete listing');
        _goToStep(s);
        return;
      }
    }

    final ok = await _controller.submit(publish: false);
    if (!mounted) return;
    if (!ok) {
      showAppErrorSnackbar('Could not save draft. Try again.');
      return;
    }
    showAppSuccessSnackbar('Draft saved.');
    Get.off(() => MyProductsScreen(side: false));
  }

  Future<void> _publishListing() async {
    for (var s = 1; s <= 4; s++) {
      final err = _controller.validateStep(s);
      if (err != null) {
        showAppErrorSnackbar(err, title: 'Incomplete listing');
        _goToStep(s);
        return;
      }
    }

    _controller.isSubmitting = true;
    _controller.update();

    final blocked = await _controller.publishBlockedMessage();
    if (blocked != null) {
      _controller.isSubmitting = false;
      _controller.update();
      showAppErrorSnackbar(blocked, title: 'Cannot publish yet');
      return;
    }

    final draft = _controller.draft;
    final publishName =
        draft.name.trim().isEmpty ? 'Your item' : draft.name.trim();
    final publishPrice = draft.pricePerDay;
    final publishLocation = draft.location.publicCityState.trim();
    ListingPhotoRef? publishCover;
    if (draft.photos.isNotEmpty) {
      for (final p in draft.photos) {
        if (p.isCover) {
          publishCover = p;
          break;
        }
      }
      publishCover ??= draft.photos.first;
    }

    final ok = await _controller.submit(publish: true);
    if (!ok) {
      showAppErrorSnackbar('Could not save listing. Try again.');
      return;
    }
    Get.off(
      () => ListingPublishedScreen(
        listingName: publishName,
        pricePerDay: publishPrice,
        locationLabel: publishLocation,
        coverPhoto: publishCover,
        productId: _controller.lastPublishedProductId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        if (c.isLoading || _pageController == null) {
          return Scaffold(
            backgroundColor: AppColors.jebbyBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.jebbyBlue,
                backgroundColor: AppColors.jebbySoftBlue,
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        final pageController = _pageController!;
        final isReview = _step == ListingStepLabels.totalSteps;
        final reviewActionsLocked = c.isSubmitting || c.isSavingDraft;
        return ListingStepShell(
          title: widget.editProductId != null ? 'Edit listing' : 'Create a listing',
          subtitle: _subtitleForStep(_step),
          subtitleColor:
              isReview ? null : AppColors.jebbyBlue,
          stepNumber: _step,
          onBack: _onBack,
          bodyScrollable: false,
          body: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24),
                child: ListingPhotosBasicsStep(),
              ),
              const SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24),
                child: ListingCategoryConditionStep(),
              ),
              const SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24),
                child: ListingPricingStep(),
              ),
              const SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24),
                child: ListingHandoffAvailabilityStep(),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: ListingReviewStep(onEditStep: _editFromReview),
              ),
            ],
          ),
          bottomBar: Column(
            children: [
              if (isReview) ...[
                OnboardingPrimaryButton(
                  label: 'Publish listing',
                  loadingLabel: 'Publishing…',
                  isLoading: c.isSubmitting,
                  onPressed: reviewActionsLocked ? null : _publishListing,
                ),
                const SizedBox(height: 10),
                OnboardingSecondaryButton(
                  label: 'Save as draft',
                  onPressed: reviewActionsLocked ? null : _saveAsDraft,
                ),
              ] else ...[
                OnboardingPrimaryButton(
                  label: _continueLabelForStep(_step),
                  onPressed: _continue,
                ),
                if ((_step == 1 || _step == 4) && widget.editProductId == null) ...[
                  const SizedBox(height: 10),
                  OnboardingSecondaryButton(
                    label: 'Save & exit',
                    onPressed: _saveAndExit,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
