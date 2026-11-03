import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF162238),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: items.any((i) => i.value == value) ? value : items.first.value,
              dropdownColor: const Color(0xFF0F172A),
              isExpanded: true,
              icon: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
