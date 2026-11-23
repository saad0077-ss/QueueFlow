import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'appointment_detail_section_card.dart';

class AppointmentDetailServiceCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;

  const AppointmentDetailServiceCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    return AppointmentDetailSectionCard(
      title: 'Service Selected',
      icon: Icons.medical_services_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.badgeOpenBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 12, color: colors.badgeOpenText),
            const SizedBox(width: 4),
            Text(
              a.serviceDuration,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.badgeOpenText,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.service,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              a.departmentName,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            a.serviceDescription,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.55,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
