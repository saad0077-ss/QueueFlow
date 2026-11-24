import 'package:flutter/material.dart';

class ProfileLaptopLayout extends StatelessWidget {
  final Widget heroCard;
  final Widget statsStrip;
  final Widget healthChips;
  final Widget activityMenu;
  final Widget preferencesMenu;
  final Widget supportLegalMenu;
  final Widget accountMenu;

  const ProfileLaptopLayout({
    super.key,
    required this.heroCard,
    required this.statsStrip,
    required this.healthChips,
    required this.activityMenu,
    required this.preferencesMenu,
    required this.supportLegalMenu,
    required this.accountMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (flex: 38): Profile Identity, Stats & Health Chips
        Expanded(
          flex: 38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heroCard,
              const SizedBox(height: 12),
              statsStrip,
              const SizedBox(height: 12),
              healthChips,
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column (flex: 62): Activity, Preferences, Legal & Account
        Expanded(
          flex: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              activityMenu,
              preferencesMenu,
              supportLegalMenu,
              accountMenu,
            ],
          ),
        ),
      ],
    );
  }
}
