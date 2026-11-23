import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_card.dart';

class PlatformTicketsGrid extends StatelessWidget {
  final List<PlatformSupportTicketEntity> filteredTickets;
  final String? selectedTicketId;
  final ValueChanged<PlatformSupportTicketEntity> onSelectTicket;

  const PlatformTicketsGrid({
    super.key,
    required this.filteredTickets,
    required this.selectedTicketId,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    if (filteredTickets.isEmpty) {
      return Container(
        height: 380,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(
              'No platform tickets found',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No inquiries match the current filter query.',
              style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTickets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 154,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return PlatformTicketCard(
          ticket: ticket,
          isSelected: ticket.id == selectedTicketId,
          onTap: () => onSelectTicket(ticket),
        );
      },
    );
  }
}
