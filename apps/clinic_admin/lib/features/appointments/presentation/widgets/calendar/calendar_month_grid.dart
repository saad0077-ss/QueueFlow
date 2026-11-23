import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';

class CalendarMonthGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<ClinicAppointmentEntity> appointments;
  final ValueChanged<DateTime> onSelectDate;
  final List<String> dows;

  const CalendarMonthGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.appointments,
    required this.onSelectDate,
    required this.dows,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final totalCells = startingWeekday + daysInMonth;
    final totalRows = (totalCells / 7).ceil();
    final compact = MediaQuery.of(context).size.width < 700;
    final cellHeight = compact ? 54.0 : 76.0;
    final cellMargin = compact ? 2.0 : 4.0;

    return Column(
      children: [
        Row(
          children: dows.map((dow) {
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
        ...List.generate(totalRows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
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
                  currentMonth.year,
                  currentMonth.month,
                  dayNumber,
                );
                final now = DateTime.now();
                final isToday =
                    cellDate.year == now.year &&
                    cellDate.month == now.month &&
                    cellDate.day == now.day;
                final isSelected =
                    cellDate.year == selectedDate.year &&
                    cellDate.month == selectedDate.month &&
                    cellDate.day == selectedDate.day;

                final dateRawStr =
                    '${cellDate.year.toString().padLeft(4, '0')}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                final count = appointments
                    .where((a) => a.dateRaw == dateRawStr)
                    .length;

                return Expanded(
                  child: InkWell(
                    onTap: () => onSelectDate(cellDate),
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
