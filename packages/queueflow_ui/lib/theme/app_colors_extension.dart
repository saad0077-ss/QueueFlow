import 'package:flutter/material.dart';

/// Semantic Design System Tokens for QueueFlow apps.
///
/// Every UI element in all apps queries this extension via `context.colors.*`.
/// Changing a value here automatically changes it across all screens, cards,
/// dialogs, sheets, and headers in both Dark and Light themes.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Surfaces & Backgrounds
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color headerBg;
  final Color navBarBg;

  // Borders & Dividers
  final Color border;
  final Color borderSubtle;
  final Color navBarBorder;

  // Typography
  final Color textPrimary;
  final Color textMuted;
  final Color textSubtle;

  // Brand Colors
  final Color primary;
  final Color primaryLight;
  final Color primaryTint;
  final Color accent;
  final Color accentLight;
  final Color accentTint;

  // Status & Component Badges
  final Color badgeOpenBg;
  final Color badgeOpenText;
  final Color ratingGold;
  final Color success;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color error;
  final Color errorTint;
  final Color info;
  final Color infoTint;

  // Theme Mode Flag
  final bool isDark;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.headerBg,
    required this.navBarBg,
    required this.border,
    required this.borderSubtle,
    required this.navBarBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.textSubtle,
    required this.primary,
    required this.primaryLight,
    required this.primaryTint,
    required this.accent,
    required this.accentLight,
    required this.accentTint,
    required this.badgeOpenBg,
    required this.badgeOpenText,
    required this.ratingGold,
    required this.success,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.error,
    required this.errorTint,
    required this.info,
    required this.infoTint,
    required this.isDark,
  });

  /// Dark Theme Semantic Color Palette (Default QueueFlow Brand)
  static const dark = AppColorsExtension(
    background: Color(0xFF0B1220),
    surface: Color(0xFF111A2C),
    surfaceSecondary: Color(0xFF162032),
    surfaceElevated: Color(0xFF131D31),
    headerBg: Color(0xFF0B1220),
    navBarBg: Color(0xFF111A2C),

    border: Color(0xFF223049),
    borderSubtle: Color(0xFF1B273D),
    navBarBorder: Color(0xFF223049),

    textPrimary: Color(0xFFEEF2FA),
    textMuted: Color(0xFF9AA7BD),
    textSubtle: Color(0xFF6B7A93),

    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryTint: Color(0x2E2563EB), // ~18% primary
    accent: Color(0xFF14B8A6),
    accentLight: Color(0xFF2DD4BF),
    accentTint: Color(0x2614B8A6), // ~15% teal

    badgeOpenBg: Color(0x3310B981),
    badgeOpenText: Color(0xFF34D399),
    ratingGold: Color(0xFFF59E0B),
    success: Color(0xFF16A34A),
    successTint: Color(0x2616A34A),
    warning: Color(0xFFF59E0B),
    warningTint: Color(0x26F59E0B),
    error: Color(0xFFDC2626),
    errorTint: Color(0x26DC2626),
    info: Color(0xFF0284C7),
    infoTint: Color(0x260284C7),

    isDark: true,
  );

  /// Light Theme Semantic Color Palette (Clean Modern Medical System)
  static const light = AppColorsExtension(
    background: Color(0xFFF8FAFC),       // Clean slate light background
    surface: Color(0xFFFFFFFF),          // Pure white card surfaces
    surfaceSecondary: Color(0xFFEEF2F7), // Slightly deeper for secondary containers/inputs
    surfaceElevated: Color(0xFFFFFFFF),  // White for sheets & dialogs
    headerBg: Color(0xFFFFFFFF),         // White header bar in light mode
    navBarBg: Color(0xFFFFFFFF),         // White bottom navigation bar

    border: Color(0xFFCBD5E1),          // Slate 300 clearly visible borders
    borderSubtle: Color(0xFFE2E8F0),    // Slate 200 dividers
    navBarBorder: Color(0xFFCBD5E1),    // Slate 300

    textPrimary: Color(0xFF0F172A),     // Slate 900 strong dark text
    textMuted: Color(0xFF64748B),       // Slate 500 readable secondary text
    textSubtle: Color(0xFF94A3B8),      // Slate 400 captions & meta text

    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryTint: Color(0xFFDBEAFE),     // Blue 100 tint
    accent: Color(0xFF0D9488),          // Accessible teal for light surfaces
    accentLight: Color(0xFF14B8A6),
    accentTint: Color(0xFFCCFBF1),      // Teal 100 tint

    badgeOpenBg: Color(0xFFBBF7D0),     // Green 200 visible chip
    badgeOpenText: Color(0xFF166534),   // Green 800 accessible text
    ratingGold: Color(0xFFB45309),      // Amber 700 high-contrast rating
    success: Color(0xFF15803D),
    successTint: Color(0xFFBBF7D0),
    warning: Color(0xFFB45309),
    warningTint: Color(0xFFFDE68A),
    error: Color(0xFFB91C1C),
    errorTint: Color(0xFFFECACA),
    info: Color(0xFF0369A1),
    infoTint: Color(0xFFBAE6FD),

    isDark: false,
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceElevated,
    Color? headerBg,
    Color? navBarBg,
    Color? border,
    Color? borderSubtle,
    Color? navBarBorder,
    Color? textPrimary,
    Color? textMuted,
    Color? textSubtle,
    Color? primary,
    Color? primaryLight,
    Color? primaryTint,
    Color? accent,
    Color? accentLight,
    Color? accentTint,
    Color? badgeOpenBg,
    Color? badgeOpenText,
    Color? ratingGold,
    Color? success,
    Color? successTint,
    Color? warning,
    Color? warningTint,
    Color? error,
    Color? errorTint,
    Color? info,
    Color? infoTint,
    bool? isDark,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      headerBg: headerBg ?? this.headerBg,
      navBarBg: navBarBg ?? this.navBarBg,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryTint: primaryTint ?? this.primaryTint,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentTint: accentTint ?? this.accentTint,
      badgeOpenBg: badgeOpenBg ?? this.badgeOpenBg,
      badgeOpenText: badgeOpenText ?? this.badgeOpenText,
      ratingGold: ratingGold ?? this.ratingGold,
      success: success ?? this.success,
      successTint: successTint ?? this.successTint,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
      error: error ?? this.error,
      errorTint: errorTint ?? this.errorTint,
      info: info ?? this.info,
      infoTint: infoTint ?? this.infoTint,
      isDark: isDark ?? this.isDark,
    );
  }

  // The wave reveal replaces color interpolation, so just switch instantly.
  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) =>
      other is AppColorsExtension && t >= 0.5 ? other : this;
}

/// Convenience extensions on [BuildContext] to access semantic tokens easily.
extension QueueFlowThemeContext on BuildContext {
  /// Direct access to all semantic color tokens for the active theme.
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

  /// Whether the app is currently displaying in dark mode.
  bool get isDarkMode =>
      Theme.of(this).extension<AppColorsExtension>()?.isDark ??
      (Theme.of(this).brightness == Brightness.dark);
}
