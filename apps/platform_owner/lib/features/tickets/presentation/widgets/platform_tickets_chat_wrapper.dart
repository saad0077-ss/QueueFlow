import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/repositories/platform_support_repository.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_chat_console.dart';

class PlatformTicketsChatWrapper extends StatelessWidget {
  final PlatformSupportTicketEntity selectedTicket;
  final PlatformSupportRepository repository;
  final VoidCallback onBackToGrid;
  final VoidCallback onTicketDeleted;

  const PlatformTicketsChatWrapper({
    super.key,
    required this.selectedTicket,
    required this.repository,
    required this.onBackToGrid,
    required this.onTicketDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final chatHeight = (MediaQuery.of(context).size.height - 180).clamp(
      780.0,
      1100.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onBackToGrid,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: Color(0xFF60A5FA),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Platform Tickets Grid',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Text(
                'Viewing Ticket #${selectedTicket.ticketNumber} • ${selectedTicket.patientName}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: chatHeight,
          child: PlatformTicketChatConsole(
            key: ValueKey(selectedTicket.id),
            initialTicket: selectedTicket,
            repository: repository,
            adminName: 'Platform Admin',
            onTicketDeleted: onTicketDeleted,
          ),
        ),
      ],
    );
  }
}
