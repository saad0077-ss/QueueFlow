import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';

class HelpSupportConcernCardHeader extends StatelessWidget {
  final SupportTicketEntity ticket;
  final Color prioColor;
  final String prioText;
  final Color statusColor;
  final String statusText;

  const HelpSupportConcernCardHeader({
    super.key,
    required this.ticket,
    required this.prioColor,
    required this.prioText,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            ticket.ticketNumber,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: prioColor.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            prioText,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: prioColor,
            ),
          ),
        ),
        if (ticket.linkedTokenNumber != null &&
            ticket.linkedTokenNumber!.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0072FF).withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Token ${ticket.linkedTokenNumber!}',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0072FF),
              ),
            ),
          ),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
