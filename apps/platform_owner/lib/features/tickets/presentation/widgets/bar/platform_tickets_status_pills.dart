import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketsStatusPills extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final int countAll;
  final int countOpen;
  final int countInProgress;
  final int countResolved;

  const PlatformTicketsStatusPills({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.countAll,
    required this.countOpen,
    required this.countInProgress,
    required this.countResolved,
  });

  Widget _statusPill(BuildContext context, String key, String label) {
    final colors = context.colors;
    final isSel = selectedStatus == key;

    return InkWell(
      onTap: () => onStatusChanged(key),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
            color: isSel ? Colors.white : colors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0F19) : colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          _statusPill(context, 'all', 'All ($countAll)'),
          _statusPill(context, 'open', 'Open ($countOpen)'),
          _statusPill(context, 'in_progress', 'In Progress ($countInProgress)'),
          _statusPill(context, 'resolved', 'Resolved ($countResolved)'),
        ],
      ),
    );
  }
}
