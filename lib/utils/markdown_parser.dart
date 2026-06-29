/// Top-level Markdown block types used by [parseMarkdown].
///
/// Kept as a small, hand-rolled hierarchy so the rendering layer
/// (see `widgets/markdown_view.dart`) can route code blocks to the
/// WebView when they are mermaid/math and to `flutter_markdown`
/// otherwise. We intentionally do NOT depend on `flutter_markdown`'s
/// internal AST — the parser here is a simple line-based splitter
/// that is sufficient for routing and trivial to test.
library;

enum CodeBlockKind { plain, mermaid, math }

sealed class ParsedBlock {
  const ParsedBlock();
}

class HeadingBlock extends ParsedBlock {
  final int level;
  final String text;
  const HeadingBlock(this.level, this.text);
}

class ParagraphBlock extends ParsedBlock {
  final String text;
  const ParagraphBlock(this.text);
}

class CodeBlock extends ParsedBlock {
  final String? language;
  final String code;
  final CodeBlockKind kind;
  const CodeBlock({
    required this.language,
    required this.code,
    required this.kind,
  });
}

class ListBlock extends ParsedBlock {
  final bool ordered;
  final List<String> items;
  const ListBlock({required this.ordered, required this.items});
}

class TableBlock extends ParsedBlock {
  final List<String> header;
  final List<List<String>> rows;
  const TableBlock({required this.header, required this.rows});
}

class OtherBlock extends ParsedBlock {
  final String raw;
  const OtherBlock(this.raw);
}

/// Classify a fenced code block by its declared language and (if no
/// language was given) the content's first line.
CodeBlockKind classifyCodeBlock(String? language, String code) {
  final lang = language?.toLowerCase().trim();
  if (lang == 'mermaid') return CodeBlockKind.mermaid;
  if (lang == 'math' || lang == 'latex' || lang == 'tex') {
    return CodeBlockKind.math;
  }
  if (lang == null || lang.isEmpty) {
    final firstLine = code.trimLeft().split('\n').first;
    if (firstLine.startsWith(r'$$') || firstLine.startsWith(r'\[')) {
      return CodeBlockKind.math;
    }
  }
  return CodeBlockKind.plain;
}

/// Split [source] into top-level blocks.
///
/// This is intentionally simple: it walks the source line-by-line,
/// tracking fenced code blocks, GFM tables, headings, and lists. It
/// is good enough to route code blocks to the WebView; the actual
/// inline rendering is delegated to `flutter_markdown`.
List<ParsedBlock> parseMarkdown(String source) {
  if (source.isEmpty) return const [];
  final lines = source.split('\n');
  final blocks = <ParsedBlock>[];
  var i = 0;

  bool isFence(String line) {
    final t = line.trimLeft();
    return t.startsWith('```') || t.startsWith('~~~');
  }

  String? fenceLang(String line) {
    final t = line.trimLeft();
    if (!t.startsWith('```') && !t.startsWith('~~~')) return null;
    final body = t.substring(3).trim();
    if (body.isEmpty) return null;
    final firstToken = body.split(RegExp(r'\s+')).first;
    return firstToken.isEmpty ? null : firstToken;
  }

  while (i < lines.length) {
    final line = lines[i];

    if (isFence(line)) {
      final lang = fenceLang(line);
      final fenceChar = line.trimLeft()[0];
      final buf = <String>[];
      i++;
      while (i < lines.length) {
        final l = lines[i];
        if (l.trimLeft().startsWith('$fenceChar$fenceChar$fenceChar')) {
          i++;
          break;
        }
        buf.add(l);
        i++;
      }
      final code = buf.join('\n');
      blocks.add(CodeBlock(
        language: lang,
        code: code,
        kind: classifyCodeBlock(lang, code),
      ),);
      continue;
    }

    if (line.startsWith('#')) {
      var level = 0;
      while (level < line.length && line[level] == '#') {
        level++;
      }
      if (level <= 6 && level < line.length && line[level] == ' ') {
        blocks.add(HeadingBlock(level, line.substring(level + 1).trim()));
        i++;
        continue;
      }
    }

    if (line.trimLeft().startsWith('|') && i + 1 < lines.length &&
        RegExp(r'^\s*\|?[\s:|-]+\|?[\s:|-]*$').hasMatch(lines[i + 1])) {
      final header = _splitRow(lines[i]);
      i += 2; // skip header + separator
      final rows = <List<String>>[];
      while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
        rows.add(_splitRow(lines[i]));
        i++;
      }
      blocks.add(TableBlock(header: header, rows: rows));
      continue;
    }

    final trimmed = line.trimLeft();
    if (trimmed.startsWith('- ') ||
        trimmed.startsWith('* ') ||
        RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
      final ordered = RegExp(r'^\d+\.\s').hasMatch(trimmed);
      final items = <String>[];
      while (i < lines.length) {
        final t = lines[i].trimLeft();
        final isItem = ordered
            ? RegExp(r'^\d+\.\s').hasMatch(t)
            : (t.startsWith('- ') || t.startsWith('* '));
        if (!isItem) break;
        final markerLen = ordered
            ? t.indexOf(RegExp(r'\d+\.\s')) + RegExp(r'\d+\.\s').firstMatch(t)!.end
            : 2;
        items.add(t.substring(markerLen).trim());
        i++;
      }
      blocks.add(ListBlock(ordered: ordered, items: items));
      continue;
    }

    if (line.trim().isEmpty) {
      i++;
      continue;
    }

    final para = <String>[line];
    i++;
    while (i < lines.length &&
        lines[i].trim().isNotEmpty &&
        !isFence(lines[i]) &&
        !lines[i].startsWith('#') &&
        !lines[i].trimLeft().startsWith('|') &&
        !lines[i].trimLeft().startsWith('- ')) {
      para.add(lines[i]);
      i++;
    }
    blocks.add(ParagraphBlock(para.join('\n')));
  }
  return blocks;
}

List<String> _splitRow(String line) {
  var t = line.trim();
  if (t.startsWith('|')) t = t.substring(1);
  if (t.endsWith('|')) t = t.substring(0, t.length - 1);
  return t.split('|').map((c) => c.trim()).toList();
}