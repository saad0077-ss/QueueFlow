import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';

class ForgotPasswordFormView extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;
  final TextEditingController emailController;
  final String? emailError;
  final bool isLoading;
  final VoidCallback onSendResetLink;
  final ValueChanged<String>? onEmailChanged;

  const ForgotPasswordFormView({
    super.key,
    required this.titleSize,
    required this.subtitleSize,
    required this.emailController,
    required this.emailError,
    required this.isLoading,
    required this.onSendResetLink,
    this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBackHeader(),
          const SizedBox(height: 32),

          // Title
          Text(
            'Forgot password?',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'Enter your registered email address and we will send you a link to reset your password.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: subtitleSize,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Email Field
          CustomTextField(
            label: 'Email address',
            hintText: 'you@example.com',
            controller: emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            helperText: 'We will send a password reset link to this address.',
            errorText: emailError,
            onChanged: onEmailChanged,
            onFieldSubmitted: (_) => onSendResetLink(),
          ),

          const Spacer(),

          // Bottom Action
          GradientButton(
            text: 'Send Reset Link',
            isLoading: isLoading,
            onPressed: onSendResetLink,
          ),
          const SizedBox(height: 18),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: RichText(
                text: const TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
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
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
