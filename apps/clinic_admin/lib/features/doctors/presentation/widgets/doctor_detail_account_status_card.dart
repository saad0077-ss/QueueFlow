import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailAccountStatusCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final ValueChanged<String> onChangeStatus;

  const DoctorDetailAccountStatusCard({
    super.key,
    required this.doctor,
    required this.onChangeStatus,
  });

  static const _options = [
    (
      'active',
      'Active',
      'Visible to patients and bookable in the live queue.',
      DoctorColors.green,
    ),
    (
      'inactive',
      'Inactive',
      'Hidden from booking. Existing records are kept.',
      DoctorColors.red,
    ),
    (
      'pending',
      'Pending',
      'Awaiting verification before the doctor can take bookings.',
      DoctorColors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: DoctorColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Account Status',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: DoctorColors.border, height: 1),
          const SizedBox(height: 12),
          for (final (key, label, desc, color) in _options) ...[
            _buildStatusRadio(
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
    required String key,
    required String label,
    required String desc,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onChangeStatus(key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
              : DoctorColors.field,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : DoctorColors.border,
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: DoctorColors.muted,
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
