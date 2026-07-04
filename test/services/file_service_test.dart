import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/services/file_service.dart';

void main() {
  group('FileService', () {
    test('reads a plain path via injected reader', () async {
      final svc = FileService(reader: (p) async => '# hello\n');
      final r = await svc.loadFromUri('/tmp/x.md');
      expect(r, isA<Ok>());
      expect((r as Ok).content, '# hello\n');
    });

    test('reads a file:// URI by stripping the scheme', () async {
      String? seen;
      final svc = FileService(
        reader: (p) async {
          seen = p;
          return 'body';
        },
      );
      await svc.loadFromUri('file:///tmp/x.md');
      expect(seen, '/tmp/x.md');
    });

    test('reads a content:// URI by passing it through to the reader', () async {
      String? seen;
      final svc = FileService(
        reader: (p) async {
          seen = p;
          return 'body';
        },
      );
      await svc.loadFromUri('content://com.example/123');
      expect(seen, 'content://com.example/123');
    });

    test('returns Error when reader throws', () async {
      final svc = FileService(reader: (_) async => throw Exception('boom'));
      final r = await svc.loadFromUri('/missing.md');
      expect(r, isA<Error>());
    });

    // -------------------------------------------------------------------------
    // loadFromPath tests
    // -------------------------------------------------------------------------

    test('loadFromPath with existing plain file returns Ok', () async {
      final dir = Directory.systemTemp.createTempSync('fs_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/test.md')..writeAsStringSync('# Hello');
      final svc = FileService(reader: (p) async => File(p).readAsString());
      final r = await svc.loadFromPath(file.path);
      expect(r, isA<Ok>());
      final ok = r as Ok;
      expect(ok.content, '# Hello');
      expect(ok.name, 'test.md');
    });

    test('loadFromPath with missing plain file returns Missing', () async {
      final svc = FileService(reader: (p) async => File(p).readAsString());
      final r = await svc.loadFromPath('/nonexistent/path/xyz.md');
      expect(r, isA<Missing>());
      expect((r as Missing).path, '/nonexistent/path/xyz.md');
    });

    test('loadFromPath with missing file:// returns Missing', () async {
      final svc = FileService(reader: (p) async => File(p).readAsString());
      final r = await svc.loadFromPath('file:///nonexistent/path/xyz.md');
      expect(r, isA<Missing>());
      expect((r as Missing).path, '/nonexistent/path/xyz.md');
    });

    test('loadFromPath with content:// and reader throwing returns Missing', () async {
      final svc = FileService(reader: (_) async => throw Exception('content unavailable'));
      final r = await svc.loadFromPath('content://com.example.app/file/123');
      expect(r, isA<Missing>());
      expect((r as Missing).path, 'content://com.example.app/file/123');
    });

    test('loadFromPath with reader throwing for existing file returns Error', () async {
      final dir = Directory.systemTemp.createTempSync('fs_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/test.md')..writeAsStringSync('# Hello');
      // Reader throws after the file exists
      final svc = FileService(reader: (_) async => throw Exception('permission denied'));
      final r = await svc.loadFromPath(file.path);
      expect(r, isA<Error>());
      expect((r as Error).reason, contains('permission denied'));
    });
  });
}