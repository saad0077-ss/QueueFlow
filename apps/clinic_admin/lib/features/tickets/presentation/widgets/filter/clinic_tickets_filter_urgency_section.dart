import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clinic_tickets_filter_card_item.dart';

class ClinicTicketsFilterUrgencySection extends StatelessWidget {
  final String selectedUrgency;
  final ValueChanged<String> onSelectUrgency;

  const ClinicTicketsFilterUrgencySection({
    super.key,
    required this.selectedUrgency,
    required this.onSelectUrgency,
  });

  static const urgencies = [
    {'id': 'all', 'title': '⚡ All Priority', 'sub': 'Any urgency level'},
    {
      'id': 'urgent',
      'title': '🔴 At-Risk / Urgent',
      'sub': 'Delay > 15m in lobby',
    },
    {'id': 'high', 'title': '▲ High Priority', 'sub': 'Doctor triage focus'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: urgencies.map((u) {
            final isSel = selectedUrgency == u['id'];
            return SizedBox(
              width: itemWidth,
              child: ClinicTicketsFilterCardItem(
                isSelected: isSel,
                onTap: () => onSelectUrgency(u['id']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u['title']!,
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
                      u['sub']!,
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
