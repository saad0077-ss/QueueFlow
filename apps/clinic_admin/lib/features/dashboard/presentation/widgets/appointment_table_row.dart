import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appointment_item_model.dart';
import 'appointment_status_pill.dart';

/// Single row item in the upcoming appointments table.
class AppointmentTableRow extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentTableRow({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Time
          Expanded(
            flex: 2,
            child: Text(
              appointment.time,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          // Customer Name
          Expanded(
            flex: 3,
            child: Text(
              appointment.customer,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          // Service
          Expanded(
            flex: 4,
            child: Text(
              appointment.service,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          // Doctor
          Expanded(
            flex: 3,
            child: Text(
              appointment.doctor,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          // Status Pill Badge
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: AppointmentStatusPill(
                status: appointment.status,
                isCompleted: appointment.isCompleted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
