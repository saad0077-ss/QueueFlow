import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/auth_back_header.dart';
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
    this.showThemeToggle = true,
    this.showTopBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showTopBar) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AuthBackHeader(),
                    if (showThemeToggle)
                      IconButton(
                        tooltip: isDark ? 'Light mode' : 'Dark mode',
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: colors.textSubtle,
                          size: 20,
                        ),
                        onPressed: () {
                          context
                              .read<ThemeBloc>()
                              .add(const ThemeToggleRequested());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
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
