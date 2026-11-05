import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_event.dart';
import '../pages/sign_up_screen.dart';

class SignInFooter extends StatelessWidget {
  final double dividerTextSize;
  final double bottomLinkSize;

  const SignInFooter({
    super.key,
    required this.dividerTextSize,
    required this.bottomLinkSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colors.border,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: colors.textSubtle,
                  fontSize: dividerTextSize,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colors.border,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GoogleSignInButton(
          onPressed: () => context
              .read<SignInBloc>()
              .add(const SignInWithGoogleSubmitted()),
        ),
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SignUpScreen(),
              ),
            ),
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: bottomLinkSize,
                ),
                children: [
                  TextSpan(
                    text: 'Create one',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: bottomLinkSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
