import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final AppColorsExtension colors;

  const RaiseConcernCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.colors,
  });

  static const List<Map<String, String>> categories = [
    {
      'id': 'queue',
      'icon': '⏱️',
      'title': 'Queue & Token Delay',
      'sub': 'Waiting room delay, skipped turn',
    },
    {
      'id': 'booking',
      'icon': '📅',
      'title': 'Appointments & Booking',
      'sub': 'Reschedule slot, doctor change',
    },
    {
      'id': 'billing',
      'icon': '💳',
      'title': 'Billing & Payments',
      'sub': 'Receipt, double charge, refund',
    },
    {
      'id': 'doctor',
      'icon': '🩺',
      'title': 'Doctor & Care Quality',
      'sub': 'Medical triage, care inquiry',
    },
    {
      'id': 'technical',
      'icon': '📱',
      'title': 'App Technical Bug',
      'sub': 'GPS radar, notification error',
    },
    {
      'id': 'feedback',
      'icon': '💬',
      'title': 'General Clinic Feedback',
      'sub': 'Parking, facilities, directions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Issue Category *',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
            Text(
              'Select area of concern',
              style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              dropdownColor: colors.surface,
              borderRadius: BorderRadius.circular(14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.textMuted,
                size: 22,
              ),
              items: categories.map((cat) {
                final isSelected = cat['id'] == selectedCategory;
                return DropdownMenuItem<String>(
                  value: cat['id'],
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                              : colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cat['icon']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              cat['sub']!,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: colors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onCategorySelected(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
