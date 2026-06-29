import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/theme/app_theme.dart';

void main() {
  test('buildLightTheme is a Material 3 light theme', () {
    final t = buildLightTheme();
    expect(t.useMaterial3, isTrue);
    expect(t.brightness, Brightness.light);
  });

  test('buildDarkTheme is a Material 3 dark theme', () {
    final t = buildDarkTheme();
    expect(t.useMaterial3, isTrue);
    expect(t.brightness, Brightness.dark);
  });

  test('markdownBodyStyle reflects font size and brightness', () {
    final s = markdownBodyStyle(fontSize: 18, brightness: Brightness.dark);
    expect(s.fontSize, 18);
    expect(s.color, isNotNull);
  });
}