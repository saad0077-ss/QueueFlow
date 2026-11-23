import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'calendar_appt_card.dart';

class CalendarDayAgendaSection extends StatelessWidget {
  final DateTime selectedDate;
  final List<ClinicAppointmentEntity> dayAppointments;
  final ValueChanged<ClinicAppointmentEntity> onSelectAppointment;
  final List<String> monthNames;

  const CalendarDayAgendaSection({
    super.key,
    required this.selectedDate,
    required this.dayAppointments,
    required this.onSelectAppointment,
    required this.monthNames,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Appointments on ${monthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayAppointments.length} bookings',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dayAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No bookings scheduled for this date.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayAppointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final appt = dayAppointments[index];
                return CalendarApptCard(
                  appointment: appt,
                  onTap: () => onSelectAppointment(appt),
                );
              },
            ),
        ],
      ),
    );
  }
}
