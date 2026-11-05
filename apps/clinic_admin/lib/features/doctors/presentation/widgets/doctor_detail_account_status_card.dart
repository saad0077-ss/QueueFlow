import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailAccountStatusCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final ValueChanged<String> onChangeStatus;

  const DoctorDetailAccountStatusCard({
    super.key,
    required this.doctor,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final options = [
      (
        'active',
        'Active',
        'Visible to patients and bookable in the live queue.',
        colors.success,
      ),
      (
        'inactive',
        'Inactive',
        'Hidden from booking. Existing records are kept.',
        colors.error,
      ),
      (
        'pending',
        'Pending',
        'Awaiting verification before the doctor can take bookings.',
        colors.warning,
      ),
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
              Icon(Icons.shield_outlined, size: 16, color: colors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Account Status',
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
          const SizedBox(height: 12),
          for (final (key, label, desc, color) in options) ...[
            _buildStatusRadio(
              context: context,
              key: key,
              label: label,
              desc: desc,
              color: color,
              isSelected: doctor.accountStatus == key,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRadio({
    required BuildContext context,
    required String key,
    required String label,
    required String desc,
    required Color color,
    required bool isSelected,
  }) {
    final colors = context.colors;

    return InkWell(
      onTap: () => onChangeStatus(key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryTint
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
