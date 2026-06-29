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
  });
}