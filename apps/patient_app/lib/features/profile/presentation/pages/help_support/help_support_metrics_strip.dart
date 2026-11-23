import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HelpSupportMetricsStrip extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int resolvedCount;

  const HelpSupportMetricsStrip({
    super.key,
    required this.totalCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        _buildStatCard(colors, '$totalCount', 'Total', null),
        const SizedBox(width: 8),
        _buildStatCard(
          colors,
          '$inProgressCount',
          'In Review',
          const Color(0xFF0072FF),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          colors,
          '$resolvedCount',
          'Resolved',
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 8),
        _buildStatCard(colors, '12m', 'Avg SLA', const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildStatCard(
    AppColorsExtension colors,
    String value,
    String label,
    Color? valColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valColor ?? colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
