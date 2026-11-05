import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformBillingKpiCard extends StatelessWidget {
  final String tag;
  final String label;
  final String value;
  final String trend;
  final String subtext;
  final IconData icon;
  final Color themeColor;

  const PlatformBillingKpiCard({
    super.key,
    required this.tag,
    required this.label,
    required this.value,
    required this.trend,
    required this.subtext,
    required this.icon,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: themeColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: themeColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(trend, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: themeColor)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(subtext, style: GoogleFonts.inter(fontSize: 11, color: colors.textSubtle), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
