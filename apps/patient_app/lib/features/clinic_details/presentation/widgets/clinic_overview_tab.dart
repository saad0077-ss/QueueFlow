import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicOverviewTab extends StatelessWidget {
  final String description;
  final List<String> features;

  const ClinicOverviewTab({
    super.key,
    required this.description,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.6,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((f) => _buildChip(f, colors)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label, AppColorsExtension colors) {
    final isEmergency = label.contains('24/7') || label.contains('Emergency');
    final color = isEmergency ? colors.accent : colors.textMuted;
    final bg = isEmergency
        ? colors.accentTint
        : colors.surfaceSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency
              ? colors.accent.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: isEmergency ? FontWeight.w700 : FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
