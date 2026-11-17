import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HoursScheduleBanner extends StatefulWidget {
  final int totalWeeklyHours;
  final bool isEmergencyOnCall;
  final String scheduleSummary;

  /// Live open/closed state for today; null when no schedule is configured.
  final ({bool isOpen, String label}) Function()? statusBuilder;

  const HoursScheduleBanner({
    super.key,
    required this.totalWeeklyHours,
    required this.isEmergencyOnCall,
    this.scheduleSummary = 'Mon–Sat: 9:00 AM – 8:00 PM · Sun: Closed',
    this.statusBuilder,
  });

  @override
  State<HoursScheduleBanner> createState() => _HoursScheduleBannerState();
}

class _HoursScheduleBannerState extends State<HoursScheduleBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get totalWeeklyHours => widget.totalWeeklyHours;
  bool get isEmergencyOnCall => widget.isEmergencyOnCall;
  String get scheduleSummary => widget.scheduleSummary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = widget.statusBuilder?.call();
    final pillColor = status == null || !status.isOpen ? colors.warning : colors.badgeOpenText;
    final pillBg = status == null || !status.isOpen ? colors.warningTint : colors.badgeOpenBg;

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Clinic Operating Schedule',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: pillColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: pillColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(status?.label ?? 'NOT SET', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: pillColor)),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isEmergencyOnCall) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.badgeOpenBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.badgeOpenText.withAlpha(120)),
                      ),
                      child: Text(
                        '⚡ 24/7 Triage On-Call',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.badgeOpenText),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withAlpha(120)),
                    ),
                    child: Text(
                      '$totalWeeklyHours Hrs / Week',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primaryLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(scheduleSummary, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
        ],
      ),
    );
  }
}
