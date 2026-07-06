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

    group('locale', () {
      test('setLocale persists and can be retrieved after re-create', () async {
        final s1 = await SettingsService.create();
        await s1.setLocale(const Locale('en'));
        expect(s1.locale, const Locale('en'));

        // Re-create to verify persistence
        final s2 = await SettingsService.create();
        expect(s2.locale, const Locale('en'));
      });

      test('setLocale zh persists and round-trips', () async {
        final s1 = await SettingsService.create();
        await s1.setLocale(const Locale('zh'));
        expect(s1.locale, const Locale('zh'));

        final s2 = await SettingsService.create();
        expect(s2.locale, const Locale('zh'));
      });

      test('default locale is zh when no prefs', () async {
        SharedPreferences.setMockInitialValues({});
        final s = await SettingsService.create();
        expect(s.locale, const Locale('zh'));
      });

      test('localeListenable notifies on setLocale', () async {
        final s = await SettingsService.create();
        final fired = <Locale>[];
        s.localeListenable.addListener(() {
          fired.add(s.localeListenable.value);
        });
        await s.setLocale(const Locale('en'));
        expect(fired, [const Locale('en')]);
      });
    });
  });
}