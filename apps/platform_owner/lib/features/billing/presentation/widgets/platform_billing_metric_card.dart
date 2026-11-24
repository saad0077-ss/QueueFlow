import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformBillingMetricCard extends StatelessWidget {
  final String tag;
  final String label;
  final String value;
  final String trend;
  final String subtext;
  final IconData icon;
  final Color themeColor;

  const PlatformBillingMetricCard({
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

    return AppMetricCard(
      tag: tag,
      tagColor: themeColor,
      label: label,
      value: value,
      icon: icon,
      iconColor: themeColor,
      iconBgColor: themeColor.withValues(alpha: 0.15),
      borderColor: themeColor.withValues(alpha: 0.35),
      bottomWidget: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trend,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: themeColor,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              subtext,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                color: colors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
