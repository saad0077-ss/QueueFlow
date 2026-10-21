import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/pages/sign_in_screen.dart';
import '../../../auth/presentation/pages/sign_up_screen.dart';

class OnboardingAuthButtons extends StatelessWidget {
  const OnboardingAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF0B1220),
              side: const BorderSide(
                color: Color(0xFF24324A),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
