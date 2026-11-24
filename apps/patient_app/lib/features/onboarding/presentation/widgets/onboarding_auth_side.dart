import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_logo.dart';
import 'onboarding_auth_buttons.dart';

class OnboardingAuthSide extends StatelessWidget {
  const OnboardingAuthSide({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(fontSize: 28, showIcon: true),
              const SizedBox(height: 28),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1.0,
                    color: colors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Book smarter.\n'),
                    TextSpan(
                      text: 'Wait less.',
                      style: TextStyle(color: colors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Skip the waiting room. Book appointments and track your place in line, in real time.',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 16,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              _buildTrustPill(colors),
              const SizedBox(height: 22),
              _buildBenefitsList(colors),
              const SizedBox(height: 32),
              const OnboardingAuthButtons(maxWidth: 480),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustPill(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            'Verified Clinics & Real-time Live Radar',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(AppColorsExtension colors) {
    return Column(
      children: [
        _benefitItem(
          colors,
          Icons.schedule_rounded,
          'Save 45+ mins average per visit',
        ),
        const SizedBox(height: 12),
        _benefitItem(
          colors,
          Icons.sync_rounded,
          'Live sync across all your devices',
        ),
        const SizedBox(height: 12),
        _benefitItem(
          colors,
          Icons.shield_outlined,
          'Secure digital passes & payments',
        ),
      ],
    );
  }

  Widget _benefitItem(AppColorsExtension colors, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: colors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textSubtle,
            ),
          ),
        ),
      ],
    );
  }
}
