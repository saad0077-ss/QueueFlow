import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_button.dart';
import 'onboarding_auth_buttons.dart';
import 'onboarding_page_indicator.dart';

class OnboardingBottomControls extends StatelessWidget {
  final bool isFinalScreen;
  final int currentPage;
  final VoidCallback onNextPressed;

  const OnboardingBottomControls({
    super.key,
    required this.isFinalScreen,
    required this.currentPage,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFinalScreen) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingPageIndicator(
            currentPage: currentPage,
            totalPages: 2,
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GradientButton(
              text: 'Next',
              onPressed: onNextPressed,
            ),
          ),
        ],
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: OnboardingAuthButtons(),
    );
  }
}
