import 'package:flutter/material.dart';

import '../bloc/sign_up/sign_up_state.dart';
import 'sign_up_footer.dart';
import 'sign_up_form.dart';
import 'sign_up_header.dart';

/// Reusable auth form container for Sign Up (Create Account) screen.
class SignUpCardBody extends StatelessWidget {
  final SignUpState state;
  final bool showThemeToggle;
  final bool showTopBar;

  const SignUpCardBody({
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
              const SignUpHeader(
                titleSize: 26,
                subtitleSize: 13.5,
              ),
              const SizedBox(height: 22),
              SignUpForm(state: state, labelSize: 13),
              const SizedBox(height: 20),
              const SignUpFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
