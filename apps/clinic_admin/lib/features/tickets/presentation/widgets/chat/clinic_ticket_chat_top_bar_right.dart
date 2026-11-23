import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/repositories/clinic_support_repository.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_helpers.dart';

class ClinicTicketChatTopBarRight extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final ClinicSupportRepository repository;
  final String staffName;

  const ClinicTicketChatTopBarRight({
    super.key,
    required this.ticket,
    required this.repository,
    required this.staffName,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProg = ticket.status.toLowerCase() == 'in_progress';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Builder(
          builder: (_) {
            final countdown = ClinicTicketChatHelpers.formatSlaCountdown(
              ticket,
            );
            final isOverdue = countdown.contains('Overdue');
            final badgeColor = isResolved
                ? const Color(0xFF10B981)
                : (isOverdue
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF59E0B));
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
              ),
              child: Text(
                isResolved ? 'SLA Met' : 'Care Desk SLA: $countdown',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            );
          },
        ),
        if (!isResolved)
          OutlinedButton(
            onPressed: isInProg
                ? null
                : () => repository.updateStatus(
                    ticketId: ticket.id,
                    status: 'in_progress',
                  ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: Color(0xFFF59E0B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            ),
            child: Text(
              '⚡ ${isInProg ? "In Triage" : "Set Triage"}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFBBF24),
              ),
            ),
          ),
        InkWell(
          onTap: () => repository.updateStatus(
            ticketId: ticket.id,
            status: isResolved ? 'in_progress' : 'resolved',
            staffName: staffName,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isResolved
                  ? const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isResolved ? '↺ Reopen' : '✓ Mark Resolved',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: ticket.isEscalated
              ? null
              : () => repository.escalateTicket(
                  ticketId: ticket.id,
                  staffName: staffName,
                ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            side: const BorderSide(color: Color(0xFFEF4444)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF7F1D1D).withValues(alpha: 0.15),
          ),
          child: Text(
            ticket.isEscalated ? '🚨 Escalated' : '🚨 Escalate',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }
}
