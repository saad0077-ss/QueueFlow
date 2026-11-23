import 'package:flutter/material.dart';
import '../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_card.dart';
import 'clinic_tickets_empty_state.dart';

class ClinicTicketsGrid extends StatelessWidget {
  final List<ClinicSupportTicketEntity> tickets;
  final String? selectedTicketId;
  final ValueChanged<String> onSelectTicket;

  const ClinicTicketsGrid({
    super.key,
    required this.tickets,
    required this.selectedTicketId,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const ClinicTicketsEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 154,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return ClinicTicketCard(
          ticket: ticket,
          isSelected: ticket.id == selectedTicketId,
          onTap: () => onSelectTicket(ticket.id),
        );
      },
    );
  }
}
