import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecentFilesRepository', () {
    test('1. add() inserts new entry, recent() returns it', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: '/Download/notes.md', name: 'notes.md');

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.path, '/Download/notes.md');
      expect(recent.first.name, 'notes.md');
    });

    test('2. add() updates existing entry — moves to top, no duplicate', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: '/Download/notes.md', name: 'notes.md');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.add(path: '/Download/other.md', name: 'other.md');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.add(path: '/Download/notes.md', name: 'notes.md');

      final recent = repo.recent();
      expect(recent.length, 2);
      expect(recent.first.path, '/Download/notes.md');
      expect(recent.last.path, '/Download/other.md');
    });

    test('3. add() evicts oldest when over maxEntries', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs, maxEntries: 3);

      await repo.add(path: '/a/1.md', name: '1.md');
      await repo.add(path: '/a/2.md', name: '2.md');
      await repo.add(path: '/a/3.md', name: '3.md');
      await repo.add(path: '/a/4.md', name: '4.md');

      final recent = repo.recent();
      expect(recent.length, 3);
      expect(recent.first.path, '/a/4.md');
      expect(recent.last.path, '/a/2.md');
    });

    test('4. add() with content:// sets isContentUri=true, parentDir=null',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(
          path: 'content://com.example/notes.md',
          name: 'notes.md',
      );

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.isContentUri, true);
      expect(recent.first.parentDir, null);
    });

    test('5. add() with file:// derives parentDir correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: 'file:///Download/notes.md', name: 'notes.md');

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.isContentUri, false);
      expect(recent.first.parentDir, '/Download');
    });

    test('6. add() with plain path derives parentDir correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(
          path: '/storage/emulated/0/Documents/readme.md',
          name: 'readme.md',
      );

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.isContentUri, false);
      expect(recent.first.parentDir, '/storage/emulated/0/Documents');
    });

    test('7. remove() deletes by path', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: '/a/1.md', name: '1.md');
      await repo.add(path: '/a/2.md', name: '2.md');
      await repo.remove('/a/1.md');

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.path, '/a/2.md');
    });

    test('8. remove() no-op on missing path — no throw', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: '/a/1.md', name: '1.md');
      await repo.remove('/a/nonexistent.md');

      expect(repo.recent().length, 1);
    });

    test('9. clear() empties the list', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      await repo.add(path: '/a/1.md', name: '1.md');
      await repo.add(path: '/a/2.md', name: '2.md');
      await repo.clear();

      expect(repo.recent(), isEmpty);
    });

    test('10. changes stream emits on add/remove/clear', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      final emissions = <List<RecentFile>>[];
      repo.changes.listen(emissions.add);

      // Flush microtasks after each operation so stream events propagate.
      Future<void> flush() => Future.delayed(const Duration(seconds: 0));

      await repo.add(path: '/a/1.md', name: '1.md');
      await flush();
      await repo.add(path: '/a/2.md', name: '2.md');
      await flush();
      await repo.remove('/a/1.md');
      await flush();
      await repo.clear();
      await flush();

      expect(emissions.length, 4);
      expect(emissions[0].length, 1);
      expect(emissions[1].length, 2);
      expect(emissions[2].length, 1);
      expect(emissions[3].length, 0);
    });

    test('11. persistence round-trip: write, construct new repo, read back',
        () async {
      final prefs = await SharedPreferences.getInstance();

      {
        final repo = RecentFilesRepository(prefs: prefs);
        await repo.add(path: '/a/1.md', name: '1.md');
        await repo.add(path: '/a/2.md', name: '2.md');
      }

      final repo2 = RecentFilesRepository(prefs: prefs);
      final recent = repo2.recent();
      expect(recent.length, 2);
      expect(recent.first.path, '/a/2.md');
    });

    test('12. defensive load: malformed entry fields skip valid entries', () async {
      // Valid JSON array but some entries have malformed fields (null path,
      // invalid lastOpenedAt). These should be skipped; valid ones still load.
      SharedPreferences.setMockInitialValues({
        'recent_files':
            '[{"path": null, "name": "bad.md", "parentDir": "/", "lastOpenedAt": "invalid", "isContentUri": false}, {"path": "/valid.md", "name": "valid.md", "parentDir": "/", "lastOpenedAt": "2026-07-03T09:00:00.000Z", "isContentUri": false}]',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = RecentFilesRepository(prefs: prefs);

      final recent = repo.recent();
      expect(recent.length, 1);
      expect(recent.first.path, '/valid.md');
    });

    // formatRelativeTime coverage lives in test/utils/relative_time_test.dart
  });
}
