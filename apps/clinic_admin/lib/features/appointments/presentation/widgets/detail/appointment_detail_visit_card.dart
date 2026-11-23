import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'appointment_detail_section_card.dart';

class AppointmentDetailVisitCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;

  const AppointmentDetailVisitCard({super.key, required this.appointment});

  Widget _infoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;

    return AppointmentDetailSectionCard(
      title: 'Visit Details',
      icon: Icons.event_note_rounded,
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 480 ? 2 : 1;
          final w = (c.maxWidth - 16 * (cols - 1)) / cols;
          Widget cell(String label, String value, IconData icon) =>
              SizedBox(width: w, child: _infoTile(context, label, value, icon));
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              cell('Assigned Doctor', a.doctor, Icons.person_outline_rounded),
              cell('Doctor Role', a.doctorRole, Icons.badge_outlined),
              cell('Date & Time', a.dateTime, Icons.calendar_today_outlined),
              cell('Visit Type', a.type, Icons.groups_2_outlined),
              cell('Room', a.room, Icons.meeting_room_outlined),
              cell('Category', a.serviceCategory, Icons.category_outlined),
            ],
          );
        },
      ),
    );
  }
}
