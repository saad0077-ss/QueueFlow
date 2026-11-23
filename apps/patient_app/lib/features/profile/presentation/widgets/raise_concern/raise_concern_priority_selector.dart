import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;
  final AppColorsExtension colors;

  const RaiseConcernPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.colors,
  });

  static const List<Map<String, String>> priorities = [
    {'id': 'low', 'title': 'Standard', 'sub': '< 25m SLA'},
    {'id': 'medium', 'title': 'In-Clinic', 'sub': '< 15m SLA'},
    {'id': 'high', 'title': 'Urgent SOS', 'sub': '< 5m SLA'},
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
              'Urgency / Priority *',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
            Text(
              'Affects triage speed',
              style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: priorities.map((p) {
            final isSelected = selectedPriority == p['id'];
            final isUrgent = p['id'] == 'high';

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onPriorityChanged(p['id']!),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isUrgent
                                ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                : const Color(0xFF2563EB)
                                      .withValues(alpha: 0.08))
                          : colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? (isUrgent
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF2563EB))
                            : colors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          p['title']!,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isUrgent && isSelected
                                ? const Color(0xFFEF4444)
                                : (isSelected
                                      ? const Color(0xFF2563EB)
                                      : colors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p['sub']!,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: colors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
