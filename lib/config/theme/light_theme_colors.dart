import 'package:flutter/material.dart';

class LightThemeColors {
  // Modern biogas-themed color palette
  static const Color primaryColor = Color(0xFF2E7D32); // Deep green
  static const Color primaryColorLight = Color(0xFF4CAF50); // Light green
  static const Color primaryColorDark = Color(0xFF1B5E20); // Darker green
  static const Color accentColor = Color(0xFFFF8C00); // Warm orange
  static const Color secondaryColor = Color(0xFF1976D2); // Professional blue

  // Background colors
  static const Color canvasColor = Color(0xFFF5F7FA);
  static const Color scaffoldBackgroundColor = Color(0xFFFAFBFC);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF8F9FA);

  // Text colors
  static const Color headlinesTextColor = Color(0xFF1A1A1A);
  static const Color bodyTextColor = Color(0xFF4A5568);
  static const Color captionTextColor = Color(0xFF718096);
  static const Color hintTextColor = Color(0xFFA0AEC0);

  // UI Element colors
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color borderColor = Color(0xFFCBD5E0);
  static const Color shadowColor = Color(0x0F000000); // 6% black

  // Status colors
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color infoColor = secondaryColor;

  // Legacy compatibility
  static const Color appBarColor = Colors.transparent;
  static const Color appBarIconsColor = headlinesTextColor;
  static const Color iconColor = bodyTextColor;
  static const Color buttonColor = primaryColor;
  static const Color buttonTextColor = Colors.white;
  static const Color buttonDisabledColor = Color(0xFFCBD5E0);
  static const Color buttonDisabledTextColor = Color(0xFF718096);
  static const Color chipBackground = primaryColor;
  static const Color chipTextColor = Colors.white;
  static const Color progressIndicatorColor = primaryColor;
}
