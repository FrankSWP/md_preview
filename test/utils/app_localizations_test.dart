import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/utils/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('appTitle returns Chinese translation for zh locale', () {
      expect(const AppLocalizations(Locale('zh')).appTitle, 'Markdown 预览');
    });

    test('appTitle returns English translation for en locale', () {
      expect(const AppLocalizations(Locale('en')).appTitle, 'MD Preview');
    });

    test('appTitle falls back to English for unsupported locale', () {
      expect(const AppLocalizations(Locale('fr')).appTitle, 'MD Preview');
    });

    // ──────────────── Task 24: HomeScreen + FullRecentListScreen ────────────────

    test('home_appbar_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeAppbarTitle, 'Markdown 预览');
      expect(const AppLocalizations(Locale('en')).homeAppbarTitle, 'MD Preview');
    });

    test('home_settings_tooltip: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeSettingsTooltip, '设置');
      expect(const AppLocalizations(Locale('en')).homeSettingsTooltip, 'Settings');
    });

    test('home_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeTitle, 'Markdown 预览');
      expect(const AppLocalizations(Locale('en')).homeTitle, 'MD Preview');
    });

    test('home_subtitle: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeSubtitle, '从文件管理器打开 .md 文件,或点击下方按钮');
      expect(const AppLocalizations(Locale('en')).homeSubtitle, 'Open a .md file from your file manager, or use the button below.');
    });

    test('home_open_button: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeOpenButton, '打开 Markdown 文件');
      expect(const AppLocalizations(Locale('en')).homeOpenButton, 'Open Markdown File');
    });

    test('home_recent_section_header: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeRecentSectionHeader, '最近文件');
      expect(const AppLocalizations(Locale('en')).homeRecentSectionHeader, 'Recent files');
    });

    test('home_view_all_link: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).homeViewAllLink, '查看全部 →');
      expect(const AppLocalizations(Locale('en')).homeViewAllLink, 'View all →');
    });

    test('recent_card_share_placeholder: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentCardSharePlaceholder, '从分享接收');
      expect(const AppLocalizations(Locale('en')).recentCardSharePlaceholder, 'From share');
    });

    test('recent_removed_snackbar: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentRemovedSnackbar, '已从最近文件中移除');
      expect(const AppLocalizations(Locale('en')).recentRemovedSnackbar, 'Removed from recent files');
    });

    test('recent_undo_action: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentUndoAction, '撤销');
      expect(const AppLocalizations(Locale('en')).recentUndoAction, 'Undo');
    });

    test('recents_appbar_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsAppbarTitle, '最近文件');
      expect(const AppLocalizations(Locale('en')).recentsAppbarTitle, 'Recent files');
    });

    test('recents_clear_tooltip: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsClearTooltip, '清空');
      expect(const AppLocalizations(Locale('en')).recentsClearTooltip, 'Clear');
    });

    test('recents_clear_dialog_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsClearDialogTitle, '清空最近文件?');
      expect(const AppLocalizations(Locale('en')).recentsClearDialogTitle, 'Clear recent files?');
    });

    test('recents_clear_dialog_body: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsClearDialogBody, '将移除所有最近打开的文件,此操作不可撤销。');
      expect(const AppLocalizations(Locale('en')).recentsClearDialogBody, 'All recently opened files will be removed. This cannot be undone.');
    });

    test('recents_clear_dialog_cancel: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsClearDialogCancel, '取消');
      expect(const AppLocalizations(Locale('en')).recentsClearDialogCancel, 'Cancel');
    });

    test('recents_clear_dialog_confirm: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsClearDialogConfirm, '清空');
      expect(const AppLocalizations(Locale('en')).recentsClearDialogConfirm, 'Clear');
    });

    test('recents_empty_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsEmptyTitle, '还没有最近文件');
      expect(const AppLocalizations(Locale('en')).recentsEmptyTitle, 'No recent files yet');
    });

    test('recents_empty_subtitle: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).recentsEmptySubtitle, '打开的 Markdown 文件会在这里显示');
      expect(const AppLocalizations(Locale('en')).recentsEmptySubtitle, 'Markdown files you open will appear here.');
    });

    // ──────────────── Task 25: SettingsScreen ────────────────

    test('settings_appbar_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsAppbarTitle, '设置');
      expect(const AppLocalizations(Locale('en')).settingsAppbarTitle, 'Settings');
    });

    test('settings_section_appearance: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsSectionAppearance, '外观');
      expect(const AppLocalizations(Locale('en')).settingsSectionAppearance, 'Appearance');
    });

    test('settings_theme_label: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsThemeLabel, '主题');
      expect(const AppLocalizations(Locale('en')).settingsThemeLabel, 'Theme');
    });

    test('settings_theme_system: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsThemeSystem, '跟随系统');
      expect(const AppLocalizations(Locale('en')).settingsThemeSystem, 'Follow system');
    });

    test('settings_theme_light: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsThemeLight, '浅色');
      expect(const AppLocalizations(Locale('en')).settingsThemeLight, 'Light');
    });

    test('settings_theme_dark: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsThemeDark, '深色');
      expect(const AppLocalizations(Locale('en')).settingsThemeDark, 'Dark');
    });

    test('settings_section_reading: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsSectionReading, '阅读');
      expect(const AppLocalizations(Locale('en')).settingsSectionReading, 'Reading');
    });

    test('settings_font_size_label: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsFontSizeLabel, '字号');
      expect(const AppLocalizations(Locale('en')).settingsFontSizeLabel, 'Font size');
    });

    test('settings_section_language: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsSectionLanguage, '语言');
      expect(const AppLocalizations(Locale('en')).settingsSectionLanguage, 'Language');
    });

    test('settings_language_label: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsLanguageLabel, '语言');
      expect(const AppLocalizations(Locale('en')).settingsLanguageLabel, 'Language');
    });

    test('settings_language_zh: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsLanguageZh, '中文');
      expect(const AppLocalizations(Locale('en')).settingsLanguageZh, 'Chinese');
    });

    test('settings_language_en: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsLanguageEn, 'English');
      expect(const AppLocalizations(Locale('en')).settingsLanguageEn, 'English');
    });

    test('settings_section_about: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsSectionAbout, '关于');
      expect(const AppLocalizations(Locale('en')).settingsSectionAbout, 'About');
    });

    test('settings_about_version: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).settingsAboutVersion, '版本');
      expect(const AppLocalizations(Locale('en')).settingsAboutVersion, 'Version');
    });

    // ──────────────── Task 25: PreviewScreen ────────────────

    test('preview_appbar_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).previewAppbarTitle, '预览');
      expect(const AppLocalizations(Locale('en')).previewAppbarTitle, 'Preview');
    });

    test('preview_error_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).previewErrorTitle, '打开文件出错');
      expect(const AppLocalizations(Locale('en')).previewErrorTitle, 'Failed to open file');
    });

    test('preview_error_separator: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).previewErrorSeparator, '原因:');
      expect(const AppLocalizations(Locale('en')).previewErrorSeparator, 'Reason:');
    });

    // ──────────────── Task 25: Missing file dialog ────────────────

    test('missing_dialog_title: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).missingDialogTitle, '文件不存在');
      expect(const AppLocalizations(Locale('en')).missingDialogTitle, 'File not found');
    });

    test('missing_dialog_body_prefix: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).missingDialogBodyPrefix, '文件可能已被移动或删除:');
      expect(const AppLocalizations(Locale('en')).missingDialogBodyPrefix, 'The file may have been moved or deleted:');
    });

    test('missing_dialog_cancel: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).missingDialogCancel, '取消');
      expect(const AppLocalizations(Locale('en')).missingDialogCancel, 'Cancel');
    });

    test('missing_dialog_remove: zh and en', () {
      expect(const AppLocalizations(Locale('zh')).missingDialogRemove, '移除');
      expect(const AppLocalizations(Locale('en')).missingDialogRemove, 'Remove');
    });

    testWidgets('of(context) returns correct locale inside MaterialApp',
        (tester) async {
      const locale = Locale('zh');
      final app = MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('zh')],
        home: Builder(
          builder: (context) {
            expect(AppLocalizations.of(context).appTitle, 'Markdown 预览');
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
    });

    group('_AppLocalizationsDelegate', () {
      test('isSupported returns true for en', () {
        const delegate = AppLocalizations.delegate;
        expect(delegate.isSupported(const Locale('en')), true);
      });

      test('isSupported returns true for zh', () {
        const delegate = AppLocalizations.delegate;
        expect(delegate.isSupported(const Locale('zh')), true);
      });

      test('isSupported returns false for fr', () {
        const delegate = AppLocalizations.delegate;
        expect(delegate.isSupported(const Locale('fr')), false);
      });

      test('load returns instance with correct locale', () async {
        const delegate = AppLocalizations.delegate;
        final result = await delegate.load(const Locale('zh'));
        expect(result.locale, const Locale('zh'));
      });
    });
  });
}
