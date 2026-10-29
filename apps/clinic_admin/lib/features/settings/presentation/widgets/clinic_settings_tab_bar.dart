import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicSettingsTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const ClinicSettingsTabBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      'Clinic Profile',
      'Location & Map',
      'Operating Hours',
      'Queue Rules',
      'Security',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = i == activeIndex;
            return InkWell(
              onTap: () => onTabSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
