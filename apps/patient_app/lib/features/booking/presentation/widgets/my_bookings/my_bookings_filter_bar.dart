import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'package:patient_app/core/layout/patient_breakpoints.dart';

class MyBookingsFilterBar extends StatelessWidget {
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;

  const MyBookingsFilterBar({
    super.key,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isLaptop = PatientBreakpoints.isLaptop(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLaptop ? 640 : 480,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : colors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTab(context, 0, 'Upcoming')),
              Expanded(child: _buildTab(context, 1, 'Completed')),
              Expanded(child: _buildTab(context, 2, 'Cancelled')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    final colors = context.colors;
    final isSelected = selectedFilterIndex == index;

    return GestureDetector(
      onTap: () => onFilterChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
