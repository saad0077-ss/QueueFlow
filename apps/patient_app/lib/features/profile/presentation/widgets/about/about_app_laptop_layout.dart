import 'package:flutter/material.dart';

/// Full-width showcase + highlights + balanced split layout on web/laptop (>= 960px).
class AboutAppLaptopLayout extends StatelessWidget {
  final Widget heroCard;
  final Widget highlightsGrid;
  final Widget howItWorksCard;
  final Widget infoCard;

  const AboutAppLaptopLayout({
    super.key,
    required this.heroCard,
    required this.highlightsGrid,
    required this.howItWorksCard,
    required this.infoCard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heroCard,
        const SizedBox(height: 20),
        highlightsGrid,
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 55, child: howItWorksCard),
            const SizedBox(width: 20),
            Expanded(flex: 45, child: infoCard),
          ],
        ),
      ],
    );
  }
}
