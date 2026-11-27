import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_revenue_equal_height_row.dart';

/// Shared card container and header used across Clinic Revenue analytics sections.
class ClinicRevenueCardShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget child;

  const ClinicRevenueCardShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  static BoxDecoration cardDecoration(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF0F172A) : colors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final embedded = ClinicRevenueEmbeddedFrameScope.isEmbedded(context);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );

    if (embedded) {
      return Padding(padding: const EdgeInsets.all(18), child: body);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(context),
      child: body,
    );
  }
}
