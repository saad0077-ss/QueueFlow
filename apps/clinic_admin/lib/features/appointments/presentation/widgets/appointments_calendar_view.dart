import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import 'calendar/calendar_day_agenda_section.dart';
import 'calendar/calendar_month_grid.dart';
import 'calendar/calendar_month_header.dart';

class AppointmentsCalendarView extends StatefulWidget {
  final List<ClinicAppointmentEntity> appointments;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<ClinicAppointmentEntity> onSelectAppointment;

  const AppointmentsCalendarView({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onSelectAppointment,
  });

  @override
  State<AppointmentsCalendarView> createState() =>
      _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _dows = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final selectedDayAppointments = widget.appointments.where((a) {
      final y = widget.selectedDate.year.toString().padLeft(4, '0');
      final m = widget.selectedDate.month.toString().padLeft(2, '0');
      final d = widget.selectedDate.day.toString().padLeft(2, '0');
      return a.dateRaw == '$y-$m-$d';
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              CalendarMonthHeader(
                currentMonth: _currentMonth,
                onPrevMonth: _prevMonth,
                onNextMonth: _nextMonth,
                monthNames: _monthNames,
              ),
              const SizedBox(height: 16),
              CalendarMonthGrid(
                currentMonth: _currentMonth,
                selectedDate: widget.selectedDate,
                appointments: widget.appointments,
                onSelectDate: widget.onSelectDate,
                dows: _dows,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CalendarDayAgendaSection(
          selectedDate: widget.selectedDate,
          dayAppointments: selectedDayAppointments,
          onSelectAppointment: widget.onSelectAppointment,
          monthNames: _monthNames,
        ),
      ],
    );
  }
}
