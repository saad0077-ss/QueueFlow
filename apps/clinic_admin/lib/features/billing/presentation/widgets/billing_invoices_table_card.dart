import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/billing_invoice_entity.dart';

class BillingInvoicesTableCard extends StatelessWidget {
  final String clinicName;
  final List<BillingInvoiceEntity> invoices;
  final VoidCallback onRefresh;
  final ValueChanged<BillingInvoiceEntity> onDownloadInvoice;
  final ValueChanged<BillingInvoiceEntity> onPayInvoice;

  const BillingInvoicesTableCard({
    super.key,
    required this.clinicName,
    required this.invoices,
    required this.onRefresh,
    required this.onDownloadInvoice,
    required this.onPayInvoice,
  });

  /// Below this width the table scrolls sideways instead of squashing its columns.
  static const double _minTableWidth = 980;

  // Column flex: number, date, plan, method, amount, status, actions.
  static const _flex = [20, 16, 25, 34, 12, 16, 27];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = clinicName.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice History & Receipts', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      name.isEmpty ? 'Past billing cycles and tax receipts' : 'Past billing cycles and tax receipts for $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11.5, color: colors.primaryLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: Text('Refresh', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = math.max(constraints.maxWidth, _minTableWidth);
              final table = SizedBox(
                width: width,
                child: Column(
                  children: [
                    _headerRow(colors),
                    Divider(color: colors.border, height: 1),
                    if (invoices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Text('No invoices yet. Receipts appear here after each billing cycle.',
                            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
                      )
                    else
                      for (final inv in invoices)
                        _InvoiceRow(
                          invoice: inv,
                          flex: _flex,
                          onDownload: () => onDownloadInvoice(inv),
                          onPay: () => onPayInvoice(inv),
                        ),
                  ],
                ),
              );
              if (width <= constraints.maxWidth) return table;
              return SingleChildScrollView(scrollDirection: Axis.horizontal, child: table);
            },
          ),
        ],
      ),
    );
  }

  Widget _headerRow(AppColorsExtension colors) {
    const labels = ['RECEIPT NUMBER', 'BILLING DATE', 'PLAN', 'PAYMENT METHOD', 'AMOUNT', 'STATUS', 'ACTIONS'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              flex: _flex[i],
              child: Text(
                labels[i],
                textAlign: i == labels.length - 1 ? TextAlign.right : TextAlign.left,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: colors.textMuted, letterSpacing: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatefulWidget {
  final BillingInvoiceEntity invoice;
  final List<int> flex;
  final VoidCallback onDownload;
  final VoidCallback onPay;

  const _InvoiceRow({required this.invoice, required this.flex, required this.onDownload, required this.onPay});

  @override
  State<_InvoiceRow> createState() => _InvoiceRowState();
}

class _InvoiceRowState extends State<_InvoiceRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inv = widget.invoice;
    final f = widget.flex;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: _hovered ? colors.surfaceSecondary : Colors.transparent,
          border: Border(bottom: BorderSide(color: colors.borderSubtle)),
        ),
        child: Row(
          children: [
            _cell(f[0], Text(inv.number, style: GoogleFonts.jetBrainsMono(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.primaryLight))),
            _cell(f[1], Text(inv.date, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textPrimary))),
            _cell(f[2], Align(alignment: Alignment.centerLeft, child: _planPill(inv.plan, colors))),
            _cell(f[3], Text(inv.method, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted))),
            _cell(f[4], Text(inv.amount, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w800, color: colors.textPrimary))),
            _cell(f[5], Align(alignment: Alignment.centerLeft, child: _statusPill(inv, colors))),
            Expanded(
              flex: f[6],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (inv.isPending || inv.isOverdue) ...[
                    _payButton(),
                    const SizedBox(width: 6),
                  ],
                  _viewPdfButton(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(int flex, Widget child) => Expanded(flex: flex, child: Padding(padding: const EdgeInsets.only(right: 10), child: child));

  Widget _planPill(String plan, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(plan, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: colors.primaryLight)),
    );
  }

  Widget _statusPill(BillingInvoiceEntity inv, AppColorsExtension colors) {
    final color = inv.isPaid ? colors.success : (inv.isPending ? colors.warning : colors.error);
    final bgColor = inv.isPaid ? colors.successTint : (inv.isPending ? colors.warningTint : colors.errorTint);
    final label = inv.isPaid ? 'PAID' : (inv.isPending ? 'PENDING' : 'OVERDUE');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.3)),
    );
  }

  Widget _payButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPay,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withAlpha(70), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFFB7185)),
              const SizedBox(width: 4),
              Text('Pay via Razorpay', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewPdfButton(AppColorsExtension colors) {
    return OutlinedButton(
      onPressed: widget.onDownload,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text('Download Receipt', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
