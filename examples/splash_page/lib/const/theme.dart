import 'package:flutter/material.dart';

final themeData = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFA8DADC), // Soft blue
    onPrimary: Color(0xFF2C3E50), // Dark text on primary
    secondary: Color(0xFFF7DC6F), // Soft yellow
    onSecondary: Color(0xFF2C3E50), // Dark text on secondary
    error: Color(0xFFE74C3C), // Soft red for errors
    onError: Color(0xFFFFFFFF), // White text on error
    surface: Color(0xFFFFFFFF), // White surface
    onSurface: Color(0xFF2C3E50), // Dark text on surface
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Light gray scaffold
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFA8DADC), // Soft blue app bar
    foregroundColor: Color(0xFF2C3E50), // Dark text
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF7DC6F), // Soft yellow buttons
      foregroundColor: const Color(0xFF2C3E50), // Dark text
    ),
  ),
);
