import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import 'clinic_revenue_period_selector.dart';

/// Top header for the Clinic Revenue tab with timeframe switcher and PDF export.
class ClinicRevenueHeader extends StatelessWidget {
  final ClinicRevenuePeriod activePeriod;
  final bool isRefreshing;
  final ValueChanged<ClinicRevenuePeriod> onPeriodChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onExportPdf;

  const ClinicRevenueHeader({
    super.key,
    required this.activePeriod,
    required this.isRefreshing,
    required this.onPeriodChanged,
    required this.onRefresh,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinic Revenue & Settlements',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time Razorpay collections, walk-in queue earnings, service share & ledger',
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ClinicRevenuePeriodSelector(
          activePeriod: activePeriod,
          onPeriodChanged: onPeriodChanged,
        ),
        IconButton(
          onPressed: isRefreshing ? null : onRefresh,
          tooltip: 'Refresh revenue data',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            side: BorderSide(color: colors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(
            Icons.refresh_rounded,
            size: 18,
            color: colors.textPrimary,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onExportPdf,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            backgroundColor: colors.surface,
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 15),
          label: Text(
            'Export Ledger',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 14), controls],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            controls,
          ],
        );
      },
    );
  }
}
