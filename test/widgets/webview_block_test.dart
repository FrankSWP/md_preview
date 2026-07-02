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

    print('viewer.html: ${viewerHtml.length}');
    print('marked.min.js: ${markedJs.length}');
    print('highlight.min.js: ${highlightJs.length}');
    print('mermaid.min.js: ${mermaidJs.length}');
    print('katex.min.js: ${katexJs.length}');

    String inlineLib(String code) => '<script>$code</script>';
    final bundled = viewerHtml
        .replaceFirst('<script src="marked.min.js"></script>', inlineLib(markedJs))
        .replaceFirst('<script src="highlight.min.js"></script>', inlineLib(highlightJs))
        .replaceFirst('<script src="mermaid.min.js"></script>', inlineLib(mermaidJs))
        .replaceFirst('<script src="katex.min.js"></script>', inlineLib(katexJs));

    print('TOTAL BUNDLED HTML: ${bundled.length} bytes = ${bundled.length / 1024 / 1024} MB');
  });
}