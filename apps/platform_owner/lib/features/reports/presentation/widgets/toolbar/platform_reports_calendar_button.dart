import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_reports_date_dialog.dart';

class PlatformReportsCalendarButton extends StatelessWidget {
  final DateTimeRange? customDateRange;
  final bool isCustomActive;
  final ValueChanged<DateTimeRange?> onCustomRangeSelected;

  const PlatformReportsCalendarButton({
    super.key,
    required this.customDateRange,
    required this.isCustomActive,
    required this.onCustomRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    String label = 'Date Range';
    if (isCustomActive && customDateRange != null) {
      final s = customDateRange!.start;
      final e = customDateRange!.end;
      label = '${_fmt(s)} – ${_fmt(e)}';
    }

    return InkWell(
      onTap: () => _openDateDialog(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isCustomActive
              ? colors.primary.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCustomActive ? colors.primary : colors.border,
            width: isCustomActive ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 15,
              color: isCustomActive ? colors.primary : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isCustomActive ? FontWeight.w700 : FontWeight.w500,
                color: isCustomActive ? colors.primary : colors.textPrimary,
              ),
            ),
            if (isCustomActive) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => onCustomRangeSelected(null),
                child: Icon(Icons.close_rounded, size: 14, color: colors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openDateDialog(BuildContext context) {
    PlatformReportsDateDialog.show(
      context,
      initialRange: customDateRange,
      onApply: onCustomRangeSelected,
    );
  }

  static String _fmt(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
