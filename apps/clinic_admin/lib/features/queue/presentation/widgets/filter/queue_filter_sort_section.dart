import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterSortSection extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const QueueFilterSortSection({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentSort,
          isExpanded: true,
          dropdownColor: colors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.textPrimary,
          ),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
          items: const [
            DropdownMenuItem(
              value: 'default',
              child: Text('Default Order'),
            ),
            DropdownMenuItem(
              value: 'waiting',
              child: Text('Highest Waiting First'),
            ),
            DropdownMenuItem(
              value: 'name',
              child: Text('Department Name (A–Z)'),
            ),
            DropdownMenuItem(
              value: 'services',
              child: Text('Most Services Configured'),
            ),
          ],
          onChanged: (v) {
            if (v != null) onSortChanged(v);
          },
        ),
      ),
    );
  }
}
