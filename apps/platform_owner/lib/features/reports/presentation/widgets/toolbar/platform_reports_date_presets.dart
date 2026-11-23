import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlatformReportsDatePresets extends StatelessWidget {
  final String? selectedPreset;
  final ValueChanged<String> onSelectPreset;

  const PlatformReportsDatePresets({
    super.key,
    required this.selectedPreset,
    required this.onSelectPreset,
  });

  static const _presets = [
    {'key': '7d', 'label': 'Last 7 Days'},
    {'key': '30d', 'label': 'Last 30 Days'},
    {'key': '90d', 'label': 'Last 90 Days'},
    {'key': 'month', 'label': 'This Month'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.map((p) {
        final sel = selectedPreset == p['key'];
        return InkWell(
          onTap: () => onSelectPreset(p['key']!),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF0284C7).withValues(alpha: 0.2) : const Color(0xFF0B0F19),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: sel ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
                width: sel ? 1.4 : 1.0,
              ),
            ),
            child: Text(
              p['label']!,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? const Color(0xFF38BDF8) : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
