import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernClinicToggle extends StatelessWidget {
  final bool isClinicRelated;
  final ValueChanged<bool> onToggle;
  final AppColorsExtension colors;

  const RaiseConcernClinicToggle({
    super.key,
    required this.isClinicRelated,
    required this.onToggle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Is this related to a specific clinic?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Live queue delays, doctor consults & appointments',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isClinicRelated,
            activeTrackColor: const Color(0xFF2563EB),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
