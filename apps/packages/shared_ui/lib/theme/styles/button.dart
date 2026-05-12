import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_radius.dart';

// Shared shape and padding for shadcn-like consistency.
const _defaultPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
const _defaultShape = RoundedRectangleBorder(
  borderRadius: AppRadius.roundedSm,
);

/// Default (primary) filled button — shadcn "default" variant.
FilledButtonThemeData filledButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      padding: _defaultPadding,
      minimumSize: const Size(64, 40),
      shape: _defaultShape,
      elevation: 0,
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

/// Outline button — shadcn "outline" variant.
OutlinedButtonThemeData outlinedButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      side: BorderSide(color: colorScheme.outline),
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      padding: _defaultPadding,
      minimumSize: const Size(64, 40),
      shape: _defaultShape,
      elevation: 0,
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

/// Ghost / minimal button — shadcn "ghost" variant.
TextButtonThemeData textButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      padding: _defaultPadding,
      minimumSize: const Size(64, 40),
      shape: _defaultShape,
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

/// Secondary (tonal) — use with [FilledButton.tonal].
FilledButtonThemeData filledTonalButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: colorScheme.onSecondaryContainer,
      backgroundColor: colorScheme.secondaryContainer,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      padding: _defaultPadding,
      minimumSize: const Size(64, 40),
      shape: _defaultShape,
      elevation: 0,
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  );
}

/// Secondary (tonal) — shadcn "secondary" variant. Use as [FilledButton] style override.
ButtonStyle secondaryFilledButtonStyle(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return FilledButton.styleFrom(
    foregroundColor: colorScheme.onSecondaryContainer,
    backgroundColor: colorScheme.secondaryContainer,
    disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
    disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
    padding: _defaultPadding,
    minimumSize: const Size(64, 40),
    shape: _defaultShape,
    elevation: 0,
    textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
  );
}

/// Destructive filled — shadcn "destructive" variant. Use as [FilledButton] style override.
ButtonStyle destructiveFilledButtonStyle(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return FilledButton.styleFrom(
    foregroundColor: colorScheme.onError,
    backgroundColor: colorScheme.error,
    disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
    disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
    padding: _defaultPadding,
    minimumSize: const Size(64, 40),
    shape: _defaultShape,
    elevation: 0,
    textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
  );
}

/// Link-style button — shadcn "link" variant. Use as [TextButton] style override.
ButtonStyle linkButtonStyle(ColorScheme colorScheme, TextTheme textTheme) {
  return TextButton.styleFrom(
    foregroundColor: colorScheme.primary,
    disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
    padding: _defaultPadding,
    minimumSize: const Size(64, 40),
    shape: _defaultShape,
    textStyle: textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary,
    ),
  );
}
