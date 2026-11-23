import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'platform_tickets_selectable_card.dart';

class PlatformTicketsFilterSlaSection extends StatelessWidget {
  final String selectedSla;
  final ValueChanged<String> onSelectSla;

  const PlatformTicketsFilterSlaSection({
    super.key,
    required this.selectedSla,
    required this.onSelectSla,
  });

  @override
  Widget build(BuildContext context) {
    final slaOptions = [
      {'id': 'all', 'title': '⚡ All SLA', 'sub': 'Any urgency'},
      {'id': 'urgent', 'title': '🔴 At-Risk SLA', 'sub': '< 15 min left'},
      {'id': 'high', 'title': '▲ High Priority', 'sub': 'Elevated focus'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slaOptions.map((opt) {
            final isSel = selectedSla == opt['id'];
            return SizedBox(
              width: itemWidth,
              child: PlatformTicketsSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectSla(opt['id']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        color: isSel ? const Color(0xFF60A5FA) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opt['sub']!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isSel
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
