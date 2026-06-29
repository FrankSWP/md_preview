import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows an Open file button', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(onOpenFile: () => opened = true),
    ),);
    expect(find.text('Open Markdown file'), findsOneWidget);
    await tester.tap(find.text('Open Markdown file'));
    expect(opened, isTrue);
  });

  testWidgets('HomeScreen shows a Settings button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(onOpenFile: () {}),
      routes: {
        '/settings': (_) => const Scaffold(body: Text('settings-stub')),
      },
    ),);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });
}