import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServicesCatalogSectionHeader extends StatelessWidget {
  final int count;

  const ServicesCatalogSectionHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        Text(
          '📋 CLINICAL SERVICES CATALOG & QUOTA',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          '$count Service${count == 1 ? '' : 's'} Configured',
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        ),
      ],
    );
  }
}
