import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EmailVerificationCard extends StatelessWidget {
  final String effectiveEmail;

  const EmailVerificationCard({
    super.key,
    required this.effectiveEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mail Icon Card
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
              Icons.mark_email_unread_rounded,
              size: 46,
              color: AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        const Text(
          'Verify your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 6),

        // Email pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            effectiveEmail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Click the link in the email to finish creating your account. Once verified, tap the button below.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
