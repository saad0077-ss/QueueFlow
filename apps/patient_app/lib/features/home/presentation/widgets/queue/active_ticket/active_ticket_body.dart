import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../domain/entities/active_ticket_entity.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../radar/live_pulsing_dot.dart';
import 'active_ticket_actions.dart';
import 'active_ticket_hero_card.dart';
import 'active_ticket_timeline.dart';

class ActiveTicketBody extends StatelessWidget {
  final ActiveTicketEntity ticket;
  final List<ClinicEntity> allClinics;
  final VoidCallback onCancelSpot;
  final ValueChanged<ClinicEntity> onGetDirections;

  const ActiveTicketBody({
    super.key,
    required this.ticket,
    required this.allClinics,
    required this.onCancelSpot,
    required this.onGetDirections,
  });

  ClinicEntity get _associatedClinic {
    final match = allClinics.where((c) => c.id == ticket.clinicId).firstOrNull;
    if (match != null) return match;
    return ClinicEntity(
      id: ticket.clinicId,
      name: ticket.clinicName,
      initials: ticket.clinicName.isNotEmpty
          ? ticket.clinicName.substring(0, 1)
          : 'C',
      category: ticket.serviceName,
      rating: 4.8,
      reviewCount: 120,
      distance: '',
      city: 'Kochi',
      address: '14 MG Road, Palarivattom, Kochi, Kerala',
      phone: '+91 98460 12345',
      consultationFee: '₹100',
      openingHours: '09:00 AM - 08:00 PM',
      currentToken: ticket.nowServing,
      waitingCount: ticket.position,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActiveTicketHeroCard(ticket: ticket),
        const SizedBox(height: 24),
        Text(
          'Queue status',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 18),
        ActiveTicketTimeline(ticket: ticket),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LivePulsingDot(),
            const SizedBox(width: 8),
            Text(
              'Updates automatically in real time',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ActiveTicketActions(
          onGetDirections: () => onGetDirections(_associatedClinic),
          onCancelSpot: onCancelSpot,
        ),
      ],
    );
  }
}
