import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailContactCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailContactCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = [
      ('EMAIL', doctor.email.isNotEmpty ? doctor.email : '—', true),
      ('PHONE', doctor.phone.isNotEmpty ? doctor.phone : '—', true),
      ('ROOM', doctor.room.isNotEmpty ? doctor.room : '—', false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contact',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 10),
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rows[i].$1,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].$2,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rows[i].$3 ? colors.primary : colors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(color: colors.border, height: 1),
          ],
        ],
      ),
    );
  }
}
