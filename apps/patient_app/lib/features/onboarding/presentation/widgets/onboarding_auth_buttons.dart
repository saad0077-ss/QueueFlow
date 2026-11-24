import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/pages/sign_in_screen.dart';
import '../../../auth/presentation/pages/sign_up_screen.dart';

class OnboardingAuthButtons extends StatelessWidget {
  final double maxWidth;

  const OnboardingAuthButtons({
    super.key,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientButton(
              text: 'Create account',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  backgroundColor: colors.surface,
                  side: BorderSide(color: colors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
