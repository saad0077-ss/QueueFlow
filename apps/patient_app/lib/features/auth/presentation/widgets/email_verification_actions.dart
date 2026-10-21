import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
                : 'Resend Verification Email',
            style: TextStyle(
              color: resendCooldown > 0
                  ? const Color(0xFF64748B)
                  : AppColors.primaryLight,
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
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13.5,
              ),
            ),
            GestureDetector(
              onTap: onSignOutAndSwitch,
              child: const Text(
                'Sign in with another account',
                style: TextStyle(
                  color: AppColors.primaryLight,
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
