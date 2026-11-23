import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketSpotlightDetails extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;

  const PlatformTicketSpotlightDetails({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                ticket.patientName,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.verified_rounded,
              size: 13,
              color: Color(0xFF38BDF8),
            ),
            if (ticket.linkedTokenNumber != null &&
                ticket.linkedTokenNumber!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4338CA).withValues(alpha: 0.25)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                        : const Color(0xFFC7D2FE),
                  ),
                ),
                child: Text(
                  '🎟️ Token ${ticket.linkedTokenNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF4338CA),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_rounded, size: 10.5, color: colors.textMuted),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    ticket.patientPhone.isNotEmpty
                        ? ticket.patientPhone
                        : 'No phone',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: 10.5, color: colors.textMuted),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    ticket.patientEmail.isNotEmpty
                        ? ticket.patientEmail
                        : 'No email',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          ticket.subject,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Category: ${ticket.category.toUpperCase()} • Submitted ${ticket.createdAt} • Assigned to ${(ticket.assignedTo != null && ticket.assignedTo!.toLowerCase().contains("clinic")) ? "Clinic Admin" : "Platform Admin"}',
          style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
