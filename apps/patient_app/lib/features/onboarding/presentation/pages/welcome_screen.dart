import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_logo.dart';
import '../widgets/onboarding_auth_buttons.dart';
import '../widgets/ticket_preview_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 12, bottom: 4),
              child: AppLogo(fontSize: 21, showIcon: true),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TicketPreviewCard(),
                    const SizedBox(height: 46),
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
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: OnboardingAuthButtons(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
