import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/screens/preview_screen.dart';

void main() {
  testWidgets('PreviewScreen shows the file name in the AppBar',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PreviewScreen(content: '# Hi', name: 'readme.md'),
    ),);
    expect(find.text('readme.md'), findsOneWidget);
  });

  testWidgets('PreviewScreen renders the markdown body', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PreviewScreen(content: '# Hi', name: 'readme.md'),
    ),);
    expect(find.text('Hi'), findsOneWidget);
  });
}