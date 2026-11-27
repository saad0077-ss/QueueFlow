import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import 'clinic_revenue_card_shell.dart';
import 'clinic_revenue_ledger_row.dart';
import 'clinic_revenue_ledger_toolbar.dart';

/// Filterable, searchable patient settlement ledger shown on the Revenue tab.
class ClinicRevenueLedgerCard extends StatelessWidget {
  final List<RevenueLedgerEntry> entries;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const ClinicRevenueLedgerCard({
    super.key,
    required this.entries,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visible = entries.take(25).toList();

    return ClinicRevenueCardShell(
      title: 'Settlements & Payment Ledger',
      subtitle: 'Recent consultation payments, pending dues & processed refunds',
      trailing: Text(
        '${entries.length} record${entries.length == 1 ? '' : 's'}',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicRevenueLedgerToolbar(
            activeFilter: activeFilter,
            onFilterChanged: onFilterChanged,
            onSearchChanged: onSearchChanged,
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No matching payment transactions found.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 740) {
                  return Column(
                    children: [
                      for (int i = 0; i < visible.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        ClinicRevenueLedgerRow(entry: visible[i], compact: true),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    _tableHeader(colors),
                    for (int i = 0; i < visible.length; i++) ...[
                      ClinicRevenueLedgerRow(entry: visible[i]),
                      if (i < visible.length - 1)
                        Divider(height: 1, color: colors.border),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(AppColorsExtension colors) {
    final style = GoogleFonts.inter(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: colors.textMuted,
      letterSpacing: 0.4,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('RECEIPT / DATE', style: style)),
          Expanded(flex: 3, child: Text('PATIENT & SERVICE', style: style)),
          Expanded(flex: 2, child: Text('METHOD', style: style)),
          Expanded(flex: 1, child: Text('STATUS', style: style)),
          Expanded(
            flex: 2,
            child: Text('AMOUNT', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}
