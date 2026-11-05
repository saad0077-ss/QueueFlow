import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors_extension.dart';

/// Pre-configured theme variants for QueueFlow apps.
///
/// Centralizes all widget defaults (cards, dialogs, bottom sheets, app bars,
/// text inputs, and typography) so that UI components stay completely in sync
/// when the user toggles between Dark and Light mode.
class AppTheme {
  /// Dark Theme (Default brand experience)
  static ThemeData get darkTheme {
    final ext = AppColorsExtension.dark;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ext.background,
      cardColor: ext.surface,
      dividerColor: ext.border,
      canvasColor: ext.surfaceElevated,
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: ext.textPrimary,
        displayColor: ext.textPrimary,
      ),
      extensions: [ext],
      colorScheme: ColorScheme.dark(
        primary: ext.primary,
        secondary: ext.accent,
        surface: ext.surface,
        error: ext.error,
        onPrimary: Colors.white,
        onSurface: ext.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ext.headerBg,
        foregroundColor: ext.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: ext.border, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: ext.textMuted, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Light Theme (Clean, high-contrast, modern medical portal)
  static ThemeData get lightTheme {
    final ext = AppColorsExtension.light;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ext.background,
      cardColor: ext.surface,
      dividerColor: ext.border,
      canvasColor: ext.surfaceElevated,
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ext.textPrimary,
        displayColor: ext.textPrimary,
      ),
      extensions: [ext],
      colorScheme: ColorScheme.light(
        primary: ext.primary,
        secondary: ext.accent,
        surface: ext.surface,
        error: ext.error,
        onPrimary: Colors.white,
        onSurface: ext.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ext.headerBg,
        foregroundColor: ext.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: ext.border, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: ext.textMuted, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border, width: 1),
        ),    
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.primary, width: 1.5),
        ),
      ),
    );
  }
}
