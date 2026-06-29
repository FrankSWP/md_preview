import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/utils/markdown_parser.dart';

void main() {
  group('classifyCodeBlock', () {
    test('mermaid language → mermaid', () {
      expect(classifyCodeBlock('mermaid', 'graph TD; A-->B'),
          CodeBlockKind.mermaid,);
    });

    test('dollar-dollar content with no language → math', () {
      expect(classifyCodeBlock(null, r'$$E=mc^2$$'), CodeBlockKind.math);
    });

    test('language=tex → math', () {
      expect(classifyCodeBlock('tex', 'E=mc^2'), CodeBlockKind.math);
    });

    test('plain python code → plain', () {
      expect(classifyCodeBlock('python', 'print(1)'), CodeBlockKind.plain);
    });
  });

  group('parseMarkdown', () {
    test('parses a heading', () {
      final blocks = parseMarkdown('# Title');
      expect(blocks.whereType<HeadingBlock>().length, 1);
    });

    test('parses a fenced code block with language', () {
      final blocks = parseMarkdown('```dart\nvoid main(){}\n```');
      final c = blocks.whereType<CodeBlock>().single;
      expect(c.language, 'dart');
      expect(c.code, 'void main(){}');
      expect(c.kind, CodeBlockKind.plain);
    });

    test('parses a GFM table', () {
      const md = '| a | b |\n|---|---|\n| 1 | 2 |';
      final blocks = parseMarkdown(md);
      expect(blocks.whereType<TableBlock>().length, 1);
    });

    test('empty source returns empty list', () {
      expect(parseMarkdown(''), isEmpty);
    });
  });
}