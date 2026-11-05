import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformBillingHeader extends StatelessWidget {
  final VoidCallback onIssueInvoice;
  final VoidCallback onExportCsv;
  final VoidCallback onSync;

  const PlatformBillingHeader({
    super.key,
    required this.onIssueInvoice,
    required this.onExportCsv,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('ENTERPRISE REVENUE ENGINE • ACTIVE', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.primaryLight, letterSpacing: 0.5)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 13, color: colors.textMuted),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      text: 'MRR Collection: ',
                      style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
                      children: [
                        TextSpan(text: '94.2% On Time', style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Plans & Billing Command', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Multi-clinic subscription tiers, automated invoicing, MRR collection and clinic upgrade controls', style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted)),
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
                  label: Text('Issue Invoice', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                OutlinedButton.icon(
                  onPressed: onExportCsv,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: Text('Export CSV', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                OutlinedButton.icon(
                  onPressed: onSync,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.sync_rounded, size: 15),
                  label: Text('Sync', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
