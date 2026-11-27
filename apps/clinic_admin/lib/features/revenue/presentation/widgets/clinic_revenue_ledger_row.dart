import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_ledger_compact_tile.dart';
import 'clinic_revenue_status_badge.dart';

/// Displays a single transaction record in either table row or compact card form.
class ClinicRevenueLedgerRow extends StatelessWidget {
  final RevenueLedgerEntry entry;
  final bool compact;

  const ClinicRevenueLedgerRow({
    super.key,
    required this.entry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = ClinicRevenueStatusBadge.colorFor(entry.status);
    final amountText = ClinicRevenueFormatter.formatInr(
      entry.status == 'pending' ? entry.grossAmount : entry.netAmount,
    );

    if (compact) {
      return ClinicRevenueLedgerCompactTile(
        entry: entry,
        amountText: amountText,
        statusColor: fg,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _twoLineCell(
              entry.receiptNo,
              entry.dateLabel,
              GoogleFonts.jetBrainsMono(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.primaryLight,
              ),
              GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 3,
            child: _twoLineCell(
              entry.patientName,
              '${entry.serviceName} • ${entry.doctorName}',
              GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.method,
              style: GoogleFonts.inter(fontSize: 11.5, color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClinicRevenueStatusBadge(status: entry.status),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (entry.refundAmount > 0)
                  Text(
                    '-${ClinicRevenueFormatter.formatInr(entry.refundAmount)} refund',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoLineCell(
    String primary,
    String secondary,
    TextStyle primaryStyle,
    TextStyle secondaryStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(primary, style: primaryStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(secondary, style: secondaryStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
