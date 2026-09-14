import 'package:flutter/material.dart';

class AppStyle {
  static const scaffoldBg = Color(0xFF0B0E14);
  static const surface = Color(0xFF121722);
  static const surfaceLight = Color(0xFF1A2130);
  static const surfaceRaised = Color(0xFF20293A);
  static const border = Color(0xFF263044);
  static const borderLight = Color(0xFF20293A);

  static const primary = Color(0xFF112E81);
  static const success = Color(0xFF47D18C);
  static const successBg = Color(0xFF143B2B);
  static const error = Color(0xFFFF6B7A);
  static const errorBg = Color(0xFF491D27);
  static const warning = Color(0xFFFFB454);
  static const warningBg = Color(0xFF49351B);
  static const info = Color(0xFF65B7FF);
  static const ready = Color(0xFF00FFDE);

  static const textPrimary = Color(0xFFF5F7FB);
  static const textSecondary = Color(0xFFAAB4C5);
  static const textMuted = Color(0xFF717D91);

  static const double paddingMd = 12;
  static const double paddingLg = 16;
  static const double radiusSm = 5;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  static const heading = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(fontSize: 13, height: 1.35);
  static const bodySm = TextStyle(fontSize: 12, height: 1.35);
  static const caption = TextStyle(fontSize: 11, height: 1.3);
  static const badge = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);

  static BoxDecoration cardDecoration({
    Color color = surface,
    double radius = radiusSm,
    bool hasBorder = true,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder ? Border.all(color: border) : null,
      );

  static InputDecoration inputDecoration(
    String label, {
    bool isDense = false,
  }) =>
      InputDecoration(
        labelText: label,
        isDense: isDense,
        filled: true,
        fillColor: surfaceLight,
      );

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
      error: error,
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: border),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        bodyMedium: body,
        bodySmall: bodySm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        labelStyle: const TextStyle(color: textMuted, fontSize: 12),
        floatingLabelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: const BorderSide(color: primary, width: 1.3),
        ),
        errorBorder: outline.copyWith(
          borderSide: const BorderSide(color: error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textSecondary),
      ),
      dividerColor: border,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
}
