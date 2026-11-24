import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/auth_back_header.dart';
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
                const SizedBox(height: 24),
              ],
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
