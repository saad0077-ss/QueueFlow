import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_entity.dart';

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
    final colors = context.colors;

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
                color: colors.textPrimary,
              ),
            ),
            Text(
              'Who performs this in your clinic?',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: availableDoctors.isEmpty
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 14)
              : const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.border,
            ),
          ),
          child: availableDoctors.isEmpty
              ? Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No doctors available for this department or service',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                )
              : Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: availableDoctors.map((doc) => _buildDoctorRow(context, doc)).toList(),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'Patients booking this service will only be able to select from assigned doctors.',
          style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDoctorRow(BuildContext context, ClinicDoctorEntity doctor) {
    final colors = context.colors;
    final isChecked = selectedDoctors.contains(doctor.name);
    final detailText = doctor.detail;

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
                activeColor: colors.primary,
                side: BorderSide(color: colors.border, width: 1.5),
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
                        color: colors.textPrimary,
                      ),
                    ),
                    if (detailText.isNotEmpty)
                      TextSpan(
                        text: '  ($detailText)',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textMuted,
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
