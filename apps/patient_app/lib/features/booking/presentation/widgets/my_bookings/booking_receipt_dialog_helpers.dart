import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingReceiptDialogHelpers {
  static Widget pill(String text, Color color, {double size = 10.5}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static Widget dlgRow(
    BuildContext context,
    String k,
    String v, {
    Color? color,
    bool mono = false,
    double size = 13,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.robotoMono(
                      fontSize: size,
                      fontWeight: FontWeight.w700,
                      color: color ?? colors.textPrimary,
                    )
                  : GoogleFonts.inter(
                      fontSize: size,
                      fontWeight: FontWeight.w700,
                      color: color ?? colors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget dlgBox(
    BuildContext context,
    Color border,
    List<Widget> children,
  ) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
