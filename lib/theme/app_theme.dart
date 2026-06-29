import 'package:flutter/material.dart';

const _seed = Color(0xFF1976D2);

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _seed);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

TextStyle markdownBodyStyle({
  required double fontSize,
  required Brightness brightness,
}) {
  final base = brightness == Brightness.dark
      ? ThemeData.dark().textTheme.bodyMedium
      : ThemeData.light().textTheme.bodyMedium;
  return (base ?? const TextStyle()).copyWith(
    fontSize: fontSize,
    height: 1.55,
  );
}