import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';

class ConcernDetailRatingCard extends StatelessWidget {
  final SupportTicketEntity ticket;
  final ValueChanged<int> onRate;

  const ConcernDetailRatingCard({
    super.key,
    required this.ticket,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentRating = ticket.rating ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Rate Resolution Quality:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (idx) {
              final star = idx + 1;
              final isFilled = star <= currentRating;

              return InkWell(
                onTap: () => onRate(star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 24,
                    color: isFilled
                        ? const Color(0xFFF59E0B)
                        : colors.textMuted,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
