import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/gradient_button.dart';

class EmailVerificationActions extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onCheckStatus;
  final int resendCooldown;
  final bool isResending;
  final VoidCallback onResend;
  final VoidCallback onSignOutAndSwitch;

  const EmailVerificationActions({
    super.key,
    required this.isChecking,
    required this.onCheckStatus,
    required this.resendCooldown,
    required this.isResending,
    required this.onResend,
    required this.onSignOutAndSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Primary Button: "I've Verified My Email"
        GradientButton(
          text: "I've Verified My Email",
          isLoading: isChecking,
          onPressed: onCheckStatus,
        ),
        const SizedBox(height: 16),

        // Secondary Action: Resend with cooldown
        TextButton.icon(
          onPressed: (resendCooldown > 0 || isResending) ? null : onResend,
          icon: isResending
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
                : 'Resend Verification Email',
            style: TextStyle(
              color: resendCooldown > 0
                  ? colors.textSubtle
                  : colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Switch / Sign out option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Wrong email? ',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13.5,
              ),
            ),
            GestureDetector(
              onTap: onSignOutAndSwitch,
              child: Text(
                'Sign in with another account',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
