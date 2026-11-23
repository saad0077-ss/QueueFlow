import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors_extension.dart';

class AppFilterTriggerButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;
  final String label;

  const AppFilterTriggerButton({
    super.key,
    required this.activeCount,
    required this.onTap,
    this.label = 'Filter',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = activeCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryTint : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? colors.primary : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: isActive ? colors.primary : colors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              isActive ? 'Filters ($activeCount)' : label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isActive ? colors.primary : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
