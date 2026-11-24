import 'package:flutter/material.dart';

import '../bloc/sign_in/sign_in_state.dart';
import 'sign_in_footer.dart';
import 'sign_in_form.dart';
import 'sign_in_header.dart';

/// Reusable auth form container for Sign In screen.
class SignInCardBody extends StatelessWidget {
  final SignInState state;
  final bool showThemeToggle;
  final bool showTopBar;

  const SignInCardBody({
    super.key,
    required this.state,
    this.showThemeToggle = false,
    this.showTopBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SignInHeader(
                titleSize: 26,
                subtitleSize: 13.5,
              ),
              const SizedBox(height: 28),
              SignInForm(
                state: state,
                labelSize: 13,
                forgotPasswordSize: 12.5,
              ),
              const SizedBox(height: 22),
              const SignInFooter(
                dividerTextSize: 12,
                bottomLinkSize: 13,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
