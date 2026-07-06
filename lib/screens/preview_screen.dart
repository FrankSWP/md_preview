import 'package:flutter/material.dart';
import 'package:md_preview/widgets/markdown_view.dart';
import 'package:md_preview/utils/app_localizations.dart';

class PreviewScreen extends StatelessWidget {
  final String content;
  final String name;
  final double fontSize;
  const PreviewScreen({
    super.key,
    required this.content,
    required this.name,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = name == 'Error' ? l.previewErrorTitle : (name.isEmpty ? l.previewAppbarTitle : name);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownView(source: content, fontSize: fontSize),
      ),
    );
  }
}
