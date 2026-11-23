import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'appointment_detail_section_card.dart';

class _Step {
  final String title;
  final String subtitle;
  final bool done;

  const _Step(this.title, this.subtitle, this.done);
}

class AppointmentDetailTimelineCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;

  const AppointmentDetailTimelineCard({super.key, required this.appointment});

  Widget _timelineRow(
    AppColorsExtension colors,
    _Step s, {
    required bool isLast,
  }) {
    final color = s.done ? colors.success : colors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.done ? colors.success : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: s.done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: s.done ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                  Text(
                    s.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    final steps = <_Step>[
      const _Step('Booked', 'Appointment created', true),
      _Step(
        'Confirmed',
        'Slot confirmed with clinic',
        a.isConfirmed || a.isCheckedIn || a.isCompleted,
      ),
      _Step(
        'Checked In',
        'Patient arrived at clinic',
        a.isCheckedIn || a.isCompleted,
      ),
      _Step('Completed', 'Consultation finished', a.isCompleted),
    ];

    return AppointmentDetailSectionCard(
      title: 'Progress',
      icon: Icons.timeline_rounded,
      child: a.isCancelled
          ? Row(
              children: [
                Icon(Icons.cancel_rounded, color: colors.error, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This appointment was cancelled.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  _timelineRow(colors, steps[i], isLast: i == steps.length - 1),
              ],
            ),
    );
  }
}
