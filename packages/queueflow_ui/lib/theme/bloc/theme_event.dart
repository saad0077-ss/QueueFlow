import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeToggleRequested extends ThemeEvent {
  const ThemeToggleRequested();
}

class ThemeModeChanged extends ThemeEvent {
  final ThemeMode mode;

  const ThemeModeChanged(this.mode);

  ThemeMode get themeMode => mode;

  @override
  List<Object?> get props => [mode];
}
