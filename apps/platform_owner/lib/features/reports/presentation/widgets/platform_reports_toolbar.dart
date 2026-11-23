import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'toolbar/platform_reports_time_tabs.dart';

class PlatformReportsToolbar extends StatelessWidget {
  final String activeRange;
  final DateTimeRange? customDateRange;
  final String selectedTier;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<DateTimeRange?> onCustomRangeSelected;
  final ValueChanged<String> onTierChanged;

  const PlatformReportsToolbar({
    super.key,
    required this.activeRange,
    this.customDateRange,
    required this.selectedTier,
    required this.onRangeChanged,
    required this.onCustomRangeSelected,
    required this.onTierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PlatformReportsTimeTabs(
          activeRange: activeRange,
          customDateRange: customDateRange,
          onRangeChanged: onRangeChanged,
          onCustomRangeSelected: onCustomRangeSelected,
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plan Tier: ',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTier,
                      dropdownColor: isDark ? const Color(0xFF0F172A) : colors.surface,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Plan Tiers')),
                        DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan')),
                        DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan')),
                        DropdownMenuItem(value: 'unlimited', child: Text('Unlimited Doctors Plan')),
                      ],
                      onChanged: (v) {
                        if (v != null) onTierChanged(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live Network Telemetry',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
