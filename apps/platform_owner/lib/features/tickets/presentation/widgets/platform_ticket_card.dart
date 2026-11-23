import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';
import 'card/platform_ticket_card_footer.dart';
import 'card/platform_ticket_card_header.dart';
import 'card/platform_ticket_card_patient_row.dart';
import 'card/platform_ticket_card_style_helper.dart';

class PlatformTicketCard extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final bool isSelected;
  final VoidCallback onTap;

  const PlatformTicketCard({
    super.key,
    required this.ticket,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final accentColor = PlatformTicketCardStyleHelper.getAccentColor(ticket);

    final initials = ticket.patientName.isNotEmpty
        ? ticket.patientName
              .split(' ')
              .map((p) => p.isNotEmpty ? p[0] : '')
              .take(2)
              .join('')
              .toUpperCase()
        : 'PT';

    final cardBg = isSelected
        ? (isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.7)
              : const Color(0xFFEFF6FF))
        : colors.surface;
    final cardBorderColor = isSelected
        ? const Color(0xFF2563EB)
        : colors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB)
                        .withValues(alpha: isDark ? 0.2 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.5, color: accentColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlatformTicketCardHeader(ticket: ticket),
                        const SizedBox(height: 8),
                        PlatformTicketCardPatientRow(
                          ticket: ticket,
                          initials: initials,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.subject,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ticket.description,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        PlatformTicketCardFooter(ticket: ticket),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
