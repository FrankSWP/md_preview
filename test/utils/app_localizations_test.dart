import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/utils/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('appTitle returns Chinese translation for zh locale', () {
      expect(AppLocalizations(const Locale('zh')).appTitle, 'Markdown 预览');
    });

    test('appTitle returns English translation for en locale', () {
      expect(AppLocalizations(const Locale('en')).appTitle, 'MD Preview');
    });

    test('appTitle falls back to English for unsupported locale', () {
      expect(AppLocalizations(const Locale('fr')).appTitle, 'MD Preview');
    });

    // ──────────────── Task 24: HomeScreen + FullRecentListScreen ────────────────

    test('home_appbar_title: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeAppbarTitle, 'Markdown 预览');
      expect(AppLocalizations(const Locale('en')).homeAppbarTitle, 'MD Preview');
    });

    test('home_settings_tooltip: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeSettingsTooltip, '设置');
      expect(AppLocalizations(const Locale('en')).homeSettingsTooltip, 'Settings');
    });

    test('home_title: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeTitle, 'Markdown 预览');
      expect(AppLocalizations(const Locale('en')).homeTitle, 'MD Preview');
    });

    test('home_subtitle: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeSubtitle, '从文件管理器打开 .md 文件,或点击下方按钮');
      expect(AppLocalizations(const Locale('en')).homeSubtitle, 'Open a .md file from your file manager, or use the button below.');
    });

    test('home_open_button: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeOpenButton, '打开 Markdown 文件');
      expect(AppLocalizations(const Locale('en')).homeOpenButton, 'Open Markdown File');
    });

    test('home_recent_section_header: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeRecentSectionHeader, '最近文件');
      expect(AppLocalizations(const Locale('en')).homeRecentSectionHeader, 'Recent files');
    });

    test('home_view_all_link: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).homeViewAllLink, '查看全部 →');
      expect(AppLocalizations(const Locale('en')).homeViewAllLink, 'View all →');
    });

    test('recent_card_share_placeholder: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentCardSharePlaceholder, '从分享接收');
      expect(AppLocalizations(const Locale('en')).recentCardSharePlaceholder, 'From share');
    });

    test('recent_removed_snackbar: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentRemovedSnackbar, '已从最近文件中移除');
      expect(AppLocalizations(const Locale('en')).recentRemovedSnackbar, 'Removed from recent files');
    });

    test('recent_undo_action: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentUndoAction, '撤销');
      expect(AppLocalizations(const Locale('en')).recentUndoAction, 'Undo');
    });

    test('recents_appbar_title: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsAppbarTitle, '最近文件');
      expect(AppLocalizations(const Locale('en')).recentsAppbarTitle, 'Recent files');
    });

    test('recents_clear_tooltip: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsClearTooltip, '清空');
      expect(AppLocalizations(const Locale('en')).recentsClearTooltip, 'Clear');
    });

    test('recents_clear_dialog_title: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsClearDialogTitle, '清空最近文件?');
      expect(AppLocalizations(const Locale('en')).recentsClearDialogTitle, 'Clear recent files?');
    });

    test('recents_clear_dialog_body: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsClearDialogBody, '将移除所有最近打开的文件,此操作不可撤销。');
      expect(AppLocalizations(const Locale('en')).recentsClearDialogBody, 'All recently opened files will be removed. This cannot be undone.');
    });

    test('recents_clear_dialog_cancel: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsClearDialogCancel, '取消');
      expect(AppLocalizations(const Locale('en')).recentsClearDialogCancel, 'Cancel');
    });

    test('recents_clear_dialog_confirm: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsClearDialogConfirm, '清空');
      expect(AppLocalizations(const Locale('en')).recentsClearDialogConfirm, 'Clear');
    });

    test('recents_empty_title: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsEmptyTitle, '还没有最近文件');
      expect(AppLocalizations(const Locale('en')).recentsEmptyTitle, 'No recent files yet');
    });

    test('recents_empty_subtitle: zh and en', () {
      expect(AppLocalizations(const Locale('zh')).recentsEmptySubtitle, '打开的 Markdown 文件会在这里显示');
      expect(AppLocalizations(const Locale('en')).recentsEmptySubtitle, 'Markdown files you open will appear here.');
    });

    testWidgets('of(context) returns correct locale inside MaterialApp',
        (tester) async {
      final locale = const Locale('zh');
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
