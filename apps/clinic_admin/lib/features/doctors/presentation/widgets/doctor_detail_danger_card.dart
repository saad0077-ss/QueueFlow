import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailDangerCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final VoidCallback onRemoveDoctor;

  const DoctorDetailDangerCard({
    super.key,
    required this.doctor,
    required this.onRemoveDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: colors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Danger Zone',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),
          Text(
            'Removing a doctor deletes them from the clinic roster, booking and live queue. This cannot be undone.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: colors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRemoveDoctor,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.45)),
                backgroundColor: colors.errorTint,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 14, color: colors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Remove Doctor',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
