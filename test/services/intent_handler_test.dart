import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/services/intent_handler.dart';

void main() {
  test('normalizeUri strips surrounding whitespace', () {
    expect(IntentHandler.normalizeUri('  file:///a.md  '), 'file:///a.md');
  });

  test('normalizeUri returns null for empty input', () {
    expect(IntentHandler.normalizeUri(''), isNull);
    expect(IntentHandler.normalizeUri(null), isNull);
  });

  test('normalizeUri keeps content:// and file:// untouched', () {
    expect(
      IntentHandler.normalizeUri('content://x/1'),
      'content://x/1',
    );
    expect(
      IntentHandler.normalizeUri('file:///x.md'),
      'file:///x.md',
    );
  });
}