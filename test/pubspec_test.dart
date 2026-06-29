import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/pubspec_constants.dart';

void main() {
  test('expected runtime dependencies are declared', () {
    final deps = <String>{
      'flutter_markdown',
      'webview_flutter',
      'file_picker',
      'receive_sharing_intent',
      'shared_preferences',
      'path_provider',
    };
    expect(
      deps.every(pubspecDependencies.contains),
      isTrue,
      reason: 'Missing one of: $deps',
    );
  });
}