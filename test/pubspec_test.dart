import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/pubspec_constants.dart';

void main() {
  test('expected runtime dependencies are declared', () {
    final deps = <String>{
      'file_picker',
      'uri_content',
      'flutter_markdown',
      'path_provider',
      'receive_sharing_intent',
      'shared_preferences',
      'webview_flutter',
    };
    expect(
      deps.every(pubspecDependencies.contains),
      isTrue,
      reason: 'Missing one of: $deps',
    );
  });
}