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

import 'dart:io';

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

class Missing extends FileLoadResult {
  final String path;
  const Missing(this.path);
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

  Future<FileLoadResult> loadFromPath(String path) async {
    // 1. If path is content:// — can't pre-check existence. Try to read; if
    //    reader throws, return Missing(path).
    if (path.startsWith('content://')) {
      try {
        final content = await reader(path);
        final name = _basename(path);
        return Ok(content, name);
      } catch (_) {
        return Missing(path);
      }
    }

    // 2. If path is file:// or plain — strip scheme, check File().exists().
    final stripped = path.startsWith('file://')
        ? path.substring('file://'.length)
        : path;

    // ignore: avoid_slow_async_io — this is intentional existence check
    final exists = await _exists(stripped);
    if (!exists) {
      return Missing(stripped);
    }

    try {
      final content = await reader(stripped);
      final name = _basename(stripped);
      return Ok(content, name);
    } catch (e) {
      return Error('Failed to read $path: $e');
    }
  }

  Future<bool> _exists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  String _basename(String path) {
    final cleaned = path.split('?').first;
    final segs = cleaned.split(RegExp(r'[/\\]'));
    return segs.isEmpty ? '' : segs.last;
  }
}