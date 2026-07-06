import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:md_preview/screens/preview_screen.dart';
import 'package:md_preview/utils/app_localizations.dart';

void main() {
  Widget buildScreen({required String name, Locale locale = const Locale('zh')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      home: PreviewScreen(content: '# Hi', name: name, fontSize: 16),
    );
  }

  group('PreviewScreen', () {
    testWidgets('shows the file name in the AppBar (zh)', (tester) async {
      await tester.pumpWidget(buildScreen(name: 'readme.md'));
      await tester.pumpAndSettle();
      expect(find.text('readme.md'), findsOneWidget);
    });

    testWidgets('shows the file name in the AppBar (en)', (tester) async {
      await tester.pumpWidget(buildScreen(name: 'readme.md', locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('readme.md'), findsOneWidget);
    });

    testWidgets('renders the markdown body', (tester) async {
      await tester.pumpWidget(buildScreen(name: 'readme.md'));
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsOneWidget);
    });

    testWidgets('shows previewAppbarTitle when name is empty (zh)', (tester) async {
      await tester.pumpWidget(buildScreen(name: ''));
      await tester.pumpAndSettle();
      expect(find.text('预览'), findsOneWidget);
    });

    testWidgets('shows previewAppbarTitle when name is empty (en)', (tester) async {
      await tester.pumpWidget(buildScreen(name: '', locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('shows previewErrorTitle when name is Error (zh)', (tester) async {
      await tester.pumpWidget(buildScreen(name: 'Error'));
      await tester.pumpAndSettle();
      expect(find.text('打开文件出错'), findsOneWidget);
    });

    testWidgets('shows previewErrorTitle when name is Error (en)', (tester) async {
      await tester.pumpWidget(buildScreen(name: 'Error', locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('Failed to open file'), findsOneWidget);
    });
  });
}
