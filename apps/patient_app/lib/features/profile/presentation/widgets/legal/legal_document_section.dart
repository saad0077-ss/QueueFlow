import 'package:flutter/material.dart';

class LegalHighlightBadge {
  final IconData icon;
  final String label;

  const LegalHighlightBadge({required this.icon, required this.label});
}

class LegalSectionItem {
  final String number;
  final String title;
  final String summary;
  final List<String> bullets;
  final IconData icon;
  final Color accent;

  const LegalSectionItem({
    required this.number,
    required this.title,
    required this.summary,
    required this.bullets,
    required this.icon,
    required this.accent,
  });
}

class LegalDocumentConfig {
  final String appBarTitle;
  final String appBarSubtitle;
  final String heroBadge;
  final String lastUpdated;
  final String heroTitle;
  final String heroDescription;
  final IconData heroIcon;
  final List<Color> heroGradient;
  final List<LegalHighlightBadge> highlights;
  final List<LegalSectionItem> sections;

  const LegalDocumentConfig({
    required this.appBarTitle,
    required this.appBarSubtitle,
    required this.heroBadge,
    required this.lastUpdated,
    required this.heroTitle,
    required this.heroDescription,
    required this.heroIcon,
    required this.heroGradient,
    required this.highlights,
    required this.sections,
  });
}
