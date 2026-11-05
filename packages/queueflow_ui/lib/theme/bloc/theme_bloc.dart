import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// Pure BLoC managing application-wide ThemeMode with persistent storage.
///
/// Features:
/// - Persistent saving/restoration via [SharedPreferences] (No Hive, no fragile caches).
/// - Instant synchronous restore on hot restart/boot when [initializePrefs] is called.
/// - Pure BLoC architecture (Events -> Bloc -> States).
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String prefKey = 'queueflow_theme_mode';
  static SharedPreferences? _cachedPrefs;

  /// Warm up SharedPreferences during app startup (in `main()`).
  static Future<void> initializePrefs() async {
    try {
      _cachedPrefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ThemeBloc: could not initialize SharedPreferences: $e');
    }
  }

  /// Resolves the currently saved ThemeMode, defaulting to [ThemeMode.dark].
  static ThemeMode getSavedThemeMode([SharedPreferences? prefs]) {
    final p = prefs ?? _cachedPrefs;
    final saved = p?.getString(prefKey);
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    return ThemeMode.dark;
  }

  final SharedPreferences? _prefs;

  ThemeBloc({SharedPreferences? prefs, ThemeMode? initialMode})
      : _prefs = prefs ?? _cachedPrefs,
        super(ThemeState(
          themeMode: initialMode ?? getSavedThemeMode(prefs ?? _cachedPrefs),
        )) {
    on<ThemeToggleRequested>(_onToggleRequested);
    on<ThemeModeChanged>(_onModeChanged);
  }

  Future<void> _onToggleRequested(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final nextMode = state.isDark ? ThemeMode.light : ThemeMode.dark;
    await _persistMode(nextMode);
    emit(ThemeState(themeMode: nextMode));
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _persistMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }

  Future<void> _persistMode(ThemeMode mode) async {
    try {
      final p = _prefs ?? _cachedPrefs ?? await SharedPreferences.getInstance();
      _cachedPrefs = p;
      await p.setString(prefKey, mode == ThemeMode.light ? 'light' : 'dark');
    } catch (e) {
      debugPrint('ThemeBloc: failed to persist theme mode: $e');
    }
  }
}
