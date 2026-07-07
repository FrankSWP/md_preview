// Regression: tapping the Settings gear icon in v0.3.1 was reported as a
// white screen. Try to reproduce in a widget test and surface the error.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/app.dart';
import 'package:md_preview/services/file_service.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/services/router.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the file_picker platform channel so opening the picker doesn't
  // crash the test.
  setUpAll(() {
    const channel = MethodChannel('mrugnanski/file_picker');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootNavigatorKey.currentState?.popUntil((r) => r.isFirst);
  });

  testWidgets('Tapping Settings gear does NOT white-screen', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await SettingsService.create();
    final recents = RecentFilesRepository(prefs: prefs);
    final fileService = FileService(reader: (_) async => '# hi');

    await tester.pumpWidget(MdPreviewApp(
      settings: settings,
      fileService: fileService,
      recents: recents,
    ),);
    await tester.pumpAndSettle();

    // Sanity: home shows the settings gear tooltip.
    expect(find.byTooltip('设置'), findsOneWidget);

    // Tap the settings gear.
    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    // The Settings page should be visible.
    expect(find.text('设置'), findsWidgets);
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('主题'), findsOneWidget);

    // No exception caught by tester.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tapping 查看全部 does NOT white-screen', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await SettingsService.create();
    final recents = RecentFilesRepository(prefs: prefs);
    final fileService = FileService(reader: (_) async => '# hi');

    // Seed 5 recent files so 查看全部 appears.
    for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
      await recents.add(path: '/storage/$name', name: name);
    }

    // Tall surface so the link is on-screen.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MdPreviewApp(
      settings: settings,
      fileService: fileService,
      recents: recents,
    ),);
    await tester.pumpAndSettle();

    // The link should be there.
    expect(find.text('查看全部 →'), findsOneWidget);

    // Tap it.
    await tester.tap(find.text('查看全部 →'));
    await tester.pumpAndSettle();

    // The full recents page should be visible (AppBar with 清空 tooltip
    // and the recents entries).
    expect(find.byTooltip('清空'), findsOneWidget);
    expect(find.text('a.md'), findsOneWidget);
    expect(find.text('e.md'), findsOneWidget);

    // No exception caught by tester.
    expect(tester.takeException(), isNull);
  });

  // Regression: SegmentedButton (3 segments) used as ListTile.trailing
  // throws a layout assertion on narrow phones (the trailing slot can't
  // fit 3 localized labels like '跟随系统 / 浅色 / 深色'). This test
  // uses a typical narrow phone width to reproduce the white screen.
  testWidgets('Settings renders without layout error on narrow phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = await SettingsService.create();
    final recents = RecentFilesRepository(prefs: prefs);
    final fileService = FileService(reader: (_) async => '# hi');

    // 360 logical px = typical narrow phone width.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MdPreviewApp(
      settings: settings,
      fileService: fileService,
      recents: recents,
    ),);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    // The SegmentedButton should be in the tree, not as a trailing widget.
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('浅色'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Full flow: settings → switch to English → back → view all',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await SettingsService.create();
    final recents = RecentFilesRepository(prefs: prefs);
    final fileService = FileService(reader: (_) async => '# hi');

    for (final name in ['a.md', 'b.md', 'c.md', 'd.md', 'e.md']) {
      await recents.add(path: '/storage/$name', name: name);
    }

    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MdPreviewApp(
      settings: settings,
      fileService: fileService,
      recents: recents,
    ),);
    await tester.pumpAndSettle();

    // 1. Tap Settings.
    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsWidgets);
    expect(tester.takeException(), isNull);

    // 2. Switch language to English via the popup.
    await tester.tap(find.byType(PopupMenuButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(settings.locale, const Locale('en'));
    expect(tester.takeException(), isNull);

    // 3. Go back to home (AppBar back button).
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Settings gear should now have English tooltip.
    expect(find.byTooltip('Settings'), findsOneWidget);

    // 5. Tap Settings again — should work, not white-screen.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Appearance'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 6. Go back to home.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 7. Tap View All in English mode.
    expect(find.text('View all →'), findsOneWidget);
    await tester.tap(find.text('View all →'));
    await tester.pumpAndSettle();
    expect(find.text('Recent files'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

