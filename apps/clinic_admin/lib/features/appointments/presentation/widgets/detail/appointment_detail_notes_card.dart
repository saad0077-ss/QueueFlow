import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'appointment_detail_section_card.dart';

class AppointmentDetailNotesCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;

  const AppointmentDetailNotesCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    return AppointmentDetailSectionCard(
      title: 'Visit Notes & Symptoms',
      icon: Icons.sticky_note_2_outlined,
      child: Text(
        a.notes.isNotEmpty ? a.notes : 'No specific symptoms noted.',
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.55,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
