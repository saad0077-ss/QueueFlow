import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_invoice_entity.dart';
import 'platform_invoice_card_widgets.dart';

class PlatformInvoiceCompactCard extends StatelessWidget {
  final PlatformInvoiceEntity invoice;
  final ValueChanged<PlatformInvoiceEntity> onDownloadInvoice;
  final ValueChanged<PlatformInvoiceEntity> onMarkPaid;
  final ValueChanged<PlatformInvoiceEntity> onRemind;

  const PlatformInvoiceCompactCard({
    super.key,
    required this.invoice,
    required this.onDownloadInvoice,
    required this.onMarkPaid,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              Expanded(child: PlatformInvoiceCardWidgets.ref(colors, invoice)),
              PlatformInvoiceCardWidgets.statusPill(colors, invoice),
            ],
          ),
          const SizedBox(height: 8),
          PlatformInvoiceCardWidgets.clinic(colors, invoice),
          const SizedBox(height: 8),
          PlatformInvoiceCardWidgets.planBadge(colors, invoice.plan),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Due: ${invoice.dueDate}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                ),
              ),
              PlatformInvoiceCardWidgets.amount(colors, invoice),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PlatformInvoiceCardWidgets.actions(
              colors,
              invoice,
              onDownloadInvoice: onDownloadInvoice,
              onMarkPaid: onMarkPaid,
              onRemind: onRemind,
            ),
          ),
        ],
      ),
    );
  }
}
