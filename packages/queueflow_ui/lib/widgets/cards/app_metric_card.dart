import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors_extension.dart';
import 'app_metric_card_header.dart';

/// Reusable executive metric / KPI card used across QueueFlow dashboards,
/// support ticket consoles, and reports.
class AppMetricCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final bool hasDot;
  final Color? dotColor;
  final String label;
  final Color? labelColor;
  final String value;
  final Color? valueColor;
  final Widget? bottomWidget;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  const AppMetricCard({
    super.key,
    required this.tag,
    required this.tagColor,
    this.hasDot = false,
    this.dotColor,
    required this.label,
    this.labelColor,
    required this.value,
    this.valueColor,
    this.bottomWidget,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
    this.height = 108,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final radius = borderRadius ?? BorderRadius.circular(12);

    final cardContent = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surface,
        borderRadius: radius,
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
          AppMetricCardHeader(
            tag: tag,
            tagColor: tagColor,
            hasDot: hasDot,
            dotColor: dotColor,
            icon: icon,
            iconColor: iconColor,
            iconBgColor: iconBgColor,
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
                  color: valueColor ?? colors.textPrimary,
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
                    color: labelColor ?? colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (bottomWidget != null) bottomWidget!,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: radius is BorderRadius ? radius : BorderRadius.circular(12),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
