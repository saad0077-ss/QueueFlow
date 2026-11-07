import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicsHeaderBar extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onRefresh;
  final VoidCallback onOnboard;
  final int activeCount;
  final int totalCount;

  const ClinicsHeaderBar({
    super.key,
    required this.onExportPdf,
    required this.onRefresh,
    required this.onOnboard,
    required this.activeCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.badgeOpenBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.success.withValues(alpha: 0.5)),
              ),
              child: Text(
                'NETWORK MANAGEMENT  •  $activeCount of $totalCount Facilities Active',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.badgeOpenText),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform Clinics Directory',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.4),
            ),
            const SizedBox(height: 4),
            Text(
              'All healthcare facilities onboarded on QueueFlow • Subscription tiers, doctor capacity & live queue triage',
              style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
            ),
          ],
        );

        final actionRow = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onExportPdf,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                backgroundColor: colors.surface,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text('Export PDF', style: TextStyle(fontSize: 12.5)),
            ),
            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                backgroundColor: colors.surface,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh', style: TextStyle(fontSize: 12.5)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton.icon(
                onPressed: onOnboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Onboard Clinic', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleCol, const SizedBox(height: 16), actionRow],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: titleCol), const SizedBox(width: 16), actionRow],
        );
      },
    );
  }
}
