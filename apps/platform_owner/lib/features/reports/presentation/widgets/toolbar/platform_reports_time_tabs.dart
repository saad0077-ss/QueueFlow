import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_reports_calendar_button.dart';

class PlatformReportsTimeTabs extends StatelessWidget {
  final String activeRange;
  final DateTimeRange? customDateRange;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<DateTimeRange?> onCustomRangeSelected;

  const PlatformReportsTimeTabs({
    super.key,
    required this.activeRange,
    this.customDateRange,
    required this.onRangeChanged,
    required this.onCustomRangeSelected,
  });

  static const _ranges = [
    {'key': '30d', 'label': 'Last 30 Days'},
    {'key': '90d', 'label': 'Last 90 Days'},
    {'key': 'all', 'label': 'All Time'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final isCustomActive = activeRange == 'custom' && customDateRange != null;

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _ranges.map((r) {
              final sel = r['key'] == activeRange;
              return InkWell(
                onTap: () => onRangeChanged(r['key']!),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? (isDark ? const Color(0xFF1E293B) : colors.surface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    r['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        PlatformReportsCalendarButton(
          customDateRange: customDateRange,
          isCustomActive: isCustomActive,
          onCustomRangeSelected: onCustomRangeSelected,
        ),
      ],
    );
  }
}
