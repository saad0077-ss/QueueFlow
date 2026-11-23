import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformBillingHeader extends StatelessWidget {
  final VoidCallback onIssueInvoice;
  final VoidCallback onExportPdf;
  final VoidCallback? onSync;

  const PlatformBillingHeader({
    super.key,
    required this.onIssueInvoice,
    required this.onExportPdf,
    this.onSync,
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
                'Platform Plans & Billing Command',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Multi-clinic subscription tiers, automated invoicing, MRR collection and clinic upgrade controls',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: onIssueInvoice,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                'Issue Invoice',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onExportPdf,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border),
                backgroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.download_rounded, size: 15),
              label: Text(
                'Export PDF',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
