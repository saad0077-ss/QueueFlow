import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketsKpiCardItem extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final bool hasRedDot;
  final String label;
  final String value;
  final Color valueColor;
  final Widget bottomWidget;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;

  const PlatformTicketsKpiCardItem({
    super.key,
    required this.tag,
    required this.tagColor,
    this.hasRedDot = false,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bottomWidget,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? borderColor : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (hasRedDot) ...[
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? iconBgColor : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          bottomWidget,
        ],
      ),
    );
  }
}
