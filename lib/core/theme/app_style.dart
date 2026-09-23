import 'package:flutter/material.dart';

/// Light-mode design tokens.
///
/// These are consumed statically (e.g. `AppStyle.surface` inside `const`
/// widgets), so the palette lives as compile-time constants rather than being
/// threaded through the widget tree off `Theme.of(context)`.
class AppStyle {
  // Surfaces, from page background down to raised elements.
  static const scaffoldBg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF1F4FA);
  static const surfaceRaised = Color(0xFFE6EBF5);
  static const border = Color(0xFFDCE2EE);
  static const borderLight = Color(0xFFE8ECF4);

  static const primary = Color(0xFF112E81);

  static const success = Color(0xFF47D18C);
  static const successBg = Color(0xFFDCF5E8);
  static const error = Color(0xFFD92D4B);
  static const errorBg = Color(0xFFFCE4E8);
  static const warning = Color(0xFFE08A00);
  static const warningBg = Color(0xFFFDF0DA);
  static const info = Color(0xFF65B7FF);

  /// Amount highlights. In dark mode this was a bright cyan, which is
  /// unreadable on a near-white background, so it becomes a deep teal.
  static const ready = Color(0xFF0E9F81);

  static const textPrimary = Color(0xFF131A26);
  static const textSecondary = Color(0xFF56606F);
  static const textMuted = Color(0xFF7C8698);

  /// Foreground for content sitting on [primary] (filled buttons).
  static const onPrimary = Color(0xFFFFFFFF);

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
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: hasBorder ? Border.all(color: border) : null,
  );

  static InputDecoration inputDecoration(
    String label, {
    bool isDense = false,
  }) => InputDecoration(
    labelText: label,
    isDense: isDense,
    filled: true,
    fillColor: surfaceLight,
  );

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
      onSurface: textPrimary,
      error: error,
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: border),
    );

    return ThemeData(
      brightness: Brightness.light,
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
        // AppBar derives its SystemUiOverlayStyle (status bar icons) from
        // these, so light icons would land on a light bar without them.
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textSecondary),
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
          foregroundColor: onPrimary,
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
      // Inverted for light mode: a dark bar with light text, since
      // surfaceRaised is now near-white.
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(color: onPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      // The style param is non-const, so the defaults stay in the constructor
      // and the whole thing is not `const` (harmless).
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: body,
      ),
    );
  }
}
