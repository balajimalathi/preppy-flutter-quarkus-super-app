import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_radius.dart';

const _kBorderRadius = AppRadius.roundedMd;
const _kContentPadding = EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0);
const _kHintStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.w500);

OutlineInputBorder _border(Color color, {double width = 1.0}) {
  return OutlineInputBorder(
    borderRadius: _kBorderRadius,
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Input decoration theme for the app.
InputDecorationTheme inputDecorationTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return InputDecorationTheme(
    filled: true,
    isDense: true,
    fillColor: colorScheme.surface,
    focusedBorder: _border(colorScheme.primary, width: 2.0),
    focusedErrorBorder: _border(colorScheme.error),
    enabledBorder: _border(colorScheme.outline),
    disabledBorder: _border(colorScheme.outline),
    errorBorder: _border(colorScheme.error),
    contentPadding: _kContentPadding,
    hintStyle: _kHintStyle,
  );
}
