import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsService', () {
    test('getThemeMode defaults to ThemeMode.system', () async {
      final s = await SettingsService.create();
      expect(await s.getThemeMode(), ThemeMode.system);
    });

    test('setThemeMode then getThemeMode returns the value', () async {
      final s = await SettingsService.create();
      await s.setThemeMode(ThemeMode.dark);
      expect(await s.getThemeMode(), ThemeMode.dark);
    });

    test('getFontSize defaults to 16.0', () async {
      final s = await SettingsService.create();
      expect(await s.getFontSize(), 16.0);
    });

    test('setFontSize then getFontSize returns the value', () async {
      final s = await SettingsService.create();
      await s.setFontSize(20.0);
      expect(await s.getFontSize(), 20.0);
    });

    test('themeModeListenable fires on setThemeMode', () async {
      final s = await SettingsService.create();
      final fired = <ThemeMode>[];
      s.themeModeListenable.addListener(() {
        fired.add(s.themeModeListenable.value);
      });
      await s.setThemeMode(ThemeMode.dark);
      expect(fired, [ThemeMode.dark]);
    });
  });
}