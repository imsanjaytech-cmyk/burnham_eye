import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary      = Color(0xFFED8B00);
  static const Color primaryLight = Color(0xFFFFF3E0);
  static const Color primaryDark  = Color(0xFFBF6900);
  static const Color primaryGlow  = Color(0xFFFFB74D);

  static const Color surface      = Colors.white;
  static const Color bg           = Color(0xFFF6F7FA);
  static const Color bgCard       = Color(0xFFFAFBFC);

  static const Color textDark     = Color(0xFF1E293B);
  static const Color textMid      = Color(0xFF64748B);
  static const Color textLight    = Color(0xFF94A3B8);

  static const Color success      = Color(0xFF10B981);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color info         = Color(0xFF3B82F6);

  static const Color divider      = Color(0xFFE2E8F0);
  static const Color border       = Color(0xFFCBD5E1);

  static const List<Color> voicePulse = [
    Color(0xFF4285F4), 
    Color(0xFFEA4335), 
    Color(0xFFFBBC05), 
    Color(0xFF34A853), 
  ];

  static Color statusColor(String status) {
    switch (status) {
      case 'Submitted':  return success;
      case 'Dispatched': return primary;
      default:           return warning;
    }
  }

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get floatShadow => [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> pulseShadow(double value) => [
    BoxShadow(
      color: error.withOpacity(value * 0.45),
      blurRadius: 24,
      spreadRadius: value * 12,
    ),
  ];

  static BorderRadius get radiusSm   => BorderRadius.circular(8);
  static BorderRadius get radiusMd   => BorderRadius.circular(12);
  static BorderRadius get radiusLg   => BorderRadius.circular(16);
  static BorderRadius get radiusXl   => BorderRadius.circular(20);
  static BorderRadius get radiusFull => BorderRadius.circular(999);

  static const TextStyle headingLg = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: textDark, letterSpacing: -0.5,
  );
  static const TextStyle headingMd = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700,
    color: textDark, letterSpacing: -0.3,
  );
  static const TextStyle headingSm = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: textDark,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14, color: textDark, height: 1.5,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: 12, color: textMid,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: textMid, letterSpacing: 0.3,
  );

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: divider),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: divider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}