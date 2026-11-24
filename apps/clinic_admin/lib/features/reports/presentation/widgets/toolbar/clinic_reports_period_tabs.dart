import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicReportsPeriodTabs extends StatelessWidget {
  final String activePeriod;
  final ValueChanged<String> onPeriodChanged;

  const ClinicReportsPeriodTabs({
    super.key,
    required this.activePeriod,
    required this.onPeriodChanged,
  });

  static const _tabs = [
    {'id': 'today', 'label': 'Today'},
    {'id': 'week', 'label': 'This Week'},
    {'id': 'month', 'label': 'This Month'},
    {'id': 'quarter', 'label': 'This Quarter'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _tabs.map((tab) {
          final id = tab['id']!;
          final label = tab['label']!;
          final isSelected = activePeriod == id;

          return InkWell(
            onTap: () => onPeriodChanged(id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : colors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
