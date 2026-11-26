import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../widgets/about/about_app_header.dart';
import '../widgets/about/about_app_hero_card.dart';
import '../widgets/about/about_app_highlights_grid.dart';
import '../widgets/about/about_app_how_it_works_card.dart';
import '../widgets/about/about_app_info_card.dart';
import '../widgets/about/about_app_laptop_layout.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutAppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AboutAppHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLaptop = constraints.maxWidth >= 960;
                  final isTablet = constraints.maxWidth >= 700;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLaptop ? 32 : (isTablet ? 24 : 16),
                      vertical: isLaptop ? 24 : 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLaptop ? 1240 : 720,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isLaptop)
                              const AboutAppLaptopLayout(
                                heroCard: AboutAppHeroCard(),
                                highlightsGrid: AboutAppHighlightsGrid(),
                                howItWorksCard: AboutAppHowItWorksCard(),
                                infoCard: AboutAppInfoCard(),
                              )
                            else ...[
                              const AboutAppHeroCard(),
                              const SizedBox(height: 18),
                              const AboutAppHighlightsGrid(),
                              const SizedBox(height: 18),
                              const AboutAppHowItWorksCard(),
                              const SizedBox(height: 18),
                              const AboutAppInfoCard(),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              '© 2026 QueueFlow Health · Made for stress-free visits',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: colors.textSubtle,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
