import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/screens/settings_screen.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:md_preview/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildScreen(SettingsService s, {Locale locale = const Locale('zh')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      home: SettingsScreen(settings: s),
    );
  }

  testWidgets('SettingsScreen renders theme and font-size controls',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final s = await SettingsService.create();

    // Tall surface so the language picker is on-screen.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(s));
    await tester.pumpAndSettle();
    // Appearance section + theme labels (segmented button shows each option)
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('主题'), findsOneWidget);
    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('浅色'), findsWidgets);
    expect(find.text('深色'), findsWidgets);
    // Reading section
    expect(find.text('阅读'), findsOneWidget);
    expect(find.text('字号'), findsOneWidget);
    // Language section
    expect(find.text('语言'), findsWidgets); // section header + setting label
    expect(find.text('中文'), findsOneWidget);
    // About section
    expect(find.text('关于'), findsOneWidget);
    expect(find.text('版本'), findsOneWidget);
    expect(find.text('开源许可'), findsOneWidget);
  });

  testWidgets('Tapping language picker and choosing English triggers setLocale',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final s = await SettingsService.create();

    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(s));
    await tester.pumpAndSettle();

    // Open the language popup by tapping the trailing PopupMenuButton.
    await tester.tap(find.byType(PopupMenuButton<Locale>));
    await tester.pumpAndSettle();

    // Select English from the popup.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(s.locale, const Locale('en'));
  });

  testWidgets('Tapping language picker and choosing Chinese triggers setLocale',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final s = await SettingsService.create();
    await s.setLocale(const Locale('en'));

    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(s, locale: const Locale('en')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<Locale>));
    await tester.pumpAndSettle();

    // PopupMenu shows localized labels. With the test pumped in 'en', the
    // items are 'Chinese' and 'English'.
    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();

    expect(s.locale, const Locale('zh'));
  });

  testWidgets('SettingsScreen renders in English locale', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final s = await SettingsService.create();

    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(s, locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Follow system'), findsWidgets);
    expect(find.text('Light'), findsWidgets);
    expect(find.text('Dark'), findsWidgets);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Font size'), findsOneWidget);
    expect(find.text('Language'), findsWidgets);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Open source licenses'), findsOneWidget);
  });
}
