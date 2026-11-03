import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const _muted = Color(0xFF94A3B8);
  static const _divider = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Container(
          padding: EdgeInsets.fromLTRB(isCompact ? 16 : 26, 24, isCompact ? 16 : 26, 26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (isCompact) _title() else Expanded(child: _title()),
                  SizedBox(width: 16, height: isCompact ? 12 : 0),
                  _filterBar(),
                ],
              ),
              const SizedBox(height: 18),
              if (invoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text('No invoices in this view.', style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B))),
                )
              else if (isCompact)
                ...invoices.map(_compactCard)
              else
                _table(constraints.maxWidth - 52),
            ],
          ),
        );
      },
    );
  }

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Platform Invoices & Receivables', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text('Global ledger of all tenant invoices and collection states', style: GoogleFonts.inter(fontSize: 12.5, color: _muted)),
      ],
    );
  }

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
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
                color: isSel ? const Color(0xFF2563EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                f['label']!,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w600, color: isSel ? Colors.white : const Color(0xFFCBD5E1)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _table(double available) {
    const minWidth = 1200.0;
    final width = available < minWidth ? minWidth : available;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            _headerRow(),
            const Divider(color: _divider, height: 1),
            ...invoices.map(_dataRow),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    Widget h(String t, {TextAlign align = TextAlign.left}) => Text(
          t.toUpperCase(),
          textAlign: align,
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.8),
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

  Widget _dataRow(PlatformInvoiceEntity inv) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _divider))),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 16, child: _ref(inv)),
          Expanded(flex: 21, child: _clinic(inv)),
          Expanded(flex: 19, child: Align(alignment: Alignment.centerLeft, child: _planBadge(inv.plan))),
          Expanded(flex: 11, child: Text(inv.dueDate, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: Colors.white))),
          Expanded(flex: 9, child: _amount(inv)),
          Expanded(flex: 14, child: Align(alignment: Alignment.centerLeft, child: _statusPill(inv))),
          Expanded(
            flex: 32,
            child: Align(alignment: Alignment.centerRight, child: _actions(inv)),
          ),
        ],
      ),
    );
  }

  Widget _compactCard(PlatformInvoiceEntity inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _ref(inv)),
              _statusPill(inv),
            ],
          ),
          const SizedBox(height: 8),
          _clinic(inv),
          const SizedBox(height: 8),
          _planBadge(inv.plan),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Due: ${inv.dueDate}', overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12.5, color: _muted))),
              _amount(inv),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: _actions(inv)),
        ],
      ),
    );
  }

  Widget _ref(PlatformInvoiceEntity inv) => Text(
        inv.number,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6)),
      );

  Widget _clinic(PlatformInvoiceEntity inv) => Text(
        inv.clinicName,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
      );

  Widget _amount(PlatformInvoiceEntity inv) => Text(
        inv.amount,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      );

  Widget _actions(PlatformInvoiceEntity inv) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _actionButton('PDF', Colors.white, const Color(0xFF334155), () => onDownloadInvoice(inv)),
        if (!inv.isPaid) ...[
          _actionButton('Mark Paid', const Color(0xFF22C55E), const Color(0xFF22C55E), () => onMarkPaid(inv)),
          _actionButton('Remind', Colors.white, const Color(0xFF334155), () => onRemind(inv)),
        ],
      ],
    );
  }

  Widget _actionButton(String label, Color fg, Color border, VoidCallback onTap) {
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

  Widget _planBadge(String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withAlpha(110), borderRadius: BorderRadius.circular(8)),
      child: Text(planName, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
    );
  }

  Widget _statusPill(PlatformInvoiceEntity inv) {
    final color = inv.isPaid ? const Color(0xFF22C55E) : (inv.isPending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    final label = inv.isPaid ? 'PAID' : (inv.isPending ? 'PENDING' : 'CANCELLED');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
    );
  }
}
