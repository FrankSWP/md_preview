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

      // Task 25 — SettingsScreen
      'settings_appbar_title': 'Settings',
      'settings_section_appearance': 'Appearance',
      'settings_theme_label': 'Theme',
      'settings_theme_system': 'Follow system',
      'settings_theme_light': 'Light',
      'settings_theme_dark': 'Dark',
      'settings_section_reading': 'Reading',
      'settings_font_size_label': 'Font size',
      'settings_section_language': 'Language',
      'settings_language_label': 'Language',
      'settings_language_zh': 'Chinese',
      'settings_language_en': 'English',
      'settings_section_about': 'About',
      'settings_about_version': 'Version',

      // Task 25 — PreviewScreen
      'preview_appbar_title': 'Preview',
      'preview_error_title': 'Failed to open file',
      'preview_error_separator': 'Reason:',

      // Task 25 — Missing file dialog
      'missing_dialog_title': 'File not found',
      'missing_dialog_body_prefix': 'The file may have been moved or deleted:',
      'missing_dialog_cancel': 'Cancel',
      'missing_dialog_remove': 'Remove',
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

      // Task 25 — SettingsScreen
      'settings_appbar_title': '设置',
      'settings_section_appearance': '外观',
      'settings_theme_label': '主题',
      'settings_theme_system': '跟随系统',
      'settings_theme_light': '浅色',
      'settings_theme_dark': '深色',
      'settings_section_reading': '阅读',
      'settings_font_size_label': '字号',
      'settings_section_language': '语言',
      'settings_language_label': '语言',
      'settings_language_zh': '中文',
      'settings_language_en': 'English',
      'settings_section_about': '关于',
      'settings_about_version': '版本',

      // Task 25 — PreviewScreen
      'preview_appbar_title': '预览',
      'preview_error_title': '打开文件出错',
      'preview_error_separator': '原因:',

      // Task 25 — Missing file dialog
      'missing_dialog_title': '文件不存在',
      'missing_dialog_body_prefix': '文件可能已被移动或删除:',
      'missing_dialog_cancel': '取消',
      'missing_dialog_remove': '移除',
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

  // ──────────────── SettingsScreen (Task 25) ────────────────
  String get settingsAppbarTitle => _t('settings_appbar_title');
  String get settingsSectionAppearance => _t('settings_section_appearance');
  String get settingsThemeLabel => _t('settings_theme_label');
  String get settingsThemeSystem => _t('settings_theme_system');
  String get settingsThemeLight => _t('settings_theme_light');
  String get settingsThemeDark => _t('settings_theme_dark');
  String get settingsSectionReading => _t('settings_section_reading');
  String get settingsFontSizeLabel => _t('settings_font_size_label');
  String get settingsSectionLanguage => _t('settings_section_language');
  String get settingsLanguageLabel => _t('settings_language_label');
  String get settingsLanguageZh => _t('settings_language_zh');
  String get settingsLanguageEn => _t('settings_language_en');
  String get settingsSectionAbout => _t('settings_section_about');
  String get settingsAboutVersion => _t('settings_about_version');

  // ──────────────── PreviewScreen (Task 25) ────────────────
  String get previewAppbarTitle => _t('preview_appbar_title');
  String get previewErrorTitle => _t('preview_error_title');
  String get previewErrorSeparator => _t('preview_error_separator');

  // ──────────────── Missing file dialog (Task 25) ────────────────
  String get missingDialogTitle => _t('missing_dialog_title');
  String get missingDialogBodyPrefix => _t('missing_dialog_body_prefix');
  String get missingDialogCancel => _t('missing_dialog_cancel');
  String get missingDialogRemove => _t('missing_dialog_remove');
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
