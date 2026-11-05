import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';

class DoctorDetailConsultationCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailConsultationCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeDays = doctor.weeklySchedule.values.where((d) => d.enabled).toList();
    final workingDaysText = activeDays.isNotEmpty
        ? activeDays.map((d) => d.shortName).join(', ')
        : 'Mon, Tue, Wed, Thu, Fri, Sat, Sun';

    final firstDay = activeDays.isNotEmpty ? activeDays.first : null;
    final hoursText = firstDay != null
        ? '${DoctorDailySchedule.formatTime12h(firstDay.start)} – ${DoctorDailySchedule.formatTime12h(firstDay.end)}'
        : '9:00 AM – 5:00 PM';

    final rows = [
      ('APPOINTMENT DURATION', '${doctor.slotDuration} min'),
      ('WORKING DAYS', workingDaysText),
      ('CONSULTATION HOURS', hoursText),
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
              Icon(Icons.schedule_rounded, size: 16, color: colors.primaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consultation Settings',
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      rows[i].$2,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(color: colors.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }
}
