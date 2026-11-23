import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformRevenueHeaderActions extends StatelessWidget {
  final VoidCallback onExportLedger;

  const PlatformRevenueHeaderActions({
    super.key,
    required this.onExportLedger,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OutlinedButton.icon(
      onPressed: onExportLedger,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        backgroundColor: colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
      label: Text(
        'Export Ledger (PDF)',
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
