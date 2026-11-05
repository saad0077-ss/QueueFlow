import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/operating_hours_day_entity.dart';

class TimelineDayRow extends StatelessWidget {
  final OperatingHoursDayEntity day;

  const TimelineDayRow({super.key, required this.day});

  static const int minTimeline = 420; // 07:00
  static const int maxTimeline = 1260; // 21:00

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(day.shortName, style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildBarTrack(context)),
          const SizedBox(width: 10),
          SizedBox(
            width: 54,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: day.isOpen ? colors.primaryTint : colors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: day.isOpen ? colors.primary.withAlpha(70) : colors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                day.netHoursText,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: day.isOpen ? colors.primaryLight : colors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarTrack(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: 22,
        color: colors.surface,
        child: !day.isOpen
            ? Container(
                color: colors.surfaceSecondary,
                alignment: Alignment.center,
                child: Text('Closed', style: GoogleFonts.inter(fontSize: 10, color: colors.textSubtle)),
              )
            : _buildOpenRow(context),
      ),
    );
  }

  Widget _buildOpenRow(BuildContext context) {
    final colors = context.colors;
    final o = OperatingHoursDayEntity.parseMinutes(day.openTime).clamp(minTimeline, maxTimeline);
    final c = OperatingHoursDayEntity.parseMinutes(day.closeTime).clamp(minTimeline, maxTimeline);
    final pre = (o - minTimeline).clamp(0, 840);
    final post = (maxTimeline - c).clamp(0, 840);

    if (day.hasBreak && day.breakStart.isNotEmpty && day.breakEnd.isNotEmpty) {
      final bs = OperatingHoursDayEntity.parseMinutes(day.breakStart).clamp(o, c);
      final be = OperatingHoursDayEntity.parseMinutes(day.breakEnd).clamp(bs, c);
      final s1 = (bs - o).clamp(0, 840);
      final brk = (be - bs).clamp(0, 840);
      final s2 = (c - be).clamp(0, 840);

      return Row(
        children: [
          if (pre > 0) Spacer(flex: pre),
          if (s1 > 0) Expanded(flex: s1, child: _segment(colors.primary, '${day.openTime}–${day.breakStart}')),
          if (brk > 0) Expanded(flex: brk, child: _segment(colors.warning, 'Break')),
          if (s2 > 0) Expanded(flex: s2, child: _segment(colors.primary, '${day.breakEnd}–${day.closeTime}')),
          if (post > 0) Spacer(flex: post),
        ],
      );
    }

    final shift = (c - o).clamp(0, 840);
    return Row(
      children: [
        if (pre > 0) Spacer(flex: pre),
        if (shift > 0) Expanded(flex: shift, child: _segment(colors.primary, '${day.openTime}–${day.closeTime}')),
        if (post > 0) Spacer(flex: post),
      ],
    );
  }

  Widget _segment(Color color, String label) {
    return Container(
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
