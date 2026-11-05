import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors_extension.dart';

/// QueueFlow Design System Typography Tokens.
/// Uses Inter for UI text and JetBrains Mono for numeric tokens & queue tickets.
class AppTypography {
  // Headings
  static TextStyle pageHeading(BuildContext context) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.15,
        color: context.colors.textPrimary,
      );

  static TextStyle displayLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: context.colors.textPrimary,
      );

  static TextStyle titleLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: context.colors.textPrimary,
      );

  static TextStyle sectionTitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: context.colors.textSubtle,
      );

  // Body text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: context.colors.textMuted,
        height: 1.45,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textSubtle,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      );

  static TextStyle buttonText({Color color = Colors.white}) => GoogleFonts.inter(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.2,
      );

  // Monospace / Numeric / Badges (JetBrains Mono)
  static TextStyle monoNumeric(BuildContext context) => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      );

  static TextStyle monoQueueNumber({Color color = Colors.white}) => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: color,
      );
}
