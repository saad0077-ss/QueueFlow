import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// Helper box shown when an email is already registered during account activation.
class ExistingAccountNotice extends StatelessWidget {
  final String email;

  const ExistingAccountNotice({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.infoTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colors.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Email already registered in system',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This email already has a password. Enter your existing password above, or click below to receive a password reset link.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.mail_lock_rounded,
              size: 15,
              color: colors.info,
            ),
            label: Text(
              'Send Password Reset Email',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: colors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'Password reset link sent to $email!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.showError(
                    context,
                    message: 'Failed to send reset email: $e',
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
