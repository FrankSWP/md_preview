import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

class CodeBlock extends StatelessWidget {
  final String language;
  final String code;
  final double fontSize;
  const CodeBlock({
    super.key,
    required this.language,
    required this.code,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1117)
            : const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: HighlightView(
        code,
        language: language.isEmpty ? 'plaintext' : language,
        theme: isDark ? atomOneDarkTheme : githubTheme,
        padding: const EdgeInsets.all(12),
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize - 2,
          height: 1.4,
        ),
      ),
    );
  }
}
