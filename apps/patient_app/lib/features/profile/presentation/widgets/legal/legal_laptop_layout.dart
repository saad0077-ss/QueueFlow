import 'package:flutter/material.dart';

import 'legal_document_hero.dart';
import 'legal_document_section.dart';
import 'legal_section_card.dart';
import 'legal_sections_index_card.dart';

/// Full-width banner + 2-column Bento grid layout used on web/laptop (>= 960px).
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
    final sections = config.sections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LegalDocumentHero(config: config, isWide: true),
        const SizedBox(height: 16),
        LegalSectionsIndexCard(
          sections: sections,
          expanded: expanded,
          onSectionTap: onToggleSection,
          isHorizontal: true,
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < sections.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LegalSectionCard(
                  section: sections[i],
                  isExpanded: expanded.contains(i),
                  onToggle: () => onToggleSection(i),
                  inGrid: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < sections.length
                    ? LegalSectionCard(
                        section: sections[i + 1],
                        isExpanded: expanded.contains(i + 1),
                        onToggle: () => onToggleSection(i + 1),
                        inGrid: true,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
