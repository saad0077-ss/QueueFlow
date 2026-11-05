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
    surfaceSecondary: Color(0xFFF1F5F9), // Slate 100 for secondary containers/inputs
    surfaceElevated: Color(0xFFFFFFFF),  // White for sheets & dialogs
    headerBg: Color(0xFFFFFFFF),         // White header bar in light mode
    navBarBg: Color(0xFFFFFFFF),         // White bottom navigation bar

    border: Color(0xFFE2E8F0),          // Slate 200 crisp light borders
    borderSubtle: Color(0xFFF1F5F9),    // Slate 100 dividers
    navBarBorder: Color(0xFFE2E8F0),    // Slate 200

    textPrimary: Color(0xFF0F172A),     // Slate 900 strong dark text
    textMuted: Color(0xFF64748B),       // Slate 500 readable secondary text
    textSubtle: Color(0xFF94A3B8),      // Slate 400 captions & meta text

    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryTint: Color(0xFFEFF6FF),     // Blue 50 light tint
    accent: Color(0xFF0D9488),          // Accessible teal for light surfaces
    accentLight: Color(0xFF14B8A6),
    accentTint: Color(0xFFF0FDFA),      // Teal 50 light tint

    badgeOpenBg: Color(0xFFDCFCE7),     // Green 100 soft chip
    badgeOpenText: Color(0xFF15803D),   // Green 700 accessible text
    ratingGold: Color(0xFFD97706),      // Amber 600 high-contrast rating
    success: Color(0xFF16A34A),
    successTint: Color(0xFFDCFCE7),
    warning: Color(0xFFD97706),
    warningTint: Color(0xFFFEF3C7),
    error: Color(0xFFDC2626),
    errorTint: Color(0xFFFEE2E2),
    info: Color(0xFF0284C7),
    infoTint: Color(0xFFE0F2FE),

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

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      badgeOpenBg: Color.lerp(badgeOpenBg, other.badgeOpenBg, t)!,
      badgeOpenText: Color.lerp(badgeOpenText, other.badgeOpenText, t)!,
      ratingGold: Color.lerp(ratingGold, other.ratingGold, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
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
