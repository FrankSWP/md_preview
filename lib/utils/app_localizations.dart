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
      'home_appbar_title': 'MD Preview',
      'home_settings_tooltip': 'Settings',
      'home_title': 'MD Preview',
      'home_subtitle': 'Open a .md file from your file manager, or use the button below.',
      'home_open_button': 'Open Markdown File',
      'home_recent_section_header': 'Recent files',
      'home_view_all_link': 'View all →',
      'recent_card_share_placeholder': 'From share',
      'recent_removed_snackbar': 'Removed from recent files',
      'recent_undo_action': 'Undo',
      'recents_appbar_title': 'Recent files',
      'recents_clear_tooltip': 'Clear',
      'recents_clear_dialog_title': 'Clear recent files?',
      'recents_clear_dialog_body': 'All recently opened files will be removed. This cannot be undone.',
      'recents_clear_dialog_cancel': 'Cancel',
      'recents_clear_dialog_confirm': 'Clear',
      'recents_empty_title': 'No recent files yet',
      'recents_empty_subtitle': 'Markdown files you open will appear here.',
    },
    'zh': {
      'app_title': 'Markdown 预览',
      'home_appbar_title': 'Markdown 预览',
      'home_settings_tooltip': '设置',
      'home_title': 'Markdown 预览',
      'home_subtitle': '从文件管理器打开 .md 文件,或点击下方按钮',
      'home_open_button': '打开 Markdown 文件',
      'home_recent_section_header': '最近文件',
      'home_view_all_link': '查看全部 →',
      'recent_card_share_placeholder': '从分享接收',
      'recent_removed_snackbar': '已从最近文件中移除',
      'recent_undo_action': '撤销',
      'recents_appbar_title': '最近文件',
      'recents_clear_tooltip': '清空',
      'recents_clear_dialog_title': '清空最近文件?',
      'recents_clear_dialog_body': '将移除所有最近打开的文件,此操作不可撤销。',
      'recents_clear_dialog_cancel': '取消',
      'recents_clear_dialog_confirm': '清空',
      'recents_empty_title': '还没有最近文件',
      'recents_empty_subtitle': '打开的 Markdown 文件会在这里显示',
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
  // Task 23 adds only the keys the app-wide skeleton needs:
  String get appTitle => _t('app_title');

  // ──────────────── HomeScreen + FullRecentListScreen (Task 24) ────────────────
  String get homeAppbarTitle => _t('home_appbar_title');
  String get homeSettingsTooltip => _t('home_settings_tooltip');
  String get homeTitle => _t('home_title');
  String get homeSubtitle => _t('home_subtitle');
  String get homeOpenButton => _t('home_open_button');
  String get homeRecentSectionHeader => _t('home_recent_section_header');
  String get homeViewAllLink => _t('home_view_all_link');
  String get recentCardSharePlaceholder => _t('recent_card_share_placeholder');
  String get recentRemovedSnackbar => _t('recent_removed_snackbar');
  String get recentUndoAction => _t('recent_undo_action');
  String get recentsAppbarTitle => _t('recents_appbar_title');
  String get recentsClearTooltip => _t('recents_clear_tooltip');
  String get recentsClearDialogTitle => _t('recents_clear_dialog_title');
  String get recentsClearDialogBody => _t('recents_clear_dialog_body');
  String get recentsClearDialogCancel => _t('recents_clear_dialog_cancel');
  String get recentsClearDialogConfirm => _t('recents_clear_dialog_confirm');
  String get recentsEmptyTitle => _t('recents_empty_title');
  String get recentsEmptySubtitle => _t('recents_empty_subtitle');
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
