import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_logo.dart';

class OnboardingTopBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onSkip;

  const OnboardingTopBar({
    super.key,
    required this.currentPage,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogo(fontSize: 21, showIcon: true),
          if (currentPage < 2)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textSubtle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
