import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_card_badge_helper.dart';
import 'platform_ticket_card_style_helper.dart';

class PlatformTicketCardHeader extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;

  const PlatformTicketCardHeader({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (badgeIcon, badgeText, badgeBg, badgeBorder, badgeTextColor) =
        PlatformTicketCardBadgeHelper.getSourceBadgeStyle(context, ticket);
    final timeAgo = PlatformTicketCardStyleHelper.formatTimeAgo(ticket);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              ticket.ticketNumber,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(badgeIcon, style: const TextStyle(fontSize: 9.5)),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          timeAgo,
          style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted),
        ),
      ],
    );
  }
}
