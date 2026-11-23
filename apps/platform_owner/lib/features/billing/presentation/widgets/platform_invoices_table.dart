import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_invoice_entity.dart';
import 'platform_invoice_card_widgets.dart';

class PlatformInvoicesTable extends StatelessWidget {
  final List<PlatformInvoiceEntity> invoices;
  final double availableWidth;
  final ValueChanged<PlatformInvoiceEntity> onDownloadInvoice;
  final ValueChanged<PlatformInvoiceEntity> onMarkPaid;
  final ValueChanged<PlatformInvoiceEntity> onRemind;

  const PlatformInvoicesTable({
    super.key,
    required this.invoices,
    required this.availableWidth,
    required this.onDownloadInvoice,
    required this.onMarkPaid,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const minWidth = 1200.0;
    final width = availableWidth < minWidth ? minWidth : availableWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _headerCell(colors, 'INVOICE REF', flex: 18),
                  _headerCell(colors, 'TENANT CLINIC', flex: 24),
                  _headerCell(colors, 'PLAN TIER', flex: 16),
                  _headerCell(colors, 'ISSUED', flex: 14),
                  _headerCell(colors, 'DUE DATE', flex: 14),
                  _headerCell(colors, 'AMOUNT', flex: 16),
                  _headerCell(colors, 'STATUS', flex: 14),
                  const Expanded(flex: 32, child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ...invoices.map((inv) => _tableRow(colors, inv)),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    AppColorsExtension colors,
    String text, {
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: colors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tableRow(AppColorsExtension colors, PlatformInvoiceEntity inv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border.withAlpha(50))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 18,
            child: PlatformInvoiceCardWidgets.ref(colors, inv),
          ),
          Expanded(
            flex: 24,
            child: PlatformInvoiceCardWidgets.clinic(colors, inv),
          ),
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PlatformInvoiceCardWidgets.planBadge(colors, inv.plan),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              inv.date,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              inv.dueDate,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 16,
            child: PlatformInvoiceCardWidgets.amount(colors, inv),
          ),
          Expanded(
            flex: 14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PlatformInvoiceCardWidgets.statusPill(colors, inv),
            ),
          ),
          Expanded(
            flex: 32,
            child: Align(
              alignment: Alignment.centerRight,
              child: PlatformInvoiceCardWidgets.actions(
                colors,
                inv,
                onDownloadInvoice: onDownloadInvoice,
                onMarkPaid: onMarkPaid,
                onRemind: onRemind,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
