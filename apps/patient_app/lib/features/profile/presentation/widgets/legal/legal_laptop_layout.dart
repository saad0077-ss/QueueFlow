import 'package:flutter/material.dart';

import 'legal_document_hero.dart';
import 'legal_document_section.dart';
import 'legal_section_card.dart';
import 'legal_sections_index_card.dart';

/// Two-column responsive layout used on laptop screens (>= 960px) for legal pages.
class LegalLaptopLayout extends StatelessWidget {
  final LegalDocumentConfig config;
  final Set<int> expanded;
  final ValueChanged<int> onToggleSection;

  const LegalLaptopLayout({
    super.key,
    required this.config,
    required this.expanded,
    required this.onToggleSection,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LegalDocumentHero(config: config),
              const SizedBox(height: 16),
              LegalSectionsIndexCard(
                sections: config.sections,
                expanded: expanded,
                onSectionTap: onToggleSection,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < config.sections.length; i++)
                LegalSectionCard(
                  section: config.sections[i],
                  isExpanded: expanded.contains(i),
                  onToggle: () => onToggleSection(i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
