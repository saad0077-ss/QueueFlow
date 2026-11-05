import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';

class ForgotPasswordFormView extends StatelessWidget {
  final double? titleSize;
  final double? subtitleSize;
  final double? scale;
  final TextEditingController? controller;
  final TextEditingController? emailController;
  final String? errorText;
  final String? emailError;
  final bool isLoading;
  final VoidCallback? onSubmit;
  final VoidCallback? onSendResetLink;
  final ValueChanged<String>? onEmailChanged;

  const ForgotPasswordFormView({
    super.key,
    this.titleSize,
    this.subtitleSize,
    this.scale,
    this.controller,
    this.emailController,
    this.errorText,
    this.emailError,
    this.isLoading = false,
    this.onSubmit,
    this.onSendResetLink,
    this.onEmailChanged,
  });

  TextEditingController get _effectiveController =>
      controller ?? emailController ?? TextEditingController();

  String? get _effectiveError => errorText ?? emailError;

  VoidCallback? get _effectiveSubmit => onSubmit ?? onSendResetLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sc = scale ?? 1.0;
    final tSize = titleSize ?? (26.0 * sc).clamp(22.0, 30.0);
    final sSize = subtitleSize ?? (13.5 * sc).clamp(12.0, 15.0);

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
              color: colors.textPrimary,
              fontSize: tSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'Enter your registered email address and we will send you a link to reset your password.',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: sSize,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Email Field
          CustomTextField(
            label: 'Email address',
            hintText: 'you@example.com',
            controller: _effectiveController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            helperText: 'We will send a password reset link to this address.',
            errorText: _effectiveError,
            onChanged: onEmailChanged,
            onFieldSubmitted: (_) => _effectiveSubmit?.call(),
          ),

          const Spacer(),

          // Bottom Action
          GradientButton(
            text: 'Send Reset Link',
            isLoading: isLoading,
            onPressed: _effectiveSubmit,
          ),
          const SizedBox(height: 18),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: RichText(
                text: TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13.5,
                  ),
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
