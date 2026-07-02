import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:md_preview/utils/markdown_parser.dart';
import 'package:md_preview/widgets/code_block.dart' as cb;
import 'package:md_preview/widgets/webview_block.dart';

/// Height of an inline math WebView — kept small so it sits on the
/// same baseline as the surrounding text.
const double _inlineMathHeight = 36.0;

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

    if (block is ParagraphBlock) {
      final segs = block.resolvedSegments;
      final hasMath = segs.any((s) => s is InlineMath);
      if (!hasMath) {
        // No inline math — delegate to flutter_markdown as before.
        return MarkdownBody(
          data: block.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: fontSize,
                  height: 1.55,
                ),
          ),
        );
      }
      // Render as a Wrap of text spans and small inline-math WebViews.
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final seg in segs)
            if (seg is InlineText)
              Text(seg.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: fontSize,
                        height: 1.55,
                      ),)
            else if (seg is InlineMath)
              _InlineMathView(formula: seg.formula),
        ],
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

/// A small inline WebView that renders a KaTeX math formula.
///
/// Uses [WebViewBlock] (the existing local-HTTP-server-backed viewer)
/// configured for inline use: fixed ~36 px height and KaTeX
/// `displayMode: false` so the formula is typeset in text size.
class _InlineMathView extends StatefulWidget {
  final String formula;
  const _InlineMathView({required this.formula});

  @override
  State<_InlineMathView> createState() => _InlineMathViewState();
}

class _InlineMathViewState extends State<_InlineMathView> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    ViewerServer.instance.start().then((int port) {
      if (!mounted) return;
      _initController(port);
    }).catchError((Object err, StackTrace st) {
      debugPrint('[_InlineMathView] server start failed: $err\n$st');
    });
  }

  Future<void> _initController(int port) async {
    // Pass displayMode=false so KaTeX typesets in text size, not block.
    final fragment =
        'lang=math&code=${Uri.encodeComponent(widget.formula)}&displayMode=false';
    final uri = Uri.parse('http://127.0.0.1:$port/#$fragment');
    debugPrint('[_InlineMathView] navigating to $uri');
    final c = WebViewController();
    await c.setJavaScriptMode(JavaScriptMode.unrestricted);
    await c.loadRequest(uri);
    if (mounted) setState(() => _controller = c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _inlineMathHeight,
      constraints: const BoxConstraints(
        minHeight: _inlineMathHeight,
        maxHeight: _inlineMathHeight,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: _controller == null
          ? const SizedBox(width: _inlineMathHeight, height: _inlineMathHeight)
          : SizedBox(
              width: _inlineMathHeight,
              height: _inlineMathHeight,
              child: WebViewWidget(controller: _controller!),
            ),
    );
  }
}
