import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/gradient_button.dart';

class ForgotPasswordSuccessView extends StatelessWidget {
  final String sentEmail;
  final int resendCooldown;
  final bool isLoading;
  final VoidCallback onResend;
  final VoidCallback? onUseDifferentEmail;
  final double scale;

  const ForgotPasswordSuccessView({
    super.key,
    required this.sentEmail,
    required this.resendCooldown,
    this.isLoading = false,
    required this.onResend,
    this.onUseDifferentEmail,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            color: colors.primaryTint,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 46,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        Text(
          'Password reset link sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
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
            color: colors.textMuted,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 8),

        // Email pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            sentEmail,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'Please open your email client and follow the instructions to set up a new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSubtle,
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
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: resendCooldown > 0
                      ? colors.textSubtle
                      : colors.primary,
                ),
          label: Text(
            resendCooldown > 0
                ? 'Resend email in ${resendCooldown}s'
                : 'Resend reset email',
            style: TextStyle(
              color: resendCooldown > 0
                  ? colors.textSubtle
                  : colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (onUseDifferentEmail != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onUseDifferentEmail,
            child: Text(
              'Use a different email address',
              style: TextStyle(
                color: colors.accent,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
