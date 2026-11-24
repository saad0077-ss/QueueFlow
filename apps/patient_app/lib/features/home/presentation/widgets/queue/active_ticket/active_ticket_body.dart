import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../../core/layout/patient_breakpoints.dart';
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
  final VoidCallback? onRaiseConcern;

  const ActiveTicketBody({
    super.key,
    required this.ticket,
    required this.allClinics,
    required this.onCancelSpot,
    required this.onGetDirections,
    this.onRaiseConcern,
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
    final isLaptop = PatientBreakpoints.isLaptop(context);

    if (isLaptop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (flex: 48): Ticket Card & Actions
          Expanded(
            flex: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActiveTicketHeroCard(ticket: ticket),
                const SizedBox(height: 16),
                ActiveTicketActions(
                  onGetDirections: () => onGetDirections(_associatedClinic),
                  onCancelSpot: onCancelSpot,
                  onRaiseConcern: onRaiseConcern,
                ),
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
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (flex: 52): Queue Status Timeline & Clinic Details
          Expanded(
            flex: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildLaptopClinicInfoCard(colors),
              ],
            ),
          ),
        ],
      );
    }

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
          onRaiseConcern: onRaiseConcern,
        ),
      ],
    );
  }

  Widget _buildLaptopClinicInfoCard(AppColorsExtension colors) {
    final clinic = _associatedClinic;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_hospital_rounded, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      clinic.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _infoPill(colors, Icons.access_time_rounded, clinic.openingHours),
              const SizedBox(width: 10),
              _infoPill(colors, Icons.phone_outlined, clinic.phone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoPill(AppColorsExtension colors, IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colors.textSubtle),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
