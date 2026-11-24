import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../pages/sign_in_screen.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: GestureDetector(
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          }
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: colors.textMuted, fontSize: 13),
            children: [
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: colors.accent,
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
