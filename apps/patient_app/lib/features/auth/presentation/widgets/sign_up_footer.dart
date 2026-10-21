import 'package:flutter/material.dart';
import '../pages/sign_in_screen.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const SignInScreen(),
              ),
            );
          }
        },
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account ? ',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
            children: [
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
