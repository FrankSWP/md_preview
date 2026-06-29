import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:md_preview/utils/markdown_parser.dart';
import 'package:md_preview/widgets/code_block.dart' as cb;
import 'package:md_preview/widgets/webview_block.dart';

class MarkdownView extends StatelessWidget {
  final String source;
  final double fontSize;
  const MarkdownView({super.key, required this.source, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final blocks = parseMarkdown(source);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final b in blocks) _renderBlock(context, b)],
    );
  }

  Widget _renderBlock(BuildContext context, ParsedBlock block) {
    if (block is CodeBlock) {
      if (block.kind == CodeBlockKind.mermaid ||
          block.kind == CodeBlockKind.math) {
        return WebViewBlock(
          language: block.language ?? block.kind.name,
          code: block.code,
        );
      }
      return cb.CodeBlock(
        language: block.language ?? '',
        code: block.code,
        fontSize: fontSize,
      );
    }
    final md = _toMarkdownSource(block);
    return MarkdownBody(
      data: md,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              height: 1.55,
            ),
        h1: Theme.of(context).textTheme.headlineMedium,
        h2: Theme.of(context).textTheme.headlineSmall,
        h3: Theme.of(context).textTheme.titleLarge,
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize - 2,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  String _toMarkdownSource(ParsedBlock b) {
    if (b is HeadingBlock) return '${'#' * b.level} ${b.text}';
    if (b is ParagraphBlock) return b.text;
    if (b is ListBlock) {
      return b.items
          .map((it) => b.ordered ? '1. $it' : '- $it')
          .join('\n');
    }
    if (b is TableBlock) {
      final head = '| ${b.header.join(' | ')} |';
      final sep = '| ${b.header.map((_) => '---').join(' | ')} |';
      final rows =
          b.rows.map((r) => '| ${r.join(' | ')} |').join('\n');
      return '$head\n$sep\n$rows';
    }
    if (b is OtherBlock) return b.raw;
    return '';
  }
}
