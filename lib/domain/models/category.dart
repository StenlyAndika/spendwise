import 'package:flutter/material.dart';

/// Predefined palette for known categories; unknown ones get a fallback.
class CategoryColors {
  static const palette = <String, Color>{
    'Langganan': Color(0xFF65B7FF),
    'Makanan': Color(0xFFFFB454),
    'Transport': Color(0xFF47D18C),
    'Belanja': Color(0xFFFF6B7A),
    'Hiburan': Color(0xFFB794F4),
    'Kesehatan': Color(0xFF00FFDE),
    'Minuman': Color(0xFFFF8A65),
  };

  static const fallback = [
    Color(0xFF7C9EFF),
    Color(0xFFE07B9C),
    Color(0xFF8BC34A),
    Color(0xFFFFD54F),
    Color(0xFF4DD0E1),
  ];

  static Color forName(String name) {
    if (palette.containsKey(name)) return palette[name]!;
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return fallback[hash % fallback.length];
  }
}
