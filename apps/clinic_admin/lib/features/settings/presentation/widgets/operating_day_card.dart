import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/operating_hours_day_entity.dart';
import 'time_input_box.dart';

class OperatingDayCard extends StatelessWidget {
  final OperatingHoursDayEntity day;
  final ValueChanged<OperatingHoursDayEntity> onDayChanged;
  final VoidCallback? onCopyDay;

  const OperatingDayCard({
    super.key,
    required this.day,
    required this.onDayChanged,
    this.onCopyDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 32,
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(day.shortName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(day.dayName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 10),
              _statusPill(day.isOpen),
              const Spacer(),
              Switch(
                value: day.isOpen,
                activeTrackColor: const Color(0xFF2563EB),
                onChanged: (val) => onDayChanged(day.copyWith(isOpen: val)),
              ),
            ],
          ),
          if (!day.isOpen) ...[
            const SizedBox(height: 6),
            Text('Clinic OPD is closed on this day. Emergency triage on-call duty may still apply.', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), fontStyle: FontStyle.italic)),
          ] else ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('OPD Shift: ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                        TimeInputBox(value: day.openTime, onChanged: (t) => onDayChanged(day.copyWith(openTime: t))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('to', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)))),
                        TimeInputBox(value: day.closeTime, onChanged: (t) => onDayChanged(day.copyWith(closeTime: t))),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: day.hasBreak,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (val) => onDayChanged(day.copyWith(hasBreak: val ?? false)),
                        ),
                        Text('Lunch Break ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: day.hasBreak ? Colors.white : const Color(0xFF94A3B8))),
                        if (day.hasBreak) ...[
                          TimeInputBox(value: day.breakStart, onChanged: (t) => onDayChanged(day.copyWith(breakStart: t))),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('to', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)))),
                          TimeInputBox(value: day.breakEnd, onChanged: (t) => onDayChanged(day.copyWith(breakEnd: t))),
                        ],
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withAlpha(40), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF3B82F6).withAlpha(80))),
                      child: Text(day.netHoursText, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF60A5FA))),
                    ),
                    if (onCopyDay != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: onCopyDay,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1E293B)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 12),
                        label: Text('Copy', style: GoogleFonts.inter(fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF065F46).withAlpha(80) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isOpen ? const Color(0xFF10B981).withAlpha(120) : const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: isOpen ? const Color(0xFF10B981) : const Color(0xFF64748B), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(isOpen ? '• Open for OPD' : '• Closed for OPD', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isOpen ? const Color(0xFF34D399) : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
