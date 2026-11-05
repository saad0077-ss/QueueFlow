import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/platform_invoice_entity.dart';

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
          padding: EdgeInsets.fromLTRB(isCompact ? 16 : 26, 24, isCompact ? 16 : 26, 26),
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
                crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (isCompact) _title(colors) else Expanded(child: _title(colors)),
                  SizedBox(width: 16, height: isCompact ? 12 : 0),
                  _filterBar(colors),
                ],
              ),
              const SizedBox(height: 18),
              if (invoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text('No invoices in this view.', style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
                )
              else if (isCompact)
                ...invoices.map((inv) => _compactCard(colors, inv))
              else
                _table(colors, constraints.maxWidth - 52),
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
        Text('Platform Invoices & Receivables', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary)),
        const SizedBox(height: 2),
        Text('Global ledger of all tenant invoices and collection states', style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
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
                style: GoogleFonts.inter(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w600, color: isSel ? Colors.white : colors.textMuted),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _table(AppColorsExtension colors, double available) {
    const minWidth = 1200.0;
    final width = available < minWidth ? minWidth : available;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            _headerRow(colors),
            Divider(color: colors.border, height: 1),
            ...invoices.map((inv) => _dataRow(colors, inv)),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(AppColorsExtension colors) {
    Widget h(String t, {TextAlign align = TextAlign.left}) => Text(
          t.toUpperCase(),
          textAlign: align,
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted, letterSpacing: 0.8),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 16, child: h('Invoice Ref')),
          Expanded(flex: 21, child: h('Clinic')),
          Expanded(flex: 19, child: h('Plan')),
          Expanded(flex: 11, child: h('Due Date')),
          Expanded(flex: 9, child: h('Amount')),
          Expanded(flex: 14, child: h('Status')),
          Expanded(flex: 32, child: h('Actions', align: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _dataRow(AppColorsExtension colors, PlatformInvoiceEntity inv) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 16, child: _ref(colors, inv)),
          Expanded(flex: 21, child: _clinic(colors, inv)),
          Expanded(flex: 19, child: Align(alignment: Alignment.centerLeft, child: _planBadge(colors, inv.plan))),
          Expanded(flex: 11, child: Text(inv.dueDate, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary))),
          Expanded(flex: 9, child: _amount(colors, inv)),
          Expanded(flex: 14, child: Align(alignment: Alignment.centerLeft, child: _statusPill(colors, inv))),
          Expanded(
            flex: 32,
            child: Align(alignment: Alignment.centerRight, child: _actions(colors, inv)),
          ),
        ],
      ),
    );
  }

  Widget _compactCard(AppColorsExtension colors, PlatformInvoiceEntity inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _ref(colors, inv)),
              _statusPill(colors, inv),
            ],
          ),
          const SizedBox(height: 8),
          _clinic(colors, inv),
          const SizedBox(height: 8),
          _planBadge(colors, inv.plan),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Due: ${inv.dueDate}', overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted))),
              _amount(colors, inv),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: _actions(colors, inv)),
        ],
      ),
    );
  }

  Widget _ref(AppColorsExtension colors, PlatformInvoiceEntity inv) => Text(
        inv.number,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primaryLight),
      );

  Widget _clinic(AppColorsExtension colors, PlatformInvoiceEntity inv) => Text(
        inv.clinicName,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.textPrimary),
      );

  Widget _amount(AppColorsExtension colors, PlatformInvoiceEntity inv) => Text(
        inv.amount,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
      );

  Widget _actions(AppColorsExtension colors, PlatformInvoiceEntity inv) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _actionButton(label: 'PDF', fg: colors.textPrimary, border: colors.border, onTap: () => onDownloadInvoice(inv)),
        if (!inv.isPaid) ...[
          _actionButton(label: 'Mark Paid', fg: colors.success, border: colors.success, onTap: () => onMarkPaid(inv)),
          _actionButton(label: 'Remind', fg: colors.textPrimary, border: colors.border, onTap: () => onRemind(inv)),
        ],
      ],
    );
  }

  Widget _actionButton({required String label, required Color fg, required Color border, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _planBadge(AppColorsExtension colors, String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: colors.primaryTint, borderRadius: BorderRadius.circular(8)),
      child: Text(planName, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.primaryLight)),
    );
  }

  Widget _statusPill(AppColorsExtension colors, PlatformInvoiceEntity inv) {
    final color = inv.isPaid ? colors.success : (inv.isPending ? colors.warning : colors.error);
    final label = inv.isPaid ? 'PAID' : (inv.isPending ? 'PENDING' : 'CANCELLED');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
    );
  }
}
