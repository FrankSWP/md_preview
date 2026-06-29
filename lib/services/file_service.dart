/// Reads a Markdown source from a URI.
///
/// The reader function is injected so tests can run on the Dart VM
/// (where `dart:io` File IO on Android `content://` URIs would not
/// work anyway). On a real device, the platform code in
/// `intent_handler.dart` provides a reader that uses
/// `MethodChannel` to ask the Android side to stream the bytes
/// via `ContentResolver`, or to read a regular `file://` via
/// `dart:io`.
library;

sealed class FileLoadResult {
  const FileLoadResult();
}

class Ok extends FileLoadResult {
  final String content;
  final String name;
  const Ok(this.content, [this.name = '']);
}

class Error extends FileLoadResult {
  final String reason;
  const Error(this.reason);
}

typedef FileReader = Future<String> Function(String uri);

class FileService {
  final FileReader reader;
  const FileService({required this.reader});

  Future<FileLoadResult> loadFromUri(String uriString) async {
    try {
      final raw = uriString.startsWith('file://')
          ? uriString.substring('file://'.length)
          : uriString;
      final content = await reader(raw);
      final name = _basename(raw);
      return Ok(content, name);
    } catch (e) {
      return Error('Failed to read $uriString: $e');
    }
  }

  String _basename(String path) {
    final cleaned = path.split('?').first;
    final segs = cleaned.split(RegExp(r'[/\\]'));
    return segs.isEmpty ? '' : segs.last;
  }
}