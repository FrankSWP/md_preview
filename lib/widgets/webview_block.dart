import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a "complex" code block (Mermaid / math) inside a WebView
/// that loads `assets/viewer/viewer.html` with the language + code
/// passed in via the URL fragment.
///
/// Strategy: on first build, copy the entire `assets/viewer/` directory
/// into the app's temp directory and load the HTML via [loadHtmlString]
/// with [baseUrl] set to the temp directory. This keeps the relative
/// `<script src="marked.min.js">` tags resolving correctly on both
/// Android and iOS without per-platform tweaks.
class WebViewBlock extends StatefulWidget {
  final String language;
  final String code;
  const WebViewBlock({super.key, required this.language, required this.code});

  @override
  State<WebViewBlock> createState() => _WebViewBlockState();
}

class _WebViewBlockState extends State<WebViewBlock> {
  static Future<_ViewerAssets>? _bootstrap;
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _bootstrap ??= _copyViewerToTemp();
    _bootstrap!.then(_initController);
  }

  Future<void> _initController(_ViewerAssets assets) async {
    final fragment =
        'lang=${Uri.encodeComponent(widget.language)}&code=${Uri.encodeComponent(widget.code)}';
    final uri = Uri.file(assets.indexPath).replace(fragment: fragment);
    final html = await File(assets.indexPath).readAsString();
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html, baseUrl: uri.toString());
    if (mounted) setState(() => _controller = c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _controller == null
            ? const Center(child: CircularProgressIndicator())
            : WebViewWidget(controller: _controller!),
      ),
    );
  }
}

/// Holds the paths to the copied viewer assets.
class _ViewerAssets {
  final String indexPath;
  _ViewerAssets(this.indexPath);
}

/// Copies every file under `assets/viewer/` into a subdirectory of
/// the app's temp directory and returns an object holding the absolute
/// path of `viewer.html`. Idempotent: repeated calls return the same
/// path.
Future<_ViewerAssets> _copyViewerToTemp() async {
  const assetDir = 'assets/viewer';
  final tempRoot = await getTemporaryDirectory();
  final target = Directory('${tempRoot.path}/md_preview_viewer');
  if (!await target.exists()) await target.create(recursive: true);

  // Bundled file names. Keep in sync with the vendored assets.
  const files = [
    'viewer.html',
    'viewer.css',
    'marked.min.js',
    'highlight.min.js',
    'mermaid.min.js',
    'katex.min.js',
    'katex.min.css',
  ];
  for (final name in files) {
    final bytes = await rootBundle.load('$assetDir/$name');
    final out = File('${target.path}/$name');
    await out.writeAsBytes(bytes.buffer.asUint8List());
  }
  return _ViewerAssets('${target.path}/viewer.html');
}