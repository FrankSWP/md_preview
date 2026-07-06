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
