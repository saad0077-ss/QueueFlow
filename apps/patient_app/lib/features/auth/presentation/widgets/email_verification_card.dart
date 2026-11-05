import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class EmailVerificationCard extends StatelessWidget {
  final String effectiveEmail;

  const EmailVerificationCard({
    super.key,
    required this.effectiveEmail,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Mail Icon Card
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
              Icons.mark_email_unread_rounded,
              size: 46,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        Text(
          'Verify your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          'We sent a verification link to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 6),

        // Email pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            effectiveEmail,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Click the link in the email to finish creating your account. Once verified, tap the button below.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSubtle,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
