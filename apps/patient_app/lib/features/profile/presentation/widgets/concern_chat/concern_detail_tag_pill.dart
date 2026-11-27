import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ellipsis-safe context pill used for clinic name, linked token, and category.
class ConcernDetailTagPill extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color border;
  final bool isMono;

  const ConcernDetailTagPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.border,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isMono
                  ? GoogleFonts.firaCode(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    )
                  : GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
