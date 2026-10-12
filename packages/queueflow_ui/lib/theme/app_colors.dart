import 'package:flutter/material.dart';

/// QueueFlow Design System Color Tokens
/// Directly mapped from the official QueueFlow Design System specification.
class AppColors {
  // Brand Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryTint = Color(0xFFEFF4FE);

  // Aliases for compatibility
  static const Color primaryBlue = primary;
  static const Color lightBlue = primaryLight;

  // Brand Accent
  static const Color accent = Color(0xFF14B8A6);
  static const Color accentLight = Color(0xFF2DD4BF);
  static const Color accentTint = Color(0xFFE6FBF6);

  // Aliases for compatibility
  static const Color accentTeal = accent;

  // Brand Gradients
  /// Primary → Accent (135deg): #2563EB to #14B8A6
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card Header Gradient: #2563EB to #2DD4BF
  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [primary, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Surfaces & Text (Default)
  static const Color darkBgApp = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111A2C);
  static const Color darkInk = Color(0xFFEEF2FA);
  static const Color darkInkMuted = Color(0xFF9AA7BD);
  static const Color darkInkFaint = Color(0xFF6B7A93);
  static const Color darkBorder = Color(0xFF223049);

  // Light Theme Surfaces & Text
  static const Color lightBgApp = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInk = Color(0xFF0F172A);
  static const Color lightInkMuted = Color(0xFF64748B);
  static const Color lightInkFaint = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Active App Theme (Dark Mode) Defaults & Semantic Aliases
  static const Color background = darkBgApp;
  static const Color cardBg = darkSurface;
  static const Color cardBorder = darkBorder;

  // Input Fields
  static const Color inputBg = darkSurface;
  static const Color inputBorder = darkBorder;
  static const Color inputFocusedBorder = primary;

  // Typography Tokens
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textInk = darkInk;
  static const Color textMuted = darkInkMuted;
  static const Color textSubtle = darkInkFaint;
  static const Color textLink = primaryLight;

  // Status Colors & Tints
  static const Color success = Color(0xFF16A34A);
  static const Color successTint = Color(0xFFEAFBF1);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningTint = Color(0xFFFEF3E2);

  static const Color error = Color(0xFFDC2626);
  static const Color errorTint = Color(0xFFFDF0F0);

  static const Color violet = Color(0xFF7C3AED);
  static const Color violetTint = Color(0xFFF2ECFE);

  // Status Aliases for compatibility
  static const Color successGreen = success;
  static const Color errorRed = error;

  // Design System Radii
  static const double radiusLg = 26.0;
  static const double radiusMd = 14.0;
  static const double radiusIcon = 20.0;

  // Icon container shadow: 0 16px 30px -10px rgba(37,99,235,.45)
  static const BoxShadow iconTileShadow = BoxShadow(
    color: Color(0x732563EB),
    blurRadius: 30,
    spreadRadius: -10,
    offset: Offset(0, 16),
  );
}
