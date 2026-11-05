import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HoursPolicyDropdown extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int> onChanged;

  const HoursPolicyDropdown({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: items.any((i) => i.value == value) ? value : items.first.value,
              dropdownColor: colors.surfaceElevated,
              isExpanded: true,
              icon: Icon(icon, size: 16, color: colors.textMuted),
              style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              items: items,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
