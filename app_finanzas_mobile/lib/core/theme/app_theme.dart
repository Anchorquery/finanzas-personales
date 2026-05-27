import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Brand ──────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2B4BEE);
  static const Color primaryColor = primary; // compat

  // ── Semantic Status ─────────────────────────────────────────────────────
  static const Color accentGreen   = Color(0xFF10B981); // ingreso / ahorro
  static const Color accentRed     = Color(0xFFF43F5E); // gasto / deuda
  static const Color accentWarning = Color(0xFFF59E0B); // alerta / eventos
  static const Color accentAI      = Color(0xFF8B5CF6); // IA / suscripciones
  static const Color accentBlue    = Color(0xFF3B82F6); // banco / info

  // ── Compat aliases ───────────────────────────────────────────────────────
  static const Color accentColor      = accentGreen;
  static const Color errorColor       = accentRed;
  static const Color loginButtonColor = accentGreen;

  // ── Backgrounds / Scaffold ───────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF0F172A); // Slate 900
  static const Color backgroundLight = Color(0xFFF6F6F8);

  // ── Surfaces (cards, paneles) ────────────────────────────────────────────
  static const Color surfaceDark         = Color(0xFF1E293B); // Slate 800
  static const Color surfaceDarkElevated = Color(0xFF253047); // Slate 750
  static const Color surfaceCard         = Color(0xFF1A1D2E); // card unificado dark

  // ── Texto ────────────────────────────────────────────────────────────────
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textHint      = Color(0xFF64748B); // Slate 500
  static const Color textDisabled  = Color(0xFF475569); // Slate 600

  // ── Input ────────────────────────────────────────────────────────────────
  static const Color inputFillDark    = Color(0xFF13161F);
  static const Color inputBorderDark  = Color(0xFF2D303E);
  static const Color inputFillLight   = Color(0xFFF3F4F6);
  static const Color inputBorderLight = Color(0xFFE5E7EB);

  // ── Balance Card gradient ────────────────────────────────────────────────
  static const Color cardGradientStart = Color(0xFF2E1C57); // Violet profundo
  static const Color cardGradientEnd   = Color(0xFF1A1F3C); // Navy

  // ── Avatar ───────────────────────────────────────────────────────────────
  static const Color avatarBg = Color(0xFFFFE4C4); // Bisque
  static const Color avatarFg = Color(0xFFD97706); // Amber 700

  // ── Org icon gradient ────────────────────────────────────────────────────
  static const Color orgGradientStart = Color(0xFF3B82F6); // Blue 500
  static const Color orgGradientEnd   = Color(0xFF06B6D4); // Cyan 500

  // ── Theme toggle ─────────────────────────────────────────────────────────
  static const Color themeToggleBg       = surfaceDark;
  static const Color themeToggleSelected = Color(0xFF334155); // Slate 700

  // ── Light mode surfaces ───────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFF1F5F9); // Slate 100 — chips/bg light
  static const Color borderLight  = Color(0xFFE2E8F0); // Slate 200 — bordes light

  // ── AI gradient extendido ────────────────────────────────────────────────
  static const Color accentAIDark = Color(0xFF6D28D9); // Violet 700

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const Color slate900        = backgroundDark;
  static const Color quantityBlack12 = Color(0x1F000000);

  // ── Chart palette (6 colores, consistente en toda la app) ───────────────
  static const List<Color> chartPalette = [
    accentBlue,        // 0xFF3B82F6
    accentGreen,       // 0xFF10B981
    accentWarning,     // 0xFFF59E0B
    accentRed,         // 0xFFF43F5E
    accentAI,          // 0xFF8B5CF6
    Color(0xFF06B6D4), // Cyan 500
  ];

  // ── InputDecorationTheme ─────────────────────────────────────────────────
  static InputDecorationTheme _inputTheme({required bool dark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: dark ? inputFillDark : inputFillLight,
      hintStyle: TextStyle(color: dark ? textHint : const Color(0xFF9CA3AF)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: dark ? inputBorderDark : inputBorderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: dark ? inputBorderDark : inputBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentRed, width: 1.5),
      ),
    );
  }

  // ── SwitchTheme ──────────────────────────────────────────────────────────
  static SwitchThemeData _switchTheme({required bool dark}) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return dark ? textHint : const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return dark ? surfaceDark : const Color(0xFFCBD5E1);
      }),
    );
  }

  // ── Cursor helper ────────────────────────────────────────────────────────
  static ButtonStyle get _clickCursor => ButtonStyle(
        mouseCursor:
            WidgetStateProperty.all(SystemMouseCursors.click),
      );

  // ════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ════════════════════════════════════════════════════════════════════════
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: Colors.white,
      error: accentRed,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    inputDecorationTheme: _inputTheme(dark: false),
    dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB), thickness: 1),
    switchTheme: _switchTheme(dark: false),
    iconButtonTheme:
        IconButtonThemeData(style: _clickCursor),
    elevatedButtonTheme:
        ElevatedButtonThemeData(style: _clickCursor),
    textButtonTheme:
        TextButtonThemeData(style: _clickCursor),
    outlinedButtonTheme:
        OutlinedButtonThemeData(style: _clickCursor),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: quantityBlack12,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ════════════════════════════════════════════════════════════════════════
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: surfaceDark,
      error: accentRed,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: _inputTheme(dark: true),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      thickness: 1,
    ),
    switchTheme: _switchTheme(dark: true),
    iconButtonTheme:
        IconButtonThemeData(style: _clickCursor),
    elevatedButtonTheme:
        ElevatedButtonThemeData(style: _clickCursor),
    textButtonTheme:
        TextButtonThemeData(style: _clickCursor),
    outlinedButtonTheme:
        OutlinedButtonThemeData(style: _clickCursor),
    cardTheme: const CardThemeData(
      color: surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0x0DFFFFFF)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
