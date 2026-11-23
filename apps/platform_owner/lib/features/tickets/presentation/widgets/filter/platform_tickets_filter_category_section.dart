import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'platform_tickets_selectable_card.dart';

class PlatformTicketsFilterCategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const PlatformTicketsFilterCategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final catOptions = [
      {'id': 'all', 'title': 'All Categories', 'sub': 'Show all types'},
      {'id': 'queue', 'title': '🎟 Queue & Tokens', 'sub': 'Delays & calls'},
      {'id': 'booking', 'title': '📅 Appointments', 'sub': 'Reschedules'},
      {'id': 'billing', 'title': '💳 Billing', 'sub': 'Payments & plans'},
      {
        'id': 'technical',
        'title': '🛠 Technical Bug',
        'sub': 'App sync / errors',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final colCount = isNarrow ? 2 : 3;
        final itemWidth =
            (constraints.maxWidth - ((colCount - 1) * 10)) / colCount;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: catOptions.map((cat) {
            final isSel = selectedCategory == cat['id'];
            return SizedBox(
              width: itemWidth,
              child: PlatformTicketsSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectCategory(cat['id']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        color: isSel ? const Color(0xFF60A5FA) : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat['sub']!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isSel
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
