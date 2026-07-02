import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a "complex" code block (Mermaid / math) inside a WebView.
///
/// Strategy: a single app-scoped HTTP server on `127.0.0.1` serves the
/// fully-inlined HTML (marked, highlight.js, mermaid, KaTeX) at every
/// path. Each [WebViewBlock] navigates to that server with a
/// `lang=...&code=...` URL fragment that the page parses on load.
///
/// Why a local HTTP server: Chromium WebView refuses to navigate to
/// any URL longer than 2,097,152 characters, and `loadHtmlString`
/// uses the same internal `data:` URL mechanism — so the bundled HTML
/// (with mermaid's 3.3 MB minified library) cannot be passed via
/// `loadHtmlString` / `data:` URL. file:// loading also fails on
/// Android (renderer crash on refusal). Serving the HTML over a
/// short `http://127.0.0.1:port/...` URL sidesteps every length
/// limit. Same content, no special permissions beyond
/// `usesCleartextTraffic="true"` (which is local-only and allowed by
/// the platform for loopback).
class WebViewBlock extends StatefulWidget {
  final String language;
  final String code;
  const WebViewBlock({super.key, required this.language, required this.code});

  @override
  State<WebViewBlock> createState() => _WebViewBlockState();
}

class _WebViewBlockState extends State<WebViewBlock> {
  static const double _minHeight = 120;
  static const double _maxHeight = 720;
  static const double _initialHeight = 240;

  WebViewController? _controller;
  double _contentHeight = _initialHeight;

  @override
  void initState() {
    super.initState();
    _ViewerServer.instance.start().then((port) {
      if (!mounted) return;
      _initController(port);
    }).catchError((Object err, StackTrace st) {
      debugPrint('[WebViewBlock] server start failed: $err\n$st');
    });
  }

  Future<void> _initController(int port) async {
    final fragment =
        'lang=${Uri.encodeComponent(widget.language)}&code=${Uri.encodeComponent(widget.code)}';
    final uri = Uri.parse('http://127.0.0.1:$port/#$fragment');
    debugPrint('[WebViewBlock] navigating to $uri');
    final c = WebViewController();
    await c.setJavaScriptMode(JavaScriptMode.unrestricted);
    await c.addJavaScriptChannel(
      'ContentHeight',
      onMessageReceived: (JavaScriptMessage msg) {
        final h = double.tryParse(msg.message);
        if (h == null) return;
        final clamped = h.clamp(_minHeight, _maxHeight);
        if ((clamped - _contentHeight).abs() < 1) return;
        if (!mounted) return;
        setState(() => _contentHeight = clamped);
      },
    );
    await c.loadRequest(uri);
    if (mounted) setState(() => _controller = c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: _contentHeight,
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

/// App-scoped local HTTP server. Bound to `127.0.0.1` on an ephemeral
/// port; serves the same fully-inlined viewer HTML for every path.
/// Each [WebViewBlock] reads its own data from the URL fragment.
class _ViewerServer {
  _ViewerServer._();
  static final _ViewerServer instance = _ViewerServer._();

  HttpServer? _server;
  String? _bundledHtml;
  int? _port;
  Future<int>? _starting;

  Future<int> start() {
    if (_port != null) return Future.value(_port);
    return _starting ??= _doStart();
  }

  Future<int> _doStart() async {
    debugPrint('[ViewerServer] building bundled HTML...');
    final html = await _buildBundledHtml();
    _bundledHtml = html;
    debugPrint('[ViewerServer] bundled HTML: ${html.length} bytes');
    debugPrint('[ViewerServer] binding to 127.0.0.1:0...');
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    debugPrint('[ViewerServer] listening on http://127.0.0.1:$_port/');
    _server!.listen(_handle);
    return _port!;
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      req.response.headers.contentType = ContentType('text', 'html', charset: 'utf-8');
      req.response.write(_bundledHtml);
    } finally {
      await req.response.close();
    }
  }

  Future<String> _buildBundledHtml() async {
    const assetDir = 'assets/viewer';
    final viewerHtml = await rootBundle.loadString('$assetDir/viewer.html');
    final markedJs = await rootBundle.loadString('$assetDir/marked.min.js');
    final highlightJs = await rootBundle.loadString('$assetDir/highlight.min.js');
    final mermaidJs = await rootBundle.loadString('$assetDir/mermaid.min.js');
    final katexJs = await rootBundle.loadString('$assetDir/katex.min.js');
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

    // Build a map of woff2 filename -> data: URL for every bundled font.
    final fontNames = [
      'KaTeX_AMS-Regular',
      'KaTeX_Caligraphic-Bold',
      'KaTeX_Caligraphic-Regular',
      'KaTeX_Fraktur-Bold',
      'KaTeX_Fraktur-Regular',
      'KaTeX_Main-Bold',
      'KaTeX_Main-BoldItalic',
      'KaTeX_Main-Italic',
      'KaTeX_Main-Regular',
      'KaTeX_Math-BoldItalic',
      'KaTeX_Math-Italic',
      'KaTeX_SansSerif-Bold',
      'KaTeX_SansSerif-Italic',
      'KaTeX_SansSerif-Regular',
      'KaTeX_Script-Regular',
      'KaTeX_Typewriter-Regular',
    ];

    final fontDataMap = <String, String>{};
    for (final name in fontNames) {
      final assetKey = '$assetDir/fonts/$name.woff2';
      try {
        final bytes = await rootBundle.load(assetKey);
        fontDataMap[name] = 'data:font/woff2;base64,${base64Encode(bytes.buffer.asUint8List())}';
      } catch (_) {
        // Font not found in bundle — skip and leave url() untouched.
      }
    }

    // Replace each url(fonts/<name>.woff2) with the corresponding data: URL.
    var patchedCss = katexCss;
    for (final entry in fontDataMap.entries) {
      patchedCss = patchedCss.replaceAll(
        'url(fonts/${entry.key}.woff2)',
        entry.value,
      );
    }

    String inlineLib(String code) => '<script>$code</script>';

    return viewerHtml
        .replaceFirst(
          '<script src="marked.min.js"></script>',
          inlineLib(markedJs),
        )
        .replaceFirst(
          '<script src="highlight.min.js"></script>',
          inlineLib(highlightJs),
        )
        .replaceFirst(
          '<script src="mermaid.min.js"></script>',
          inlineLib(mermaidJs),
        )
        .replaceFirst(
          '<script src="katex.min.js"></script>',
          inlineLib(katexJs),
        )
        .replaceFirst('__KATEX_CSS__', patchedCss);
  }
}