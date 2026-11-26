import 'package:flutter/material.dart';

/// Two-column responsive layout used on laptop screens (>= 960px) for About App.
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heroCard,
              const SizedBox(height: 18),
              infoCard,
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              highlightsGrid,
              const SizedBox(height: 18),
              howItWorksCard,
            ],
          ),
        ),
      ],
    );
  }
}
