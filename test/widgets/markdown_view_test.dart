import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:md_preview/widgets/markdown_view.dart';

void main() {
  testWidgets('MarkdownView renders a heading', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarkdownView(source: '# Title', fontSize: 16,),
        ),
      ),
    ),);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('MarkdownView renders a fenced code block (plain)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarkdownView(
            source: '```dart\nprint(1);\n```',
            fontSize: 16,
          ),
        ),
      ),
    ),);
    // CodeBlock uses HighlightView (RichText/TextSpan), not plain Text.
    expect(find.byType(HighlightView), findsOneWidget);
  });

  testWidgets('MarkdownView routes mermaid to WebViewBlock', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarkdownView(
            source: '```mermaid\ngraph TD; A-->B\n```',
            fontSize: 16,
          ),
        ),
      ),
    ),);
    // Plain code text must NOT be rendered (WebView takes over).
    expect(find.text('graph TD; A-->B'), findsNothing);
  });
}
