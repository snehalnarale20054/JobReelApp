import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All design tokens for the app live here.
/// Update this file to change the look of the entire product.
class AppTheme {
  AppTheme._();

  // ── Colour palette ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A56DB);       // Trust blue
  static const Color primaryDark = Color(0xFF1241A8);
  static const Color accent = Color(0xFFF97316);         // Action orange
  static const Color background = Color(0xFFF5F7FA);     // Off-white canvas
  static const Color surface = Color(0xFFFFFFFF);        // Cards / sheets
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF9CA3AF);

  // ── Sizing ───────────────────────────────────────────────────────────────────
  /// Minimum touch-target size (spec rule: 48dp minimum)
  static const double minTouchTarget = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ── Typography ───────────────────────────────────────────────────────────────
  /// Noto Sans supports Latin, Devanagari (Hindi + Marathi) in one font family.
  static TextTheme get _textTheme => GoogleFonts.notoSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: surface),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
        ),
      );

  // ── Light theme ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
          error: error,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        textTheme: _textTheme,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: navBackground,
          selectedItemColor: navSelected,
          unselectedItemColor: navUnselected,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),

        // Buttons — enforce 48dp minimum height
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: surface,
            minimumSize: const Size(double.infinity, minTouchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, minTouchTarget),
            side: const BorderSide(color: primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(48, minTouchTarget),
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error),
          ),
        ),

        // Cards
        cardTheme: CardTheme(
          color: surface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          margin: EdgeInsets.zero,
        ),

        dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      );
}
