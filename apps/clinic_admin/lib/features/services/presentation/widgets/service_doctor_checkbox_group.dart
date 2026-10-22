import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_entity.dart';
import 'service_ui_kit.dart';

class ServiceDoctorCheckboxGroup extends StatelessWidget {
  final List<ClinicDoctorEntity> availableDoctors;
  final List<String> selectedDoctors;
  final ValueChanged<String> onToggleDoctor;

  const ServiceDoctorCheckboxGroup({
    super.key,
    required this.availableDoctors,
    required this.selectedDoctors,
    required this.onToggleDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              '👨‍⚕️ Assign Practicing Doctor(s) *',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            Text(
              'Who performs this in your clinic?',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: ServiceColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: ServiceColors.field,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ServiceColors.fieldBorder),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: availableDoctors.map(_buildDoctorRow).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Patients booking this service will only be able to select from assigned doctors.',
          style: GoogleFonts.inter(fontSize: 11.5, color: ServiceColors.muted),
        ),
      ],
    );
  }

  Widget _buildDoctorRow(ClinicDoctorEntity doctor) {
    final isChecked = selectedDoctors.contains(doctor.name);
    return InkWell(
      onTap: () => onToggleDoctor(doctor.name),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: isChecked,
                onChanged: (_) => onToggleDoctor(doctor.name),
                activeColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF475569), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '👨‍⚕️ ${doctor.name}',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '  (${doctor.detail})',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
