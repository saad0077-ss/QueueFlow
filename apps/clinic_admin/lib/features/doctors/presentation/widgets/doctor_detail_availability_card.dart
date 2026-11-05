import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';

class DoctorDetailAvailabilityCard extends StatefulWidget {
  final ClinicDoctorProfileEntity doctor;
  final VoidCallback onEditSchedule;

  const DoctorDetailAvailabilityCard({
    super.key,
    required this.doctor,
    required this.onEditSchedule,
  });

  @override
  State<DoctorDetailAvailabilityCard> createState() =>
      _DoctorDetailAvailabilityCardState();
}

class _DoctorDetailAvailabilityCardState
    extends State<DoctorDetailAvailabilityCard> {
  static const _days = [
    ('mon', 'Mon'),
    ('tue', 'Tue'),
    ('wed', 'Wed'),
    ('thu', 'Thu'),
    ('fri', 'Fri'),
    ('sat', 'Sat'),
    ('sun', 'Sun'),
  ];

  late String _selectedDayKey;

  @override
  void initState() {
    super.initState();
    _selectedDayKey = 'mon';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final schedule = widget.doctor.weeklySchedule.isNotEmpty
        ? widget.doctor.weeklySchedule
        : DoctorDailySchedule.defaultWeekly();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: colors.primaryLight),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Weekly Availability',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onEditSchedule,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Edit schedule',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 540;
              final colWidth = isWide
                  ? (constraints.maxWidth - (6 * 8)) / 7
                  : (constraints.maxWidth - 8) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (key, short) in _days)
                    _buildDayBox(
                      colors: colors,
                      colWidth: colWidth,
                      dayKey: key,
                      short: short,
                      schedule: schedule[key],
                      isSelected: key == _selectedDayKey,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayBox({
    required AppColorsExtension colors,
    required double colWidth,
    required String dayKey,
    required String short,
    required DoctorDailySchedule? schedule,
    required bool isSelected,
  }) {
    final isOn = schedule?.enabled ?? false;
    final start12 = isOn && schedule != null
        ? DoctorDailySchedule.formatTime12h(schedule.start)
        : 'Off';
    final end12 = isOn && schedule != null
        ? DoctorDailySchedule.formatTime12h(schedule.end)
        : '';
    final break12 = isOn &&
            schedule != null &&
            schedule.breakStart.isNotEmpty &&
            schedule.breakEnd.isNotEmpty
        ? 'Break: ${DoctorDailySchedule.formatTime12h(schedule.breakStart)}-${DoctorDailySchedule.formatTime12h(schedule.breakEnd)}'
        : '';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDayKey = dayKey;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: colWidth,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryTint
              : (isOn ? colors.surfaceSecondary : colors.background),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              short,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isOn ? colors.textPrimary : colors.textMuted,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              start12,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isOn ? colors.textPrimary : colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (end12.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(
                end12,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (break12.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                break12,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
