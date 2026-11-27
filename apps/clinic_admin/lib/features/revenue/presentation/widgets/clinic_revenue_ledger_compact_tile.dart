import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import 'clinic_revenue_status_badge.dart';

/// Compact mobile transaction card used when horizontal space is below 740px.
class ClinicRevenueLedgerCompactTile extends StatelessWidget {
  final RevenueLedgerEntry entry;
  final String amountText;
  final Color statusColor;

  const ClinicRevenueLedgerCompactTile({
    super.key,
    required this.entry,
    required this.amountText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: colors.isDark ? 0.5 : 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.patientName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amountText,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.serviceName} • ${entry.doctorName}',
            style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${entry.receiptNo} • ${entry.method}',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ClinicRevenueStatusBadge(status: entry.status),
            ],
          ),
        ],
      ),
    );
  }
}
