import 'package:flutter/material.dart';

/// Per-locale lookup table. Keys are snake_case; values are the translated strings.
///
/// To add a new key:
///   1. Add the English value under 'en'.
///   2. Add the translation under every other locale (zh at minimum).
///   3. Add a typed getter below.
///   4. Use it from a screen: AppLocalizations.of(context).yourKey
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  /// Look up an AppLocalizations from the widget tree. Falls back to the
  /// default English instance if none is registered (e.g. in tests).
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)
        ?? AppLocalizations._default;
  }

  /// The default locale when nothing is configured. Matches the system's
  /// pre-i18n behavior: English strings.
  static const AppLocalizations _default = AppLocalizations(Locale('en'));

  /// Two-locale table. English is the canonical key set.
  static const Map<String, Map<String, String>> _values = {
    'en': {
      'app_title': 'MD Preview',
    },
    'zh': {
      'app_title': 'Markdown 预览',
    },
  };

  String _t(String key) {
    final byLocale = _values[locale.languageCode];
    if (byLocale != null) {
      final v = byLocale[key];
      if (v != null) return v;
    }
    // Fallback to English if missing in the requested locale.
    final byEn = _values['en']?[key];
    return byEn ?? key;
  }

  /// The current locale's `LocalizationsDelegate`. Registered with MaterialApp.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ──────────────── Typed string getters ────────────────
  // Tasks 24-27 will add getters here as they translate each screen.
  // Task 23 adds only the keys the app-wide skeleton needs:
  String get appTitle => _t('app_title');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
