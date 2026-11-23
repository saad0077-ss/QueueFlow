import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_card_badge_helper.dart';

class PlatformTicketCardFooter extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;

  const PlatformTicketCardFooter({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (catBg, catText) = PlatformTicketCardBadgeHelper.getCategoryStyle(
      context,
      ticket,
    );
    final (statusBg, statusTextColor, statusLabel) =
        PlatformTicketCardBadgeHelper.getStatusStyle(context, ticket);
    final isClinicAssigned =
        ticket.assignedTo != null &&
        ticket.assignedTo!.toLowerCase().contains("clinic");
    final assignedText = isClinicAssigned ? "Clinic Admin" : "Platform Admin";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        Text(
          'Assigned: $assignedText',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
