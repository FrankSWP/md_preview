import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// RecentFile
// ---------------------------------------------------------------------------

class RecentFile {
  final String path;
  final String name;
  final String? parentDir;
  final DateTime lastOpenedAt;
  final bool isContentUri;

  const RecentFile({
    required this.path,
    required this.name,
    this.parentDir,
    required this.lastOpenedAt,
    required this.isContentUri,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'parentDir': parentDir,
        'lastOpenedAt': lastOpenedAt.toUtc().toIso8601String(),
        'isContentUri': isContentUri,
      };

  static RecentFile? fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String?;
    if (path == null || path.isEmpty) return null;
    final lastOpenedAt =
        DateTime.tryParse(json['lastOpenedAt'] as String? ?? '');
    if (lastOpenedAt == null) return null;

    return RecentFile(
      path: path,
      name: json['name'] as String? ?? '',
      parentDir: json['parentDir'] as String?,
      lastOpenedAt: lastOpenedAt,
      isContentUri: json['isContentUri'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          name == other.name &&
          parentDir == other.parentDir &&
          lastOpenedAt == other.lastOpenedAt &&
          isContentUri == other.isContentUri;

  @override
  int get hashCode =>
      path.hashCode ^
      name.hashCode ^
      parentDir.hashCode ^
      lastOpenedAt.hashCode ^
      isContentUri.hashCode;
}

// ---------------------------------------------------------------------------
// RecentFilesRepository
// ---------------------------------------------------------------------------

class RecentFilesRepository {
  static const _key = 'recent_files';

  final SharedPreferences? _prefs;
  final int _maxEntries;

  final StreamController<List<RecentFile>> _changeController =
      StreamController<List<RecentFile>>.broadcast();

  List<RecentFile> _entries = [];

  RecentFilesRepository({SharedPreferences? prefs, int maxEntries = 50})
      : _prefs = prefs,
        _maxEntries = maxEntries {
    _load();
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  Stream<List<RecentFile>> get changes => _changeController.stream;

  Future<void> add({required String path, required String name}) async {
    final isContentUri = path.startsWith('content://');
    String? parentDir;

    if (isContentUri) {
      parentDir = null;
    } else if (path.startsWith('file://')) {
      final stripped = path.substring('file://'.length);
      final segments = stripped.split(RegExp(r'[/\\]'));
      parentDir = segments.length > 1
          ? segments.take(segments.length - 1).join('/')
          : null;
    } else {
      final segments = path.split(RegExp(r'[/\\]'));
      parentDir = segments.length > 1
          ? segments.take(segments.length - 1).join('/')
          : null;
    }

    final now = DateTime.now().toUtc();
    final without = _entries.where((e) => e.path != path).toList();

    final updated = RecentFile(
      path: path,
      name: name,
      parentDir: parentDir,
      lastOpenedAt: now,
      isContentUri: isContentUri,
    );

    _entries = [updated, ...without];
    if (_entries.length > _maxEntries) {
      _entries = _entries.take(_maxEntries).toList();
    }

    await _persist();
    _changeController.add(List.unmodifiable(_entries));
  }

  List<RecentFile> recent({int limit = 5}) {
    return List.unmodifiable(_entries.take(limit));
  }

  Future<void> remove(String path) async {
    final before = _entries.length;
    _entries = _entries.where((e) => e.path != path).toList();
    if (_entries.length != before) {
      await _persist();
      _changeController.add(List.unmodifiable(_entries));
    }
  }

  Future<void> clear() async {
    if (_entries.isEmpty) return;
    _entries = [];
    await _persist();
    _changeController.add(List.unmodifiable(_entries));
  }

  // -------------------------------------------------------------------------
  // Persistence
  // -------------------------------------------------------------------------

  void _load() {
    if (_prefs == null) return;
    final raw = _prefs.getString(_key);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final loaded = <RecentFile>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final entry = RecentFile.fromJson(item);
          if (entry != null) loaded.add(entry);
        }
      }
      _entries = loaded;
      _entries.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    } catch (_) {
      _entries = [];
    }
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    final list = _entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(list));
  }
}
