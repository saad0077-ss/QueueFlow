import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clinic_tickets_filter_card_item.dart';

class ClinicTicketsFilterCategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const ClinicTicketsFilterCategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const categories = [
    {
      'id': 'all',
      'title': '📋 All Categories',
      'sub': 'Complete inbox',
      'tag': 'ALL',
      'color': Color(0xFF94A3B8),
    },
    {
      'id': 'queue',
      'title': '🎟️ Queue / Delay',
      'sub': 'Waiting room flow',
      'tag': 'QUEUE',
      'color': Color(0xFF2DD4BF),
    },
    {
      'id': 'booking',
      'title': '📅 Booking & Reschedule',
      'sub': 'Time slots & visits',
      'tag': 'APPT',
      'color': Color(0xFF60A5FA),
    },
    {
      'id': 'billing',
      'title': '💳 Billing & Receipt',
      'sub': 'Invoices & charges',
      'tag': 'BILL',
      'color': Color(0xFFA5B4FC),
    },
    {
      'id': 'doctor',
      'title': '🩺 Doctor & Care',
      'sub': 'Consultation & care',
      'tag': 'DOC',
      'color': Color(0xFF38BDF8),
    },
    {
      'id': 'general',
      'title': '💬 General Feedback',
      'sub': 'Patient remarks',
      'tag': 'GEN',
      'color': Color(0xFFFBBF24),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final colCount = isNarrow ? 2 : 3;
        final itemWidth =
            (constraints.maxWidth - ((colCount - 1) * 10)) / colCount;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((c) {
            final isSel = selectedCategory == c['id'];
            final tagColor = c['color'] as Color;
            return SizedBox(
              width: itemWidth,
              child: ClinicTicketsFilterCardItem(
                isSelected: isSel,
                onTap: () => onSelectCategory(c['id'] as String),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSel
                                  ? const Color(0xFF60A5FA)
                                  : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c['tag'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: tagColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c['sub'] as String,
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
