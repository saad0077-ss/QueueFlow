import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10192C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          _row(Icons.location_on_outlined, 'Facility Address:', clinic.address),
          _row(Icons.person_outline_rounded, 'Medical Director:', '${clinic.adminName} (${clinic.adminEmail})'),
          _row(Icons.phone_outlined, 'Phone Contact:', clinic.phone),
          _row(Icons.access_time_rounded, 'Operating Hours:', clinic.operatingHours),
          _row(Icons.medical_services_outlined, 'Doctor Capacity:', '${clinic.practicingDoctors} Doctors active • ${clinic.doctorLimitText}'),
          _row(Icons.confirmation_number_outlined, 'Live Queue Activity:', '${clinic.queueStatus} • Token ${clinic.servingToken} (Avg: ${clinic.avgWaitTime})'),
          _row(Icons.star_rounded, 'Patient Reviews:', '★ ${clinic.rating} / 5.0 (Patient Rating)'),
          _row(Icons.calendar_today_outlined, 'Monthly Appointments:', '${clinic.monthlyVisits} visits this month'),
        ],
      ),
    );
  }

  static Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFFF1F5F9),
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
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.25),
            child: const Icon(Icons.person_rounded, size: 16, color: Color(0xFF60A5FA)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  doc.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${doc.specialty} • ${doc.room}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
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
                  ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                  : const Color(0xFF78350F).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: doc.isAvailable
                    ? const Color(0xFF059669).withValues(alpha: 0.4)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              doc.isAvailable ? 'AVAILABLE' : 'OFF DUTY',
              style: GoogleFonts.inter(
                color: doc.isAvailable ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
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
