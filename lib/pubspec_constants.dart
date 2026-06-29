/// Compile-time-known set of declared pubspec dependencies.
///
/// Listed here so tests can assert the project's declared dependencies
/// without parsing pubspec.yaml at test time.
const pubspecDependencies = <String>{
  'flutter_markdown',
  'webview_flutter',
  'file_picker',
  'receive_sharing_intent',
  'shared_preferences',
  'path_provider',
};