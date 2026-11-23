import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_invoice_entity.dart';
import 'platform_invoice_compact_card.dart';
import 'platform_invoices_table.dart';

class PlatformInvoicesLedgerView extends StatelessWidget {
  final List<PlatformInvoiceEntity> invoices;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<PlatformInvoiceEntity> onDownloadInvoice;
  final ValueChanged<PlatformInvoiceEntity> onMarkPaid;
  final ValueChanged<PlatformInvoiceEntity> onRemind;

  const PlatformInvoicesLedgerView({
    super.key,
    required this.invoices,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onDownloadInvoice,
    required this.onMarkPaid,
    required this.onRemind,
  });

  static const _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'completed', 'label': 'Paid'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'cancelled', 'label': 'Overdue'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Container(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 16 : 26,
            24,
            isCompact ? 16 : 26,
            26,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (isCompact)
                    _title(colors)
                  else
                    Expanded(child: _title(colors)),
                  SizedBox(width: 16, height: isCompact ? 12 : 0),
                  _filterBar(colors),
                ],
              ),
              const SizedBox(height: 18),
              if (invoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    'No invoices in this view.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: colors.textMuted,
                    ),
                  ),
                )
              else if (isCompact)
                ...invoices.map(
                  (inv) => PlatformInvoiceCompactCard(
                    invoice: inv,
                    onDownloadInvoice: onDownloadInvoice,
                    onMarkPaid: onMarkPaid,
                    onRemind: onRemind,
                  ),
                )
              else
                PlatformInvoicesTable(
                  invoices: invoices,
                  availableWidth: constraints.maxWidth - 52,
                  onDownloadInvoice: onDownloadInvoice,
                  onMarkPaid: onMarkPaid,
                  onRemind: onRemind,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _title(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Platform Invoices & Receivables',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Global ledger of all tenant invoices and collection states',
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        ),
      ],
    );
  }

  Widget _filterBar(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((f) {
          final isSel = activeFilter == f['key'];
          return GestureDetector(
            onTap: () => onFilterChanged(f['key']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                f['label']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                  color: isSel ? Colors.white : colors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
