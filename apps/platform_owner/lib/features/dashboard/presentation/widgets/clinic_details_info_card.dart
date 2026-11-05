import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class StatMetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatMetricBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: colors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class FacilityInfoCard extends StatelessWidget {
  final TenantClinicEntity clinic;

  const FacilityInfoCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _row(colors, Icons.location_on_outlined, 'Facility Address:', clinic.address),
          _row(colors, Icons.person_outline_rounded, 'Medical Director:', '${clinic.adminName} (${clinic.adminEmail})'),
          _row(colors, Icons.phone_outlined, 'Phone Contact:', clinic.phone),
          _row(colors, Icons.access_time_rounded, 'Operating Hours:', clinic.operatingHours),
          _row(colors, Icons.medical_services_outlined, 'Doctor Capacity:', '${clinic.practicingDoctors} Doctors active • ${clinic.doctorLimitText}'),
          _row(colors, Icons.confirmation_number_outlined, 'Live Queue Activity:', '${clinic.queueStatus} • Token ${clinic.servingToken} (Avg: ${clinic.avgWaitTime})'),
          _row(colors, Icons.star_rounded, 'Patient Reviews:', '★ ${clinic.rating} / 5.0 (Patient Rating)'),
          _row(colors, Icons.calendar_today_outlined, 'Monthly Appointments:', '${clinic.monthlyVisits} visits this month'),
        ],
      ),
    );
  }

  static Widget _row(AppColorsExtension colors, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: colors.primaryLight),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: colors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorRosterTile extends StatelessWidget {
  final PracticingDoctorEntity doc;

  const DoctorRosterTile({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.primaryTint,
            child: Icon(Icons.person_rounded, size: 16, color: colors.primaryLight),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  doc.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${doc.specialty} • ${doc.room}',
                  style: GoogleFonts.inter(
                    color: colors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: doc.isAvailable
                  ? colors.badgeOpenBg
                  : colors.warningTint,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: doc.isAvailable
                    ? colors.success.withValues(alpha: 0.4)
                    : colors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              doc.isAvailable ? 'AVAILABLE' : 'OFF DUTY',
              style: GoogleFonts.inter(
                color: doc.isAvailable ? colors.badgeOpenText : colors.warning,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
