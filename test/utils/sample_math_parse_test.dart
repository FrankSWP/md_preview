import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/utils/markdown_parser.dart';

void main() {
  test('parse sample_math.md exactly', () {
    const sample = '''行内公式：\$E = mc^2\$

二次方程：\$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\$

求和：\$\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}\$

积分：\$\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}\$

矩阵：
\$\$
A = \\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}
\$\$

高斯分布：
\$\$
f(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{(x-\\mu)^2}{2\\sigma^2}}
\$\$
''';

    final blocks = parseMarkdown(sample);
    print('--- ${blocks.length} blocks ---');
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final desc = switch (b) {
        HeadingBlock h => 'Heading(h=${h.level}) "${h.text}"',
        ParagraphBlock p => 'Paragraph "${p.text.substring(0, p.text.length.clamp(0, 80))}${p.text.length > 80 ? '...' : ''}"',
        CodeBlock cb => 'CodeBlock(lang=${cb.language}, kind=${cb.kind}, code="${cb.code.substring(0, cb.code.length.clamp(0, 80))}${cb.code.length > 80 ? '...' : ''}")',
        ListBlock lb => 'ListBlock(ordered=${lb.ordered}, items=${lb.items.length})',
        TableBlock tb => 'TableBlock(header=${tb.header.length}, rows=${tb.rows.length})',
        OtherBlock o => 'OtherBlock "${o.raw}"',
      };
      print('[$i] $desc');
    }
  });
}