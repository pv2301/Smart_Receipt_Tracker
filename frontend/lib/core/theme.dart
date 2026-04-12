import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0F1C); // Ultra Dark Navy
  static const Color cardColor      = Color(0xFF172033); // Slightly lighter Navy
  static const Color navBarColor    = Color(0xFF111827); // Nav bar (between bg and card)
  static const Color primaryAction  = Color(0xFF00E676); // Neon Green
  static const Color textMain       = Colors.white;
  static const Color textSecondary  = Color(0xFF8B9BB4);

  // ── Typography Scale ──────────────────────────────────────────────────────
  static const double fontXS  = 10.0; // nav labels, captions
  static const double fontSM  = 12.0; // secondary text, badges
  static const double fontMD  = 14.0; // body text
  static const double fontLG  = 16.0; // emphasized body, card titles
  static const double fontXL  = 20.0; // section headers
  static const double font2XL = 24.0; // screen titles
  static const double font3XL = 32.0; // hero values (ex: R$ 0,00)

  // ── Spacing Scale ─────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusSM   = 8.0;
  static const double radiusMD   = 12.0;
  static const double radiusLG   = 16.0;
  static const double radiusXL   = 20.0;
  static const double radiusFull = 100.0;

  // ── Component Sizes ───────────────────────────────────────────────────────
  static const double navBarHeight    = 64.0;
  static const double fabSize         = 60.0;
  static const double iconSizeNav     = 22.0;
  static const double iconSizeMD      = 24.0;
  static const double buttonHeightSM  = 36.0;
  static const double buttonHeightMD  = 44.0;
  static const double buttonHeightLG  = 52.0;

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryAction,
        secondary: primaryAction,
        surface: cardColor,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: cardColor.withOpacity(0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: const BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      // BottomAppBar (used by notched nav)
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: navBarColor,
        elevation: 12,
        shadowColor: Colors.black54,
      ),
      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryAction,
        foregroundColor: darkBackground,
        elevation: 6,
        shape: CircleBorder(),
      ),
      // NavigationRail (tablet/desktop)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkBackground,
        selectedIconTheme: const IconThemeData(color: primaryAction, size: iconSizeMD),
        unselectedIconTheme: const IconThemeData(color: textSecondary, size: iconSizeMD),
        selectedLabelTextStyle: const TextStyle(color: primaryAction, fontSize: fontSM, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: const TextStyle(color: textSecondary, fontSize: fontSM),
        indicatorColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: const BorderSide(color: primaryAction, width: 1.5),
        ),
      ),
      // Text theme baseline
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: font3XL, fontWeight: FontWeight.bold,   color: textMain),
        headlineMedium:TextStyle(fontSize: font2XL, fontWeight: FontWeight.bold,   color: textMain),
        titleLarge:    TextStyle(fontSize: fontXL,  fontWeight: FontWeight.w600,   color: textMain),
        titleMedium:   TextStyle(fontSize: fontLG,  fontWeight: FontWeight.w500,   color: textMain),
        bodyLarge:     TextStyle(fontSize: fontMD,  fontWeight: FontWeight.normal, color: textMain),
        bodyMedium:    TextStyle(fontSize: fontSM,  fontWeight: FontWeight.normal, color: textSecondary),
        labelSmall:    TextStyle(fontSize: fontXS,  fontWeight: FontWeight.normal, color: textSecondary),
      ),
    );
  }
}
