import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class CalendarMonthHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final List<String> monthNames;

  const CalendarMonthHeader({
    super.key,
    required this.currentMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.monthNames,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon: const Icon(Icons.chevron_left_rounded),
              color: colors.textMuted,
              iconSize: 20,
              splashRadius: 18,
              tooltip: 'Previous month',
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
              color: colors.textMuted,
              iconSize: 20,
              splashRadius: 18,
              tooltip: 'Next month',
            ),
          ],
        ),
      ],
    );
  }
}
