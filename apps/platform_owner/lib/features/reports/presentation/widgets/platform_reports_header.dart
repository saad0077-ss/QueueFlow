import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformReportsHeader extends StatelessWidget {
  final VoidCallback onExportPdf;

  const PlatformReportsHeader({
    super.key,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview Reports',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cross-clinic queue performance, patient throughput, subscription plan adoption & MRR growth',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onExportPdf,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.border),
            backgroundColor: colors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
          label: Text(
            'Export PDF',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
