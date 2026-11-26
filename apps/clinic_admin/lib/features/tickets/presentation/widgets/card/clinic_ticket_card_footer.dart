import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_card_badge_helper.dart';

class ClinicTicketCardFooter extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;

  const ClinicTicketCardFooter({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    final (
      statusBg,
      statusTextColor,
      statusLabel,
    ) = ClinicTicketCardBadgeHelper.getStatusStyle(
      ticket: ticket,
      isDark: isDark,
    );

    final (catBg, catText) = ClinicTicketCardBadgeHelper.getCategoryStyle(
      ticket: ticket,
      isDark: isDark,
    );

    final assignedName =
        (ticket.assignedTo != null &&
            ticket.assignedTo!.toLowerCase().contains('platform'))
        ? 'Platform Admin'
        : 'Clinic Admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: catBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: catText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Assigned: $assignedName',
                style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
