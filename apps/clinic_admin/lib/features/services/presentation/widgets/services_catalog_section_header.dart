import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServicesCatalogSectionHeader extends StatelessWidget {
  final int count;

  const ServicesCatalogSectionHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFFCBD5E1),
            letterSpacing: 0.6,
          ),
        ),
        Text(
          '$count Service${count == 1 ? '' : 's'} Configured',
          style: GoogleFonts.inter(fontSize: 12.5, color: ServiceColors.muted),
        ),
      ],
    );
  }
}
