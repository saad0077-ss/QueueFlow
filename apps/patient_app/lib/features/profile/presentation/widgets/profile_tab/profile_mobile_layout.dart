import 'package:flutter/material.dart';

class ProfileMobileLayout extends StatelessWidget {
  final Widget heroCard;
  final Widget statsStrip;
  final Widget healthChips;
  final Widget activityMenu;
  final Widget preferencesMenu;
  final Widget supportLegalMenu;
  final Widget accountMenu;

  const ProfileMobileLayout({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heroCard,
        statsStrip,
        healthChips,
        activityMenu,
        preferencesMenu,
        supportLegalMenu,
        accountMenu,
      ],
    );
  }
}
