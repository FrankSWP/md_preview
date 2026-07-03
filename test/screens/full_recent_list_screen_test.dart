import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/screens/full_recent_list_screen.dart';
import 'package:md_preview/services/recent_files_repository.dart';
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
  }) {
    return MaterialApp(
      home: FullRecentListScreen(
        recents: repo,
        onOpenFile: onOpenFile,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Test 1: Empty state — shows '还没有最近文件' title
  // -------------------------------------------------------------------------
  testWidgets('empty state: shows 还没有最近文件 title', (tester) async {
    final repo = await buildRepo();
    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('还没有最近文件'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 2: With 3 entries — all 3 filenames shown
  // -------------------------------------------------------------------------
  testWidgets('with 3 entries: all 3 filenames are shown', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/a.md', name: 'a.md');
    await repo.add(path: '/storage/b.md', name: 'b.md');
    await repo.add(path: '/storage/c.md', name: 'c.md');

    await tester.pumpWidget(buildScreen(repo: repo));
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

    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    // Scroll through the list and verify each file appears.
    final listView = find.byType(ListView);
    for (int i = 0; i < 50; i++) {
      // Each item must be findable when scrolled into view.
      expect(
        find.descendant(anchor: listView, matching: find.text('file_$i.md')),
        findsOneWidget,
      );
      // Scroll down ~60px per step (approximate tile height).
      await tester.drag(listView, const Offset(0, -60));
      await tester.pump();
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
      onOpenFile: (file) => openedFile = file,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('notes.md'));
    await tester.pump();

    expect(openedFile?.name, equals('notes.md'));
    expect(openedFile?.path, equals('/storage/notes.md'));
  });

  // -------------------------------------------------------------------------
  // Test 5: Tap a card pops the route
  // -------------------------------------------------------------------------
  testWidgets('tap a card pops the route', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    // Push FullRecentListScreen onto a route stack so there is a route to pop to.
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: Center(child: Text('home'))),
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
    await tester.pump();

    // After pop, FullRecentListScreen is removed from the tree.
    expect(find.byType(FullRecentListScreen), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Test 6: Long-press a card removes it
  // -------------------------------------------------------------------------
  testWidgets('long-press a card removes it', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsOneWidget);

    await tester.longPress(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsNothing);
    expect(find.text('已从最近文件中移除'), findsOneWidget);
    expect(find.text('撤销'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 7: "清空" button shows confirmation dialog with '清空最近文件?'
  // -------------------------------------------------------------------------
  testWidgets('清空 button shows confirmation dialog with 清空最近文件?', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();

    expect(find.text('清空最近文件?'), findsOneWidget);
    expect(
      find.text('将移除所有最近打开的文件,此操作不可撤销。'),
      findsOneWidget,
    );
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 8: Confirming the dialog calls recents.clear()
  // -------------------------------------------------------------------------
  testWidgets('confirming the dialog calls recents.clear()', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await tester.pumpWidget(buildScreen(repo: repo));
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

    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsOneWidget);
    expect(find.text('API设计.md'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 10: AppBar shows '最近文件' title
  // -------------------------------------------------------------------------
  testWidgets('AppBar shows 最近文件 title', (tester) async {
    final repo = await buildRepo();
    await tester.pumpWidget(buildScreen(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('最近文件'), findsOneWidget);
  });
}
