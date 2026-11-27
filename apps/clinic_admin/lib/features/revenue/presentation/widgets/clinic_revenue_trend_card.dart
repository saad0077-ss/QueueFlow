import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_area_chart.dart';
import 'clinic_revenue_card_shell.dart';

/// Interactive area curve showing net clinic collections across the active period.
class ClinicRevenueTrendCard extends StatefulWidget {
  final List<DailyRevenuePoint> points;
  final String periodLabel;

  const ClinicRevenueTrendCard({
    super.key,
    required this.points,
    required this.periodLabel,
  });

  @override
  State<ClinicRevenueTrendCard> createState() => _ClinicRevenueTrendCardState();
}

class _ClinicRevenueTrendCardState extends State<ClinicRevenueTrendCard> {
  int? _selectedIdx;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pts = widget.points;
    final total = pts.fold<double>(0, (sum, p) => sum + p.amount);
    final peak = pts.fold<double>(0, (max, p) => p.amount > max ? p.amount : max);
    final avg = pts.isEmpty ? 0.0 : total / pts.length;
    final activeIdx = _resolveActiveIndex(pts);
    final peakPoint = pts.where((p) => p.amount == peak && peak > 0).firstOrNull;

    return ClinicRevenueCardShell(
      title: 'Revenue Trajectory',
      subtitle: 'Net settled collections across ${widget.periodLabel.toLowerCase()}',
      trailing: peakPoint != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Peak ${peakPoint.label}: '
                '${ClinicRevenueFormatter.formatCompactInr(peakPoint.amount)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stat(colors, 'PERIOD TOTAL', ClinicRevenueFormatter.formatCompactInr(total)),
              _divider(colors),
              _stat(colors, 'AVG / BUCKET', ClinicRevenueFormatter.formatCompactInr(avg)),
              _divider(colors),
              _stat(colors, 'HIGHEST', peak > 0 ? ClinicRevenueFormatter.formatCompactInr(peak) : '—'),
            ],
          ),
          const SizedBox(height: 14),
          if (pts.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Not enough points to chart in this range.',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 175,
              child: ClinicRevenueAreaChart(
                points: pts,
                activeIndex: activeIdx,
                onActiveChanged: (idx) => setState(() => _selectedIdx = idx),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(AppColorsExtension colors, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColorsExtension colors) => Container(
    width: 1,
    height: 26,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: colors.border,
  );

  int? _resolveActiveIndex(List<DailyRevenuePoint> pts) {
    if (pts.isEmpty) return null;
    if (_selectedIdx != null && _selectedIdx! < pts.length) return _selectedIdx;
    int best = 0;
    for (int i = 1; i < pts.length; i++) {
      if (pts[i].amount >= pts[best].amount) best = i;
    }
    return pts[best].amount > 0 ? best : null;
  }
}
