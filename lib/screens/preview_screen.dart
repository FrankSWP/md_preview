import 'package:flutter/material.dart';
import 'package:md_preview/widgets/markdown_view.dart';

class PreviewScreen extends StatelessWidget {
  final String content;
  final String name;
  const PreviewScreen({
    super.key,
    required this.content,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownView(source: content, fontSize: 16),
      ),
    );
  }
}