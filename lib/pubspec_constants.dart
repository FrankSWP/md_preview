/// Compile-time-known set of declared pubspec dependencies.
///
/// Listed here so tests can assert the project's declared dependencies
/// without parsing pubspec.yaml at test time.
const pubspecDependencies = <String>{
  'file_picker',
  'uri_content',
  'flutter_markdown',
  'path_provider',
  'receive_sharing_intent',
  'shared_preferences',
  'webview_flutter',
};