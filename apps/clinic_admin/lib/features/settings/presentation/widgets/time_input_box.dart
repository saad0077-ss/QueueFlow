import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class TimeInputBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TimeInputBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> timeSlots = [
    '06:00', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00',
    '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00',
    '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00',
    '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveValue = timeSlots.contains(value) ? value : timeSlots.first;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          icon: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(Icons.access_time_rounded, size: 14, color: colors.textMuted),
          ),
          dropdownColor: colors.surfaceElevated,
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.textPrimary),
          items: timeSlots.map((t) {
            return DropdownMenuItem<String>(
              value: t,
              child: Text(t, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
