import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles following Material Design 3 typography scale
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Display styles - Large, attention-grabbing text
  static TextStyle displayLarge = GoogleFonts.roboto(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = GoogleFonts.roboto(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static TextStyle displaySmall = GoogleFonts.roboto(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  // Headline styles - High-emphasis text
  static TextStyle headlineLarge = GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headlineMedium = GoogleFonts.roboto(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headlineSmall = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  // Title styles - Medium-emphasis text
  static TextStyle titleLarge = GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static TextStyle titleMedium = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Body styles - Regular text
  static TextStyle bodyLarge = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label styles - Buttons, tabs, labels
  static TextStyle labelLarge = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Custom styles for specific use cases
  static TextStyle currency = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFeatures: [const FontFeature.tabularFigures()], // Tabular numbers
  );

  static TextStyle balance = GoogleFonts.roboto(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle transactionAmount = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle customerName = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static TextStyle customerPhone = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle dateText = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );

  static TextStyle chipText = GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
  );
}
