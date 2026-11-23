import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_invoice_entity.dart';

class PlatformInvoiceCardWidgets {
  static Widget ref(AppColorsExtension colors, PlatformInvoiceEntity inv) =>
      Text(
        inv.number,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.primaryLight,
        ),
      );

  static Widget clinic(AppColorsExtension colors, PlatformInvoiceEntity inv) =>
      Text(
        inv.clinicName,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      );

  static Widget amount(AppColorsExtension colors, PlatformInvoiceEntity inv) =>
      Text(
        inv.amount,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      );

  static Widget planBadge(AppColorsExtension colors, String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        planName,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.primaryLight,
        ),
      ),
    );
  }

  static Widget statusPill(
    AppColorsExtension colors,
    PlatformInvoiceEntity inv,
  ) {
    final color = inv.isPaid
        ? colors.success
        : (inv.isPending ? colors.warning : colors.error);
    final label = inv.isPaid
        ? 'PAID'
        : (inv.isPending ? 'PENDING' : 'CANCELLED');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static Widget actions(
    AppColorsExtension colors,
    PlatformInvoiceEntity inv, {
    required ValueChanged<PlatformInvoiceEntity> onDownloadInvoice,
    required ValueChanged<PlatformInvoiceEntity> onMarkPaid,
    required ValueChanged<PlatformInvoiceEntity> onRemind,
  }) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        _btn(
          label: 'PDF',
          fg: colors.textPrimary,
          border: colors.border,
          onTap: () => onDownloadInvoice(inv),
        ),
        if (!inv.isPaid) ...[
          _btn(
            label: 'Mark Paid',
            fg: colors.success,
            border: colors.success,
            onTap: () => onMarkPaid(inv),
          ),
          _btn(
            label: 'Remind',
            fg: colors.textPrimary,
            border: colors.border,
            onTap: () => onRemind(inv),
          ),
        ],
      ],
    );
  }

  static Widget _btn({
    required String label,
    required Color fg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
