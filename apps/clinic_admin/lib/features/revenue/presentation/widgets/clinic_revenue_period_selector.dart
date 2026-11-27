import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_summary.dart';

/// Segmented timeframe selector pills for Clinic Revenue views.
class ClinicRevenuePeriodSelector extends StatelessWidget {
  final ClinicRevenuePeriod activePeriod;
  final ValueChanged<ClinicRevenuePeriod> onPeriodChanged;

  const ClinicRevenuePeriodSelector({
    super.key,
    required this.activePeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 4,
        children: ClinicRevenuePeriod.values.map((period) {
          final isSelected = period == activePeriod;
          return InkWell(
            onTap: () => onPeriodChanged(period),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(
                        alpha: colors.isDark ? 0.25 : 0.12,
                      )
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                period.shortLabel,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colors.primaryLight : colors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
