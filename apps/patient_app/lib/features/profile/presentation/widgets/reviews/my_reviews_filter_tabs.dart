import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class MyReviewsFilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;
  final int countAll;
  final int countDoctors;
  final int countClinics;
  final int count5Star;

  const MyReviewsFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    required this.countAll,
    required this.countDoctors,
    required this.countClinics,
    required this.count5Star,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final tabs = [
      {'key': 'all', 'label': 'All', 'count': countAll, 'icon': ''},
      {'key': 'doctors', 'label': 'Doctors Rated', 'count': countDoctors, 'icon': '👨‍⚕️ '},
      {'key': 'clinics', 'label': 'Clinic Care', 'count': countClinics, 'icon': '🏥 '},
      {'key': '5star', 'label': '5 Stars', 'count': count5Star, 'icon': '⭐⭐⭐⭐⭐ '},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeFilter == tab['key'];
          final key = tab['key'] as String;
          final label = tab['label'] as String;
          final count = tab['count'] as int;
          final icon = tab['icon'] as String;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onFilterSelected(key),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  '$icon$label ($count)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : colors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
