import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_common_widgets.dart';

class ClinicDetailsDoctorsCard extends StatelessWidget {
  final TenantClinicEntity clinic;

  const ClinicDetailsDoctorsCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicDetailsCommonWidgets.sectionHeader(
            colors,
            icon: Icons.medical_services_outlined,
            color: const Color(0xFFA855F7),
            title: 'Practicing Medical Team (${clinic.doctors.length})',
          ),
          const SizedBox(height: 14),
          if (clinic.doctors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No doctors added yet. The clinic admin adds doctors from their portal.',
                style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
              ),
            )
          else
            for (final doc in clinic.doctors)
              _doctorTile(
                colors,
                name: doc.name,
                specialty: doc.specialty,
                room: doc.room,
                isAvailable: doc.isAvailable,
                status: doc.status,
              ),
        ],
      ),
    );
  }

  Widget _doctorTile(
    AppColorsExtension colors, {
    required String name,
    required String specialty,
    required String room,
    required bool isAvailable,
    String status = 'available',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primaryTint,
            child: Icon(
              Icons.person_rounded,
              color: colors.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [specialty, room].where((s) => s.isNotEmpty).join(' • '),
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable ? colors.badgeOpenBg : colors.warningTint,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase().replaceAll('-', ' '),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAvailable ? colors.badgeOpenText : colors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
