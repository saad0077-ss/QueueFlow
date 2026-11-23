import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicTicketsHeaderActions extends StatelessWidget {
  final VoidCallback onLogTicket;
  final VoidCallback? onSync;
  final VoidCallback? onExportPdf;

  const ClinicTicketsHeaderActions({
    super.key,
    required this.onLogTicket,
    this.onSync,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onExportPdf != null)
          OutlinedButton.icon(
            onPressed: onExportPdf,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: colors.border),
            ),
            icon: Icon(
              Icons.picture_as_pdf_outlined,
              size: 15,
              color: colors.textPrimary,
            ),
            label: Text(
              'Export PDF',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: onLogTicket,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: Text(
            'Log Patient Ticket',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
