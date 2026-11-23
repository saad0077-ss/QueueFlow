import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/repositories/platform_support_repository.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_card.dart';
import 'platform_tickets_chat_wrapper.dart';

class PlatformTicketsSplitView extends StatefulWidget {
  final List<PlatformSupportTicketEntity> filteredTickets;
  final String? selectedTicketId;
  final ValueChanged<String?> onSelectTicket;
  final PlatformSupportRepository repository;
  final VoidCallback onTicketDeleted;

  const PlatformTicketsSplitView({
    super.key,
    required this.filteredTickets,
    required this.selectedTicketId,
    required this.onSelectTicket,
    required this.repository,
    required this.onTicketDeleted,
  });

  @override
  State<PlatformTicketsSplitView> createState() =>
      _PlatformTicketsSplitViewState();
}

class _PlatformTicketsSplitViewState extends State<PlatformTicketsSplitView> {
  bool _isViewingChat = false;

  @override
  Widget build(BuildContext context) {
    if (widget.filteredTickets.isEmpty) {
      return Container(
        height: 380,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No inquiries match the current filter query.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    PlatformSupportTicketEntity? selectedTicket;
    for (final t in widget.filteredTickets) {
      if (t.id == widget.selectedTicketId) {
        selectedTicket = t;
        break;
      }
    }
    selectedTicket ??= widget.filteredTickets.first;

    if (_isViewingChat) {
      return PlatformTicketsChatWrapper(
        selectedTicket: selectedTicket,
        repository: widget.repository,
        onBackToGrid: () => setState(() => _isViewingChat = false),
        onTicketDeleted: () {
          setState(() => _isViewingChat = false);
          widget.onTicketDeleted();
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.filteredTickets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 200,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final t = widget.filteredTickets[index];
        return PlatformTicketCard(
          ticket: t,
          isSelected: t.id == widget.selectedTicketId,
          onTap: () {
            widget.onSelectTicket(t.id);
            setState(() => _isViewingChat = true);
          },
        );
      },
    );
  }
}
