import 'package:flutter/material.dart';

/// App color constants following Material Design 3 guidelines
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1976D2); // Deep Blue
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Secondary Colors
  static const Color secondary = Color(0xFF00897B); // Teal
  static const Color secondaryLight = Color(0xFF4EBAAA);
  static const Color secondaryDark = Color(0xFF005B4F);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green - for "You Got"
  static const Color error = Color(0xFFF44336); // Red - for "You Gave"
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF03A9F4); // Light Blue

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // Divider Colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF2C2C2C);

  // Transaction Type Colors
  static const Color credit = error; // You Gave (Red)
  static const Color debit = success; // You Got (Green)

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // Overlay Colors
  static const Color overlay = Color(0x33000000);

  // Currency Symbol Color
  static const Color currency = Color(0xFF1976D2);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF00897B), // Teal
    Color(0xFFFF9800), // Orange
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF00BCD4), // Cyan
  ];
}
