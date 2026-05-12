import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.googleSans(
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: GoogleFonts.googleSans(
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.googleSans(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.googleSans(
      fontSize: 32,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: GoogleFonts.googleSans(
      fontSize: 28,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.googleSans(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.googleSans(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.googleSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.googleSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.googleSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.googleSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: GoogleFonts.googleSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.googleSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.googleSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.googleSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
}
