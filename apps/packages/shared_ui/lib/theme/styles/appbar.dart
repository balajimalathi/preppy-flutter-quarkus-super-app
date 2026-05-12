import 'package:flutter/material.dart';

/// AppBar theme for the app. Used by [MaterialTheme] to build [ThemeData.appBarTheme].
AppBarTheme appBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
  return AppBarTheme(
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: true,
    backgroundColor: colorScheme.inversePrimary,
    foregroundColor: colorScheme.onSurface,
    surfaceTintColor: colorScheme.surfaceTint,
    titleTextStyle: textTheme.titleLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
  );
}
