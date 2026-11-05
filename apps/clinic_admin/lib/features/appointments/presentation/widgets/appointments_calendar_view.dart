import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

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

    // Filter appointments for the selected day
    final selectedDayAppointments = widget.appointments.where((a) {
      final y = widget.selectedDate.year.toString().padLeft(4, '0');
      final m = widget.selectedDate.month.toString().padLeft(2, '0');
      final d = widget.selectedDate.day.toString().padLeft(2, '0');
      final targetStr = '$y-$m-$d';
      return a.dateRaw == targetStr;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Calendar Card
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
              // Header: Month Title and Prev/Next buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _prevMonth,
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: colors.textMuted,
                        iconSize: 20,
                        splashRadius: 18,
                        tooltip: 'Previous month',
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: colors.textMuted,
                        iconSize: 20,
                        splashRadius: 18,
                        tooltip: 'Next month',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Grid
              _buildMonthGrid(colors),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Day Appointments Section
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
                            'Appointments on ${_monthNames[widget.selectedDate.month - 1]} ${widget.selectedDate.day}, ${widget.selectedDate.year}',
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
                      '${selectedDayAppointments.length} bookings',
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
              if (selectedDayAppointments.isEmpty)
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
                  itemCount: selectedDayAppointments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final appt = selectedDayAppointments[index];
                    return _CalendarApptCard(
                      appointment: appt,
                      onTap: () => widget.onSelectAppointment(appt),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(AppColorsExtension colors) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    // Sunday is 0, Monday is 1, etc.
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final totalCells = startingWeekday + daysInMonth;
    final totalRows = (totalCells / 7).ceil();
    final compact = MediaQuery.of(context).size.width < 700;
    final cellHeight = compact ? 54.0 : 76.0;
    final cellMargin = compact ? 2.0 : 4.0;

    return Column(
      children: [
        // Days of week header row
        Row(
          children: _dows.map((dow) {
            return Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    dow,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Grid Rows
        ...List.generate(totalRows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  // Empty cell
                  return Expanded(
                    child: Container(
                      height: cellHeight,
                      margin: EdgeInsets.symmetric(horizontal: cellMargin),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }

                final cellDate = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  dayNumber,
                );
                final now = DateTime.now();
                final isToday =
                    cellDate.year == now.year &&
                    cellDate.month == now.month &&
                    cellDate.day == now.day;
                final isSelected =
                    cellDate.year == widget.selectedDate.year &&
                    cellDate.month == widget.selectedDate.month &&
                    cellDate.day == widget.selectedDate.day;

                // Count appointments on this day
                final dateRawStr =
                    '${cellDate.year.toString().padLeft(4, '0')}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                final count = widget.appointments
                    .where((a) => a.dateRaw == dateRawStr)
                    .length;

                return Expanded(
                  child: InkWell(
                    onTap: () => widget.onSelectDate(cellDate),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: cellHeight,
                      margin: EdgeInsets.symmetric(horizontal: cellMargin),
                      padding: EdgeInsets.all(compact ? 5 : 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryTint
                            : (isToday
                                  ? colors.primaryTint.withValues(alpha: 0.6)
                                  : colors.surface),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : (isToday ? colors.primary : colors.border),
                          width: isSelected || isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$dayNumber',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected || isToday
                                    ? colors.primary
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                          if (count > 0)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [colors.primary, colors.accent],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _CalendarApptCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onTap;

  const _CalendarApptCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Time Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                appointment.timeRaw,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Patient & Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${appointment.service} · ${appointment.doctor}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Ref & Details Icon
            Text(
              '#${appointment.bookingId}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
