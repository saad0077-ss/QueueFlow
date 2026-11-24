import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors_extension.dart';

class AppMetricCardHeader extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final bool hasDot;
  final Color? dotColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const AppMetricCardHeader({
    super.key,
    required this.tag,
    required this.tagColor,
    this.hasDot = false,
    this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDot) ...[
              Container(
                width: 5.5,
                height: 5.5,
                decoration: BoxDecoration(
                  color: dotColor ?? tagColor,
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
    );
  }
}
