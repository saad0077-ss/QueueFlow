import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HelpSupportFilterPills extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final int totalCount;
  final int inProgressCount;
  final int resolvedCount;

  const HelpSupportFilterPills({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.totalCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildPill('All ($totalCount)', 'all', colors),
          _buildPill('In Progress ($inProgressCount)', 'active', colors),
          _buildPill('Resolved ($resolvedCount)', 'resolved', colors),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value, AppColorsExtension colors) {
    final isSelected = activeFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () => onFilterChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.textPrimary : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
