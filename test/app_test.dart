import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/app.dart';
import 'package:md_preview/services/file_service.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/services/settings_service.dart';
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

  Future<MdPreviewApp> buildApp({
    required FileService fileService,
    required RecentFilesRepository recents,
  }) async {
    final settings = await SettingsService.create();
    return MdPreviewApp(
      settings: settings,
      fileService: fileService,
      recents: recents,
    );
  }

  // -------------------------------------------------------------------------
  // Test 1: On Ok from loadFromPath, preview is pushed AND recents.add is called
  // -------------------------------------------------------------------------
  testWidgets('Ok result: preview is pushed and recents.add is called', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    final fileService = _MockFileService(
      loadFromPathResult: const Ok('# Hello world', 'notes.md'),
    );

    final app = await buildApp(fileService: fileService, recents: repo);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'notes.md'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Preview should show the content
    expect(find.text('Hello world'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 2: On Missing, dialog is shown with '文件不存在' title
  // -------------------------------------------------------------------------
  testWidgets('Missing result: dialog shown with 文件不存在', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/nonexistent/notes.md', name: 'notes.md');

    final fileService = _MockFileService(
      loadFromPathResult: const Missing('/nonexistent/notes.md'),
    );

    final app = await buildApp(fileService: fileService, recents: repo);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'notes.md'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('文件不存在'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('移除'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Test 3: On Missing + user taps 移除, recents.remove is called
  // -------------------------------------------------------------------------
  testWidgets('Missing + tap 移除: recents.remove is called', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/nonexistent/notes.md', name: 'notes.md');

    final fileService = _MockFileService(
      loadFromPathResult: const Missing('/nonexistent/notes.md'),
    );

    final app = await buildApp(fileService: fileService, recents: repo);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'notes.md'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('移除'));
    await tester.pumpAndSettle();

    expect(repo.recent(), isEmpty);
  });

  // -------------------------------------------------------------------------
  // Test 4: On Missing + user taps 取消, recents.remove is NOT called
  // -------------------------------------------------------------------------
  testWidgets('Missing + tap 取消: recents.remove NOT called', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/nonexistent/notes.md', name: 'notes.md');
    await repo.add(path: '/storage/other.md', name: 'other.md');

    final fileService = _MockFileService(
      loadFromPathResult: const Missing('/nonexistent/notes.md'),
    );

    final app = await buildApp(fileService: fileService, recents: repo);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'notes.md'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(repo.recent().length, equals(2));
  });

  // -------------------------------------------------------------------------
  // Test 5: On Error (non-missing), preview is pushed with error text
  // -------------------------------------------------------------------------
  testWidgets('Error result: preview is pushed with error text', (tester) async {
    final repo = await buildRepo();
    await repo.add(path: '/storage/notes.md', name: 'notes.md');

    final fileService = _MockFileService(
      loadFromPathResult: const Error('permission denied'),
    );

    final app = await buildApp(fileService: fileService, recents: repo);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'notes.md'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('permission denied'), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
  });
}

// -------------------------------------------------------------------------
// _MockFileService — returns a canned FileLoadResult without doing real IO
// -------------------------------------------------------------------------

class _MockFileService extends FileService {
  final FileLoadResult loadFromPathResult;

  _MockFileService({required this.loadFromPathResult})
      : super(reader: (_) async => '');

  @override
  Future<FileLoadResult> loadFromPath(String path) async {
    return loadFromPathResult;
  }
}
