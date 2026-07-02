import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('measure bundled HTML size', () async {
    const assetDir = 'assets/viewer';
    final viewerHtml = await rootBundle.loadString('$assetDir/viewer.html');
    final markedJs = await rootBundle.loadString('$assetDir/marked.min.js');
    final highlightJs = await rootBundle.loadString('$assetDir/highlight.min.js');
    final mermaidJs = await rootBundle.loadString('$assetDir/mermaid.min.js');
    final katexJs = await rootBundle.loadString('$assetDir/katex.min.js');
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

    print('viewer.html: ${viewerHtml.length}');
    print('marked.min.js: ${markedJs.length}');
    print('highlight.min.js: ${highlightJs.length}');
    print('mermaid.min.js: ${mermaidJs.length}');
    print('katex.min.js: ${katexJs.length}');
    print('katex.min.css: ${katexCss.length}');

    String inlineLib(String code) => '<script>$code</script>';
    final bundled = viewerHtml
        .replaceFirst('<script src="marked.min.js"></script>', inlineLib(markedJs))
        .replaceFirst('<script src="highlight.min.js"></script>', inlineLib(highlightJs))
        .replaceFirst('<script src="mermaid.min.js"></script>', inlineLib(mermaidJs))
        .replaceFirst('<script src="katex.min.js"></script>', inlineLib(katexJs));

    print('TOTAL BUNDLED HTML: ${bundled.length} bytes = ${bundled.length / 1024 / 1024} MB');
  });

  test('katex.min.css is loaded and inlined via __KATEX_CSS__ replacement', () async {
    const assetDir = 'assets/viewer';
    final viewerHtml = await rootBundle.loadString('$assetDir/viewer.html');
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

    // Verify the placeholder exists in the original viewer.html
    expect(viewerHtml.contains('__KATEX_CSS__'), isTrue);

    // Verify the CSS contains a known KaTeX rule (minified name)
    expect(katexCss.contains('.katex-display'), isTrue);

    // After replacement the placeholder should be gone and CSS should be present
    final bundled = viewerHtml.replaceFirst('__KATEX_CSS__', katexCss);
    expect(bundled.contains('__KATEX_CSS__'), isFalse);
    expect(bundled.contains('.katex-display'), isTrue);
  });

  test('all 16 bundled woff2 fonts are encoded as data: URLs', () async {
    const assetDir = 'assets/viewer';
    final viewerHtml = await rootBundle.loadString('$assetDir/viewer.html');
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

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

    String patchedCss = katexCss;
    for (final name in fontNames) {
      final assetKey = '$assetDir/fonts/$name.woff2';
      final bytes = await rootBundle.load(assetKey);
      final dataUrl = 'data:font/woff2;base64,${base64Encode(bytes.buffer.asUint8List())}';
      patchedCss = patchedCss
        .replaceAll('url(fonts/$name.woff2)', dataUrl)
        .replaceAll('url(fonts/$name.woff)', dataUrl)
        .replaceAll('url(fonts/$name.ttf)', dataUrl);
    }

    final bundled = viewerHtml.replaceFirst('__KATEX_CSS__', patchedCss);

    // All 16 data: URLs should be present
    for (final name in fontNames) {
      final dataUrl = 'data:font/woff2;base64,';
      expect(
        bundled.contains(dataUrl),
        isTrue,
        reason: 'data: URL missing for $name',
      );
    }

    // Count remaining url(fonts/) references. The CSS uses 3 formats
    // per font (woff2/woff/ttf = 60 total). We replace all 3 formats
    // for the 16 vendored fonts (48 patched), so only the 4 missing
    // fonts (Size1-4) remain with 3 formats each = 12 url(fonts/) refs.
    final urlFontCount = RegExp(r'url\(fonts/').allMatches(bundled).length;
    expect(urlFontCount, equals(12),
        reason: 'Expected 12 remaining url(fonts/) refs '
            '(4 missing fonts × 3 formats), got $urlFontCount',);
  });

  test('__KATEX_CSS__ placeholder is replaced in final HTML', () async {
    const assetDir = 'assets/viewer';
    final viewerHtml = await rootBundle.loadString('$assetDir/viewer.html');
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

    final bundled = viewerHtml.replaceFirst('__KATEX_CSS__', katexCss);
    expect(bundled.contains('__KATEX_CSS__'), isFalse);
  });

  test('url(fonts/) references are all replaced by data: URLs', () async {
    const assetDir = 'assets/viewer';
    final katexCss = await rootBundle.loadString('$assetDir/katex.min.css');

    final beforeCount = RegExp(r'url\(fonts/').allMatches(katexCss).length;
    expect(beforeCount, greaterThan(0), reason: 'CSS should have url(fonts/) references before patching');

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

    var patchedCss = katexCss;
    for (final name in fontNames) {
      final assetKey = '$assetDir/fonts/$name.woff2';
      final bytes = await rootBundle.load(assetKey);
      final dataUrl = 'data:font/woff2;base64,${base64Encode(bytes.buffer.asUint8List())}';
      patchedCss = patchedCss
          .replaceAll('url(fonts/$name.woff2)', dataUrl)
          .replaceAll('url(fonts/$name.woff)', dataUrl)
          .replaceAll('url(fonts/$name.ttf)', dataUrl);
    }

    final afterCount = RegExp(r'url\(fonts/').allMatches(patchedCss).length;
    // After patching all 3 formats, only the 4 missing fonts (Size1-4)
    // remain with 3 formats each = 12 url(fonts/) refs.
    expect(afterCount, equals(12),
        reason: 'Expected exactly 12 remaining url(fonts/) refs '
            '(4 missing fonts × 3 formats), got $afterCount');
  });
}
