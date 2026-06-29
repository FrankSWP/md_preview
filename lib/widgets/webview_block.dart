import 'package:flutter/material.dart';

/// Renders a "complex" code block (Mermaid / math) inside a WebView
/// that loads `assets/viewer/viewer.html` with the language + code
/// passed in via the URL fragment.
///
/// During tests and in early development, before the WebView impl
/// lands in Task 13, this is a stub showing a placeholder.
class WebViewBlock extends StatelessWidget {
  final String language;
  final String code;
  const WebViewBlock({super.key, required this.language, required this.code});

  @override
  Widget build(BuildContext context) {
    // Real implementation is added in Task 13.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('[$language block: ${code.length} chars]'),
    );
  }
}
