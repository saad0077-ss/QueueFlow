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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _pill(context, id: 'all', label: 'All', count: countAll),
        _pill(
          context,
          id: 'open',
          label: 'Open',
          count: countOpen,
          activeColor: const Color(0xFFEF4444),
        ),
        _pill(
          context,
          id: 'in_progress',
          label: 'In Progress',
          count: countInProgress,
          activeColor: const Color(0xFFF59E0B),
        ),
        _pill(
          context,
          id: 'resolved',
          label: 'Resolved',
          count: countResolved,
          activeColor: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _pill(
    BuildContext context, {
    required String id,
    required String label,
    required int count,
    Color activeColor = const Color(0xFF2563EB),
  }) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final isSel = selectedStatus == id;

    return InkWell(
      onTap: () => onStatusChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSel
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSel
                ? activeColor
                : (isDark ? const Color(0xFF1E293B) : colors.border),
            width: isSel ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel
                    ? (isDark ? Colors.white : activeColor)
                    : colors.textMuted,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSel
                    ? activeColor
                    : (isDark
                          ? const Color(0xFF1E293B)
                          : colors.surfaceSecondary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.white : colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
