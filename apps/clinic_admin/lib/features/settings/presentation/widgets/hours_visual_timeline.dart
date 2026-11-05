import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/operating_hours_day_entity.dart';
import 'timeline_day_row.dart';
import 'timeline_ruler_header.dart';

class HoursVisualTimeline extends StatelessWidget {
  final Map<String, OperatingHoursDayEntity> days;

  const HoursVisualTimeline({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visual Weekly Timeline Overview',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Proportional daily clinic shift coverage. Blue indicates active OPD consultation hours, amber indicates midday doctor lunch breaks.',
                      style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  _legendDot(colors.primary, 'Active Open', colors),
                  const SizedBox(width: 8),
                  _legendDot(colors.warning, 'Lunch Break', colors),
                  const SizedBox(width: 8),
                  _legendDot(colors.border, 'Closed', colors),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const TimelineRulerHeader(),
          ...days.values.map((d) => TimelineDayRow(day: d)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text, AppColorsExtension colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
      ],
    );
  }
}
