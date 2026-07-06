import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/screens/home_screen.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Helper: build HomeScreen with optional repo
  // -------------------------------------------------------------------------
  Future<RecentFilesRepository> buildRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return RecentFilesRepository(prefs: prefs);
  }

  Widget buildHome({
    required VoidCallback onOpenFile,
    VoidCallback? onViewAllRecents,
    RecentFilesRepository? recents,
    ValueChanged<RecentFile>? onOpenRecent,
  }) {
    return MaterialApp(
      home: HomeScreen(
        onOpenFile: onOpenFile,
        onViewAllRecents: onViewAllRecents,
        recents: recents,
        onOpenRecent: onOpenRecent,
      ),
      routes: {
        '/settings': (_) => const Scaffold(body: Text('settings-stub')),
      },
    );
  }

  // -------------------------------------------------------------------------
  // Tests 1-6: Chinese strings and basic interactions (no recents)
  // -------------------------------------------------------------------------

  testWidgets('renders Chinese AppBar title', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    expect(find.text('Markdown 预览'), findsAtLeastNWidgets(1));
  });

  testWidgets('renders Chinese open button label', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    expect(find.text('打开 Markdown 文件'), findsOneWidget);
  });

  testWidgets('renders Chinese subtitle', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    expect(find.text('从文件管理器打开 .md 文件,或点击下方按钮'), findsOneWidget);
  });

  testWidgets('renders Chinese Settings tooltip', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    expect(find.byTooltip('设置'), findsOneWidget);
  });

  testWidgets('tapping open button calls onOpenFile', (tester) async {
    var opened = false;
    await tester.pumpWidget(buildHome(onOpenFile: () => opened = true));
    await tester.tap(find.text('打开 Markdown 文件'));
    expect(opened, isTrue);
  });

  testWidgets('tapping settings icon pushes /settings route', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    expect(find.text('settings-stub'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Tests 7-8: recents section hidden when null or empty
  // -------------------------------------------------------------------------

  testWidgets('with recents == null: no 最近文件 header', (tester) async {
    await tester.pumpWidget(buildHome(onOpenFile: () {}));
    expect(find.text('最近文件'), findsNothing);
  });

  testWidgets('with empty recents: no 最近文件 header', (tester) async {
    final repo = await buildRepo();
    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();
    expect(find.text('最近文件'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Tests 9-12: recents section content
  // -------------------------------------------------------------------------

  testWidgets('with 2 recent entries: both filenames are shown', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/api.md', name: 'API设计.md');

    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();

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

    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();

    expect(find.text('e.md'), findsOneWidget);
    expect(find.text('d.md'), findsOneWidget);
    expect(find.text('c.md'), findsOneWidget);
    expect(find.text('a.md'), findsNothing);
    expect(find.text('b.md'), findsNothing);
  });

  testWidgets('with 5 recent entries: 查看全部 link is shown', (tester) async {
    final repo = await buildRepo();
    for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
      await repo.add(path: '/storage/$name', name: name);
    }

    await tester.pumpWidget(buildHome(onOpenFile: () {}, onViewAllRecents: () {}, recents: repo));
    await tester.pumpAndSettle();

    expect(find.text('查看全部 →'), findsOneWidget);
  });

  testWidgets('with 2 recent entries: 查看全部 link is NOT shown', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/a.md', name: 'a.md');
    await repo.add(path: '/storage/b.md', name: 'b.md');

    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();

    expect(find.text('查看全部 →'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // Regression: tapping the "查看全部" link must invoke the callback.
  // (v0.2.0/v0.2.1 used a bare GestureDetector wrapping a Text, which had a
  // near-zero hit area and was eaten by the parent ScrollView. v0.2.2 uses
  // TextButton which has its own tappable region.)
  // -------------------------------------------------------------------------
  testWidgets('tapping 查看全部 link invokes onViewAllRecents', (tester) async {
    final repo = await buildRepo();
    for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
      await repo.add(path: '/storage/$name', name: name);
    }

    // Use a tall test surface so the link is on-screen (default 800x600
    // is too short for 5 recents + the link).
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var viewAllInvoked = false;
    await tester.pumpWidget(buildHome(
      onOpenFile: () {},
      recents: repo,
      onViewAllRecents: () => viewAllInvoked = true,
    ),);
    await tester.pumpAndSettle();

    expect(find.text('查看全部 →'), findsOneWidget);
    await tester.tap(find.text('查看全部 →'));
    await tester.pumpAndSettle();

    expect(viewAllInvoked, isTrue);
  });

  // -------------------------------------------------------------------------
  // Test 13: tap recent card calls onOpenRecent (NOT onOpenFile)
  // -------------------------------------------------------------------------

  testWidgets('tapping a recent file card calls onOpenRecent (NOT onOpenFile)', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    RecentFile? openedFile;
    var pickerOpened = false;
    await tester.pumpWidget(buildHome(
      onOpenFile: () => pickerOpened = true,
      recents: repo,
      onOpenRecent: (file) => openedFile = file,
    ),);
    await tester.pumpAndSettle();

    // tap the card
    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    // Should call onOpenRecent, NOT onOpenFile
    expect(openedFile?.name, equals('notes.md'));
    expect(openedFile?.path, equals('/storage/notes.md'));
    expect(pickerOpened, isFalse);
  });

  // -------------------------------------------------------------------------
  // Test 14: when onOpenRecent is null, tapping a card does nothing
  // -------------------------------------------------------------------------

  testWidgets('when onOpenRecent is null, tapping a card does nothing (no crash)', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    var pickerOpened = false;
    await tester.pumpWidget(buildHome(
      onOpenFile: () => pickerOpened = true,
      recents: repo,
      onOpenRecent: null, // explicitly null
    ),);
    await tester.pumpAndSettle();

    // tap the card — should not crash and should not call onOpenFile
    await tester.tap(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(pickerOpened, isFalse);
  });

  // -------------------------------------------------------------------------
  // Test 15: long-press removes and shows snackbar
  // -------------------------------------------------------------------------

  testWidgets('long-pressing a recent card removes it and shows snackbar', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsOneWidget);

    await tester.longPress(find.text('notes.md'));
    await tester.pumpAndSettle();

    expect(find.text('notes.md'), findsNothing);
    expect(find.text('已从最近文件中移除'), findsOneWidget);
    expect(find.text('撤销'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 16: content:// shows 从分享接收
  // -------------------------------------------------------------------------

  testWidgets('content:// recents show 从分享接收 instead of parent dir', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: 'content://com.example.app/file/123', name: 'shared.md');

    await tester.pumpWidget(buildHome(onOpenFile: () {}, recents: repo));
    await tester.pumpAndSettle();

    // The subtitle should contain "从分享接收"
    expect(find.textContaining('从分享接收'), findsOneWidget);
    // It should NOT contain a path segment
    expect(find.textContaining('/'), findsNothing);
  });
}
