import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.6,
            color: AppColors.darkInkMuted,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map(_buildChip).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    final isEmergency = label.contains('24/7') || label.contains('Emergency');
    final color = isEmergency ? AppColors.accent : AppColors.darkInkMuted;
    final bg = isEmergency
        ? AppColors.accent.withValues(alpha: 0.12)
        : AppColors.darkSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.darkBorder,
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
