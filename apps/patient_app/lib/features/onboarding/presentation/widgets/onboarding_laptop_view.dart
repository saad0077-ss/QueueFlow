import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'onboarding_animation_side.dart';
import 'onboarding_auth_side.dart';

class OnboardingLaptopView extends StatelessWidget {
  const OnboardingLaptopView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 11,
          child: OnboardingAnimationSide(),
        ),
        Container(
          width: 1,
          color: colors.border.withValues(alpha: 0.4),
        ),
        const Expanded(
          flex: 10,
          child: OnboardingAuthSide(),
        ),
      ],
    );
  }
}
