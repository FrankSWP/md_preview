import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/screens/home_screen.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Helper: build HomeScreen with optional repo and locale
  // -------------------------------------------------------------------------
  Future<RecentFilesRepository> buildRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return RecentFilesRepository(prefs: prefs);
  }

  Future<void> pumpHome({
    required WidgetTester tester,
    required VoidCallback onOpenFile,
    VoidCallback? onViewAllRecents,
    RecentFilesRepository? recents,
    ValueChanged<RecentFile>? onOpenRecent,
    Locale locale = const Locale('zh'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('zh')],
        home: HomeScreen(
          onOpenFile: onOpenFile,
          onViewAllRecents: onViewAllRecents,
          recents: recents,
          onOpenRecent: onOpenRecent,
        ),
        routes: {
          '/settings': (_) => const Scaffold(body: Text('settings-stub')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  // -------------------------------------------------------------------------
  // Tests 1-4: AppBar title, open button, subtitle, settings tooltip (both locales)
  // -------------------------------------------------------------------------

  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('AppBar title ($lang)', (tester) async {
      await pumpHome(tester: tester, onOpenFile: () {}, locale: locale);
      final expected = lang == 'zh' ? 'Markdown 预览' : 'MD Preview';
      expect(find.text(expected), findsAtLeastNWidgets(1));
    });

    testWidgets('open button label ($lang)', (tester) async {
      await pumpHome(tester: tester, onOpenFile: () {}, locale: locale);
      final expected = lang == 'zh' ? '打开 Markdown 文件' : 'Open Markdown File';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('subtitle ($lang)', (tester) async {
      await pumpHome(tester: tester, onOpenFile: () {}, locale: locale);
      final expected = lang == 'zh'
          ? '从文件管理器打开 .md 文件,或点击下方按钮'
          : 'Open a .md file from your file manager, or use the button below.';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('Settings tooltip ($lang)', (tester) async {
      await pumpHome(tester: tester, onOpenFile: () {}, locale: locale);
      final expected = lang == 'zh' ? '设置' : 'Settings';
      expect(find.byTooltip(expected), findsOneWidget);
    });
  }

  testWidgets('tapping open button calls onOpenFile', (tester) async {
    var opened = false;
    await pumpHome(
      tester: tester,
      locale: const Locale('zh'),
      onOpenFile: () => opened = true,
    );
    await tester.tap(find.text('打开 Markdown 文件'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  testWidgets('tapping settings icon pushes /settings route', (tester) async {
    await pumpHome(
      tester: tester,
      locale: const Locale('zh'),
      onOpenFile: () {},
    );
    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    expect(find.text('settings-stub'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Tests 5-6: recents section hidden when null or empty
  // -------------------------------------------------------------------------

  testWidgets('with recents == null: no 最近文件 header', (tester) async {
    await pumpHome(tester: tester, locale: const Locale('zh'), onOpenFile: () {});
    expect(find.text('最近文件'), findsNothing);
  });

  testWidgets('with empty recents: no 最近文件 header', (tester) async {
    final repo = await buildRepo();
    await pumpHome(tester: tester, locale: const Locale('zh'), onOpenFile: () {}, recents: repo);
    expect(find.text('最近文件'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Tests 7-10: recents section content
  // -------------------------------------------------------------------------

  testWidgets('with 2 recent entries: both filenames are shown', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await pumpHome(tester: tester, locale: const Locale('zh'), onOpenFile: () {}, recents: repo);

    expect(find.text('notes.md'), findsOneWidget);
    expect(find.text('API设计.md'), findsOneWidget);
  });

  testWidgets('with 5 recent entries: only first 3 are shown', (tester) async {
    final repo = await buildRepo();
    for (final name in [
      'a.md', 'b.md', 'c.md', 'd.md', 'e.md',
    ]) {
      await repo.add(path: '/storage/$name', name: name);
    }

    await pumpHome(tester: tester, locale: const Locale('zh'), onOpenFile: () {}, recents: repo);

    expect(find.text('e.md'), findsOneWidget);
    expect(find.text('d.md'), findsOneWidget);
    expect(find.text('c.md'), findsOneWidget);
    expect(find.text('a.md'), findsNothing);
    expect(find.text('b.md'), findsNothing);
  });

  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('with 5 recent entries: View all link is shown ($lang)', (tester) async {
      final repo = await buildRepo();
      for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
        await repo.add(path: '/storage/$name', name: name);
      }

      await pumpHome(
        tester: tester,
        locale: locale,
        onOpenFile: () {},
        onViewAllRecents: () {},
        recents: repo,
      );

      final expected = lang == 'zh' ? '查看全部 →' : 'View all →';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('with 2 recent entries: View all link is NOT shown ($lang)', (tester) async {
      final repo = await buildRepo();
      await repo.add(path: '/storage/a.md', name: 'a.md');
      await repo.add(path: '/storage/b.md', name: 'b.md');

      await pumpHome(tester: tester, locale: locale, onOpenFile: () {}, recents: repo);

      final expected = lang == 'zh' ? '查看全部 →' : 'View all →';
      expect(find.text(expected), findsNothing);
    });
  }

  // -------------------------------------------------------------------------
  // Regression: tapping the "查看全部" link must invoke the callback.
  // -------------------------------------------------------------------------
  testWidgets('tapping View all link invokes onViewAllRecents', (tester) async {
    final repo = await buildRepo();
    for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
      await repo.add(path: '/storage/$name', name: name);
    }

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var viewAllInvoked = false;
    await pumpHome(
      tester: tester,
      locale: const Locale('zh'),
      onOpenFile: () {},
      recents: repo,
      onViewAllRecents: () => viewAllInvoked = true,
    );

    expect(find.text('查看全部 →'), findsOneWidget);
    await tester.tap(find.text('查看全部 →'));
    await tester.pumpAndSettle();

    expect(viewAllInvoked, isTrue);
  });

  // -------------------------------------------------------------------------
  // Test: tap recent card calls onOpenRecent (NOT onOpenFile)
  // -------------------------------------------------------------------------

  testWidgets('tapping a recent file card calls onOpenRecent (NOT onOpenFile)', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    RecentFile? openedFile;
    var pickerOpened = false;
    await pumpHome(
      tester: tester,
      locale: const Locale('zh'),
      onOpenFile: () => pickerOpened = true,
      recents: repo,
      onOpenRecent: (file) => openedFile = file,
    );

    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(openedFile?.name, equals('notes.md'));
    expect(openedFile?.path, equals('/storage/notes.md'));
    expect(pickerOpened, isFalse);
  });

  // -------------------------------------------------------------------------
  // Test: when onOpenRecent is null, tapping a card does nothing
  // -------------------------------------------------------------------------

  testWidgets('when onOpenRecent is null, tapping a card does nothing (no crash)', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    var pickerOpened = false;
    await pumpHome(
      tester: tester,
      locale: const Locale('zh'),
      onOpenFile: () => pickerOpened = true,
      recents: repo,
      onOpenRecent: null,
    );

    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(pickerOpened, isFalse);
  });

  // -------------------------------------------------------------------------
  // Test: long-press removes and shows snackbar (both locales)
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('long-pressing a recent card removes it and shows snackbar ($lang)', (tester) async {
      final repo = await buildRepo();
      await repo.add(path: '/storage/notes.md', name: 'notes.md');

      await pumpHome(tester: tester, locale: locale, onOpenFile: () {}, recents: repo);

      expect(find.text('notes.md'), findsOneWidget);

      await tester.longPress(find.text('notes.md'));
      await tester.pumpAndSettle();

      expect(find.text('notes.md'), findsNothing);
      final snackbarText = lang == 'zh' ? '已从最近文件中移除' : 'Removed from recent files';
      final undoText = lang == 'zh' ? '撤销' : 'Undo';
      expect(find.text(snackbarText), findsOneWidget);
      expect(find.text(undoText), findsOneWidget);
    });
  }

  // -------------------------------------------------------------------------
  // Test: content:// shows From share / 从分享接收
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('content:// recents show share placeholder instead of parent dir ($lang)', (tester) async {
      final repo = await buildRepo();
      await repo.add(path: 'content://com.example.app/file/123', name: 'shared.md');

      await pumpHome(tester: tester, locale: locale, onOpenFile: () {}, recents: repo);

      final placeholder = lang == 'zh' ? '从分享接收' : 'From share';
      expect(find.textContaining(placeholder), findsOneWidget);
      // It should NOT contain a path segment
      expect(find.textContaining('/'), findsNothing);
    });
  }
}
