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

  group('parseInlineSegments', () {
    test(r'splits paragraph with inline $...$ into text + math', () {
      final segs = parseInlineSegments(r'行内公式：$E = mc^2$');
      expect(segs.length, 2);
      expect(segs[0], const InlineText('行内公式：'));
      expect(segs[1], const InlineMath('E = mc^2'));
    });

    test('does not treat \$5.99 as math (currency heuristic)', () {
      final segs = parseInlineSegments(r'Price: $5.99');
      expect(segs.length, 1);
      expect(segs[0], const InlineText(r'Price: $5.99'));
    });

    test('treats an unclosed \$ as literal text', () {
      final segs = parseInlineSegments(r'未闭合：$x');
      expect(segs.length, 1);
      expect(segs[0], const InlineText(r'未闭合：$x'));
    });

    test('multiple formulas in one paragraph', () {
      final segs = parseInlineSegments(r'$a$ and $b$');
      // Segments are: InlineMath("a"), InlineText(" and "), InlineMath("b")
      // (consecutive text segments are merged).
      expect(segs.length, 3);
      expect(segs[0], const InlineMath('a'));
      expect(segs[1], const InlineText(' and '));
      expect(segs[2], const InlineMath('b'));
    });

    test('formula with no surrounding text', () {
      final segs = parseInlineSegments(r'$x^2$');
      expect(segs.length, 1);
      expect(segs[0], const InlineMath('x^2'));
    });

    test('whitespace around formula is trimmed from formula', () {
      final segs = parseInlineSegments(r'[$  E = mc^2  $]');
      expect(segs.length, 3);
      expect(segs[0], const InlineText('['));
      expect(segs[1], const InlineMath('E = mc^2'));
      expect(segs[2], const InlineText(']'));
    });
  });

  group('parseMarkdown — inline math', () {
    test(r'inline $...$ becomes ParagraphBlock with math segments', () {
      final blocks = parseMarkdown(r'行内公式：$E = mc^2$');
      final ps = blocks.whereType<ParagraphBlock>().toList();
      expect(ps.length, 1);
      final segs = ps[0].resolvedSegments;
      expect(segs.whereType<InlineMath>().length, 1);
      expect(segs.whereType<InlineText>().length, 1);
    });

    test('\$\$ block math becomes CodeBlock, not inline', () {
      final blocks = parseMarkdown(r'$$E=mc^2$$');
      expect(blocks.whereType<CodeBlock>().length, 1);
      expect(blocks.whereType<ParagraphBlock>(), isEmpty);
    });

    test(r'plain paragraph without $ has no InlineMath segments', () {
      final blocks = parseMarkdown('Hello world');
      final ps = blocks.whereType<ParagraphBlock>().toList();
      expect(ps.length, 1);
      expect(ps[0].resolvedSegments.whereType<InlineMath>(), isEmpty);
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