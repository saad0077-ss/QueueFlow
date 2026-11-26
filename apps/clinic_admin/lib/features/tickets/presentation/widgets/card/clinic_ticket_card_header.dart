import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_card_style_helper.dart';

class ClinicTicketCardHeader extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;

  const ClinicTicketCardHeader({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final isAppRelated = ClinicTicketCardStyleHelper.isTicketAppRelated(ticket);

    final badgeIcon = isAppRelated ? '📱' : '🏥';
    final badgeText = isAppRelated
        ? 'QueueFlow App'
        : (ticket.clinicName.isNotEmpty ? ticket.clinicName : 'Clinic');
    final badgeBg = isAppRelated
        ? (isDark
              ? const Color(0xFF0C4A6E).withValues(alpha: 0.55)
              : const Color(0xFFE0F2FE))
        : (isDark
              ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
              : const Color(0xFFEEF2FF));
    final badgeBorder = isAppRelated
        ? (isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.45)
              : const Color(0xFFBAE6FD))
        : (isDark
              ? const Color(0xFF4338CA).withValues(alpha: 0.4)
              : const Color(0xFFC7D2FE));
    final badgeTextColor = isAppRelated
        ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
        : (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                ticket.ticketNumber,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3B82F6),
                ),
              ),
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
                      constraints: const BoxConstraints(maxWidth: 118),
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
              if (ticket.linkedTokenNumber != null &&
                  ticket.linkedTokenNumber!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4338CA).withValues(alpha: 0.4)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎟', style: TextStyle(fontSize: 9.5)),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          'Token #${ticket.linkedTokenNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ClinicTicketCardStyleHelper.formatTimeAgo(ticket),
          style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted),
        ),
      ],
    );
  }
}
