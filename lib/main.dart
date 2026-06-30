import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:md_preview/app.dart';
import 'package:md_preview/services/file_service.dart';
import 'package:md_preview/services/intent_handler.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:uri_content/uri_content.dart';

/// Injected into [FileService]. The path may be:
///   - `file:///...`  -> strip scheme, read via `dart:io`
///   - `/...`         -> read via `dart:io` (e.g. file_picker result)
///   - `content://...` -> delegate to [UriContent] (Android only)
///   - anything else  -> throw, FileService wraps the throw into Error
Future<String> _readFromPath(String path) async {
  if (path.startsWith('content://')) {
    final bytes = await UriContent().from(Uri.parse(path));
    return utf8.decode(bytes);
  }
  final cleaned = path.startsWith('file:') ? path.substring(5) : path;
  return await File(cleaned).readAsString();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _bootstrap();
}

Future<void> _bootstrap() async {
  final settings = await SettingsService.create();
  final fileService = FileService(reader: _readFromPath);
  final app = MdPreviewApp(settings: settings, fileService: fileService);
  runApp(app);

  // Cold-start: the app may have been launched from an "Open with"
  // intent. Wait one frame so the navigator is mounted before pushing.
  final intents = IntentHandler()..start();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    intents.sharedFileUris.listen((uri) async {
      final loaded = await fileService.loadFromUri(uri);
      await app.pushLoaded(loaded);
    });
  });
}
