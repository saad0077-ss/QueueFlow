import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_event.dart';
import '../bloc/sign_in/sign_in_state.dart';
import '../pages/forgot_password_screen.dart';

class SignInForm extends StatelessWidget {
  final SignInState state;
  final double labelSize;
  final double forgotPasswordSize;

  const SignInForm({
    super.key,
    required this.state,
    required this.labelSize,
    required this.forgotPasswordSize,
  });

  void _onSignInPressed(BuildContext context) {
    final email = state.email.trim();
    final password = state.password;
    if (email.isEmpty && password.isEmpty) {
      AppSnackBar.showWarning(
        context,
        title: 'Missing Details',
        message: 'Please enter your email and password.',
      );
      return;
    }
    if (email.isEmpty) {
      AppSnackBar.showWarning(
        context,
        title: 'Email Required',
        message: 'Please enter your email address.',
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      AppSnackBar.showWarning(
        context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
      );
      return;
    }
    if (password.isEmpty) {
      AppSnackBar.showWarning(
        context,
        title: 'Password Required',
        message: 'Please enter your password.',
      );
      return;
    }
    context.read<SignInBloc>().add(const SignInSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignInBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Email address',
          hintText: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          helperText: 'Enter a valid email address.',
          errorText: state.emailError,
          labelFontSize: labelSize,
          onChanged: (email) => bloc.add(SignInEmailChanged(email)),
        ),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: state.isPasswordObscured,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          labelFontSize: labelSize,
          onChanged: (pwd) => bloc.add(SignInPasswordChanged(pwd)),
          suffixIcon: IconButton(
            icon: Icon(
              state.isPasswordObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSubtle,
              size: 20,
            ),
            onPressed: () => bloc.add(const SignInTogglePasswordVisibility()),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordScreen(
                      initialEmail: state.email.trim().isNotEmpty
                          ? state.email.trim()
                          : null,
                    ),
                  ),
                );
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColors.textLink,
                  fontSize: forgotPasswordSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Sign In',
          isLoading: state.isLoading,
          onPressed: () => _onSignInPressed(context),
        ),
      ],
    );
  }
}
