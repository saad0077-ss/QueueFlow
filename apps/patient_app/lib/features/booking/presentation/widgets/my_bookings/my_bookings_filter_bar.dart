import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterTab(context, 0, 'Upcoming'),
          const SizedBox(width: 8),
          _buildFilterTab(context, 1, 'Completed'),
          const SizedBox(width: 8),
          _buildFilterTab(context, 2, 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, int index, String label) {
    final colors = context.colors;
    final isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
