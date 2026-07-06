import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user settings (theme mode, font size) using
/// [SharedPreferences] and exposes a [ValueListenable] for
/// each so widgets can rebuild reactively.
class SettingsService {
  static const _kThemeMode = 'theme_mode';
  static const _kFontSize = 'font_size';
  static const _kLocale = 'locale';

  static const _defaultFontSize = 16.0;
  static const _minFontSize = 10.0;
  static const _maxFontSize = 32.0;

  final SharedPreferences _prefs;
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<double> _fontSize = ValueNotifier(_defaultFontSize);
  final ValueNotifier<Locale> _locale = ValueNotifier(const Locale('zh'));

  SettingsService._(this._prefs) {
    _themeMode.value = _readThemeMode();
    _fontSize.value = _readFontSize();
    _locale.value = _readLocale();
  }

  /// Loads the underlying [SharedPreferences] then constructs the service.
  /// Tests should call this with [SharedPreferences.setMockInitialValues]
  /// set up first.
  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  ValueListenable<ThemeMode> get themeModeListenable => _themeMode;
  ValueListenable<double> get fontSizeListenable => _fontSize;
  ValueListenable<Locale> get localeListenable => _locale;

  Future<ThemeMode> getThemeMode() async => _themeMode.value;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode.value == mode) return;
    await _prefs.setString(_kThemeMode, _encodeThemeMode(mode));
    _themeMode.value = mode;
  }

  Locale get locale => _locale.value;

  Future<void> setLocale(Locale locale) async {
    if (_locale.value == locale) return;
    await _prefs.setString(_kLocale, _encodeLocale(locale));
    _locale.value = locale;
  }

  Future<double> getFontSize() async => _fontSize.value;

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(_minFontSize, _maxFontSize);
    if (_fontSize.value == clamped) return;
    await _prefs.setDouble(_kFontSize, clamped);
    _fontSize.value = clamped;
  }

  ThemeMode _readThemeMode() {
    final raw = _prefs.getString(_kThemeMode);
    return _decodeThemeMode(raw) ?? ThemeMode.system;
  }

  double _readFontSize() {
    final raw = _prefs.getDouble(_kFontSize);
    if (raw == null) return _defaultFontSize;
    return raw.clamp(_minFontSize, _maxFontSize);
  }

  static String _encodeThemeMode(ThemeMode m) => switch (m) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };

  static ThemeMode? _decodeThemeMode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      };

  Locale _readLocale() {
    final raw = _prefs.getString(_kLocale);
    if (raw == null) return const Locale('zh');
    return Locale(raw);
  }

  static String _encodeLocale(Locale l) => l.languageCode;
}