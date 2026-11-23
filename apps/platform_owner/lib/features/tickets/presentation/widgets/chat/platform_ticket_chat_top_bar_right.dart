import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import '../../../domain/repositories/platform_support_repository.dart';
import 'platform_ticket_chat_sla_badge.dart';

class PlatformTicketChatTopBarRight extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final PlatformSupportRepository repository;
  final VoidCallback onDelete;

  const PlatformTicketChatTopBarRight({
    super.key,
    required this.ticket,
    required this.repository,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProgress = ticket.status.toLowerCase() == 'in_progress';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PlatformTicketChatSlaBadge(ticket: ticket),
        if (!isResolved)
          OutlinedButton(
            onPressed: isInProgress
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 10.5)),
                const SizedBox(width: 4),
                Text(
                  isInProgress ? 'In-Progress' : 'Set In-Progress',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
          ),
        InkWell(
          onTap: () {
            repository.updateStatus(
              ticketId: ticket.id,
              status: isResolved ? 'in_progress' : 'resolved',
              staffName: 'Platform Admin',
            );
          },
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
              boxShadow: [
                BoxShadow(
                  color:
                      (isResolved
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF10B981))
                          .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isResolved
                      ? Icons.refresh_rounded
                      : Icons.check_circle_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  isResolved ? 'Reopen Ticket' : 'Mark Resolved',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 15,
              color: Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }
}
