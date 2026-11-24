import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_logo.dart';
import '../widgets/onboarding_auth_buttons.dart';
import '../widgets/onboarding_laptop_view.dart';
import '../widgets/ticket_preview_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return const OnboardingLaptopView();
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 16, 4),
                      child: AppLogo(fontSize: 21, showIcon: true),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            const TicketPreviewCard(),
                            const SizedBox(height: 38),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Book smarter.\n',
                                    style: TextStyle(color: colors.textPrimary),
                                  ),
                                  TextSpan(
                                    text: 'Wait less.',
                                    style: TextStyle(color: colors.accent),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Skip the waiting room. Book appointments\nand track your place in line, in real time.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Verified Clinics & Real-time Live Radar',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textSubtle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: OnboardingAuthButtons(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
