import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// QueueFlow Design System Typography Tokens
/// Uses Inter for UI text, headings, body and JetBrains Mono for numeric labels/badges.
class AppTypography {
  // Headings
  static TextStyle pageHeading = GoogleFonts.inter(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02 * 38,
    height: 1.08,
    color: AppColors.textWhite,
  );

  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textWhite,
  );

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textWhite,
  );

  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16.5,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Monospace / Numeric / Badges (JetBrains Mono)
  static TextStyle monoNumeric = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle monoQueueNumber = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: Colors.white,
  );
}