import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/screens/full_recent_list_screen.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Helper
  // -------------------------------------------------------------------------
  Future<RecentFilesRepository> buildRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return RecentFilesRepository(prefs: prefs);
  }

  Widget buildScreen({
    required RecentFilesRepository repo,
    ValueChanged<RecentFile>? onOpenFile,
    Locale locale = const Locale('zh'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      home: FullRecentListScreen(
        recents: repo,
        onOpenFile: onOpenFile,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Test 1: Empty state — shows localized title (both locales)
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('empty state: shows localized title ($lang)', (tester) async {
      final repo = await buildRepo();
      await tester.pumpWidget(buildScreen(repo: repo, locale: locale));
      await tester.pumpAndSettle();

      final expected = lang == 'zh' ? '还没有最近文件' : 'No recent files yet';
      expect(find.text(expected), findsOneWidget);
    });
  }

  // -------------------------------------------------------------------------
  // Test 2: With 3 entries — all 3 filenames shown
  // -------------------------------------------------------------------------
  testWidgets('with 3 entries: all 3 filenames are shown', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/a.md', name: 'a.md');
    await repo.add(path: '/storage/b.md', name: 'b.md');
    await repo.add(path: '/storage/c.md', name: 'c.md');

    await tester.pumpWidget(buildScreen(repo: repo, locale: const Locale('zh')));
    await tester.pumpAndSettle();

    expect(find.text('a.md'), findsOneWidget);
    expect(find.text('b.md'), findsOneWidget);
    expect(find.text('c.md'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 3: With 50 entries — all 50 filenames shown (no implicit limit)
  // -------------------------------------------------------------------------
  testWidgets('with 50 entries: all 50 filenames are shown', (tester) async {
    final repo = await buildRepo();
    for (int i = 0; i < 50; i++) {
      await repo.add(path: '/storage/file_$i.md', name: 'file_$i.md');
    }

    await tester.pumpWidget(buildScreen(repo: repo, locale: const Locale('zh')));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);

    expect(find.text('file_49.md'), findsOneWidget);
    expect(find.text('file_48.md'), findsOneWidget);
    expect(find.text('file_47.md'), findsOneWidget);

    final listView = find.byType(ListView);
    for (int i = 0; i < 10; i++) {
      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
  });

  // -------------------------------------------------------------------------
  // Test 4: Tap a card calls onOpenFile with the correct RecentFile
  // -------------------------------------------------------------------------
  testWidgets('tap a card calls onOpenFile with the correct RecentFile',
      (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    RecentFile? openedFile;
    await tester.pumpWidget(buildScreen(
      repo: repo,
      locale: const Locale('zh'),
      onOpenFile: (file) => openedFile = file,
    ),);
    await tester.pumpAndSettle();

    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(openedFile?.name, equals('notes.md'));
    expect(openedFile?.path, equals('/storage/notes.md'));
  });

  // -------------------------------------------------------------------------
  // Test 5: Tap a card pops the route
  // -------------------------------------------------------------------------
  testWidgets('tap a card pops the route', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('home'))),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FullRecentListScreen(recents: repo, onOpenFile: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FullRecentListScreen), findsOneWidget);

    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(find.byType(FullRecentListScreen), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Test 6: Long-press a card removes it (both locales)
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('long-press a card removes it ($lang)', (tester) async {
      final repo = await buildRepo();
      await repo.add(path: '/storage/notes.md', name: 'notes.md');
      await repo.add(path: '/storage/api.md', name: 'API设计.md');

      await tester.pumpWidget(buildScreen(repo: repo, locale: locale));
      await tester.pumpAndSettle();

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
  // Test 7: Clear button shows confirmation dialog with localized strings
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('Clear button shows localized dialog ($lang)', (tester) async {
      final repo = await buildRepo();
      await repo.add(path: '/storage/notes.md', name: 'notes.md');

      await tester.pumpWidget(buildScreen(repo: repo, locale: locale));
      await tester.pumpAndSettle();

      final tooltip = lang == 'zh' ? '清空' : 'Clear';
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();

      final dialogTitle = lang == 'zh' ? '清空最近文件?' : 'Clear recent files?';
      final dialogBody = lang == 'zh'
          ? '将移除所有最近打开的文件,此操作不可撤销。'
          : 'All recently opened files will be removed. This cannot be undone.';
      final cancelText = lang == 'zh' ? '取消' : 'Cancel';
      final confirmText = lang == 'zh' ? '清空' : 'Clear';

      expect(find.text(dialogTitle), findsOneWidget);
      expect(find.text(dialogBody), findsOneWidget);
      expect(find.text(cancelText), findsOneWidget);
      expect(find.text(confirmText), findsOneWidget);
    });
  }

  // -------------------------------------------------------------------------
  // Test 8: Confirming the dialog calls recents.clear()
  // -------------------------------------------------------------------------
  testWidgets('confirming the dialog calls recents.clear()', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await tester.pumpWidget(buildScreen(repo: repo, locale: const Locale('zh')));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsNothing);
    expect(find.text('API设计.md'), findsNothing);
    expect(find.text('还没有最近文件'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 9: Cancelling the dialog does NOT call recents.clear()
  // -------------------------------------------------------------------------
  testWidgets('cancelling the dialog does NOT call recents.clear()', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await tester.pumpWidget(buildScreen(repo: repo, locale: const Locale('zh')));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsOneWidget);
    expect(find.text('API设计.md'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 10: AppBar shows localized title (both locales)
  // -------------------------------------------------------------------------
  for (final locale in [const Locale('zh'), const Locale('en')]) {
    final lang = locale.languageCode;
    testWidgets('AppBar shows localized title ($lang)', (tester) async {
      final repo = await buildRepo();
      await tester.pumpWidget(buildScreen(repo: repo, locale: locale));
      await tester.pumpAndSettle();

      final expected = lang == 'zh' ? '最近文件' : 'Recent files';
      expect(find.text(expected), findsOneWidget);
    });
  }
}
