import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors based on Fintech styling
  static const Color darkBackground = Color(0xFF0A0F1C); // Ultra Dark Navy
  static const Color cardColor = Color(0xFF172033);      // Slightly lighter Navy
  static const Color primaryAction = Color(0xFF00E676);  // Vibrant Neon Green/Teal
  static const Color textMain = Colors.white;
  static const Color textSecondary = Color(0xFF8B9BB4);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryAction,
        secondary: primaryAction,
        surface: cardColor,
      ),
      fontFamily: 'Outfit', // Or any modern sans-serif. We'll setup GoogleFonts later
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: cardColor.withOpacity(0.6), // Glassmorphism base
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: primaryAction,
        unselectedItemColor: textSecondary,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: darkBackground,
        selectedIconTheme: IconThemeData(color: primaryAction),
        unselectedIconTheme: IconThemeData(color: textSecondary),
      ),
    );
  }
}
