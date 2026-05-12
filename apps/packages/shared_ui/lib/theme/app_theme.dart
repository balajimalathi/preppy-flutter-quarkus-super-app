import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/theme/styles/appbar.dart';
import 'package:shared_ui/theme/styles/button.dart';
import 'package:shared_ui/theme/styles/textformfield.dart';

import 'app_colors.dart';
import 'app_typography.dart';

final class ThemeState {
  const ThemeState({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
  });

  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
}

final class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(
      theme: _buildTheme(AppColors.lightScheme()),
      darkTheme: _buildTheme(AppColors.darkScheme()),
      themeMode: ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = ThemeState(
      theme: state.theme,
      darkTheme: state.darkTheme,
      themeMode: mode,
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme(scheme, textTheme),
      appBarTheme: appBarTheme(scheme, textTheme),
      filledButtonTheme: filledButtonTheme(scheme, textTheme),
      outlinedButtonTheme: outlinedButtonTheme(scheme, textTheme),
      textButtonTheme: textButtonTheme(scheme, textTheme),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
