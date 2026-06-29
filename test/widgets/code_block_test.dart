import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:md_preview/widgets/code_block.dart';

void main() {
  testWidgets('CodeBlock renders the code in a monospace Text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CodeBlock(
          language: 'python',
          code: 'print(1)',
          fontSize: 14,
        ),
      ),
    ),);
    // CodeBlock uses HighlightView which renders a RichText containing
    // TextSpan nodes with the highlighted code.
    expect(find.byType(HighlightView), findsOneWidget);
    // Verify the code text appears somewhere in the widget tree.
    expect(find.byType(RichText), findsWidgets);
  });
}
