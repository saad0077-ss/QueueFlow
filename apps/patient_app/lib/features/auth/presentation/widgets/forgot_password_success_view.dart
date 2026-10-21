import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';

class ForgotPasswordSuccessView extends StatelessWidget {
  final String sentEmail;
  final int resendCooldown;
  final bool isLoading;
  final VoidCallback onResend;
  final VoidCallback onUseDifferentEmail;

  const ForgotPasswordSuccessView({
    super.key,
    required this.sentEmail,
    required this.resendCooldown,
    required this.isLoading,
    required this.onResend,
    required this.onUseDifferentEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        // Mail Sent Icon Card
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF334155),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 46,
              color: AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        const Text(
          'Password reset link sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          'We have sent a password reset link to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 8),

        // Email pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            sentEmail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Please open your email client and follow the instructions to set up a new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),

        // Primary Button: Back to Sign In
        GradientButton(
          text: 'Back to Sign In',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),

        // Resend option
        TextButton.icon(
          onPressed: (resendCooldown > 0 || isLoading) ? null : onResend,
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryLight,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: resendCooldown > 0
                      ? const Color(0xFF64748B)
                      : AppColors.primaryLight,
                ),
          label: Text(
            resendCooldown > 0
                ? 'Resend email in ${resendCooldown}s'
                : 'Resend reset email',
            style: TextStyle(
              color: resendCooldown > 0
                  ? const Color(0xFF64748B)
                  : AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Switch email
        GestureDetector(
          onTap: onUseDifferentEmail,
          child: const Text(
            'Use a different email address',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
