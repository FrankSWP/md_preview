import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:md_preview/screens/full_recent_list_screen.dart';
import 'package:md_preview/screens/home_screen.dart';
import 'package:md_preview/screens/preview_screen.dart';
import 'package:md_preview/screens/settings_screen.dart';
import 'package:md_preview/services/file_service.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/services/router.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:md_preview/theme/app_theme.dart';

class MdPreviewApp extends StatefulWidget {
  final SettingsService settings;
  final FileService fileService;
  final RecentFilesRepository recents;

  const MdPreviewApp({
    super.key,
    required this.settings,
    required this.fileService,
    required this.recents,
  });

  @override
  State<MdPreviewApp> createState() => _MdPreviewAppState();

  /// Pushes the preview screen for any [FileLoadResult]. Public so
  /// `main.dart`'s intent listener can reuse it. Uses rootNavigatorKey directly.
  static Future<void> pushLoaded(FileLoadResult loaded) async {
    if (loaded is Ok) {
      await _pushPreviewStatic(loaded.content, loaded.name);
    } else if (loaded is Error) {
      await _pushPreviewStatic(
        '_Failed to open file._\n\n${loaded.reason}',
        'Error',
      );
    }
  }

  static Future<void> _pushPreviewStatic(String content, String name) async {
    final nav = Navigator.of(rootNavigatorKey.currentContext!);
    await nav.pushNamed(
      '/preview',
      arguments: <String, String>{'content': content, 'name': name},
    );
  }
}

class _MdPreviewAppState extends State<MdPreviewApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.settings.themeModeListenable,
      builder: (_, mode, __) => MaterialApp(
        title: 'MD Preview',
        navigatorKey: rootNavigatorKey,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: mode,
        initialRoute: '/',
        routes: {
          '/settings': (_) => SettingsScreen(settings: widget.settings),
          '/recents': (_) => FullRecentListScreen(
                recents: widget.recents,
                onOpenFile: (file) => _onOpenRecent(file),
              ),
        },
        onGenerateRoute: (s) {
          if (s.name == '/preview') {
            final args =
                (s.arguments as Map<String, String>? ?? <String, String>{});
            return MaterialPageRoute(
              builder: (_) => PreviewScreen(
                content: args['content'] ?? '',
                name: args['name'] ?? '',
                fontSize: widget.settings.fontSizeListenable.value,
              ),
            );
          }
          return null;
        },
        home: HomeScreen(
          onOpenFile: _pickAndPreview,
          recents: widget.recents,
          onOpenRecent: _onOpenRecent,
          onViewAllRecents: () => Navigator.pushNamed(context, '/recents'),
        ),
      ),
    );
  }

  Future<void> _pickAndPreview() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['md', 'markdown'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    final loaded = await widget.fileService.loadFromUri(path);
    if (!mounted) return;
    await _pushLoaded(loaded);
  }

  /// Called when a recent file card is tapped (HomeScreen or FullRecentListScreen).
  /// Loads the file directly; if missing, shows a dialog offering to remove it.
  Future<void> _onOpenRecent(RecentFile file) async {
    final result = await widget.fileService.loadFromPath(file.path);
    if (!mounted) return;

    switch (result) {
      case Ok(:final content, :final name):
        await widget.recents.add(path: file.path, name: name);
        await _pushPreview(content, name);
      case Missing():
        final removed = await _showMissingFileDialog(file.path);
        if (removed == true) {
          await widget.recents.remove(file.path);
        }
      case Error(:final reason):
        await _pushPreview('_Failed to open file._\n\n$reason', 'Error');
    }
  }

  /// Returns true if the user chose to remove, false/null otherwise.
  Future<bool?> _showMissingFileDialog(String path) {
    return showDialog<bool>(
      context: rootNavigatorKey.currentContext!,
      builder: (ctx) => AlertDialog(
        title: const Text('文件不存在'),
        content: Text('文件可能已被移动或删除:\n$path'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  /// Pushes the preview screen for any [FileLoadResult]. Public so
  /// `main.dart`'s intent listener can reuse it.
  Future<void> pushLoaded(FileLoadResult loaded) => _pushLoaded(loaded);

  Future<void> _pushLoaded(FileLoadResult loaded) async {
    if (loaded is Ok) {
      await _pushPreview(loaded.content, loaded.name);
    } else if (loaded is Error) {
      await _pushPreview('_Failed to open file._\n\n${loaded.reason}', 'Error');
    }
  }

  Future<void> _pushPreview(String content, String name) async {
    final nav = Navigator.of(rootNavigatorKey.currentContext!);
    await nav.pushNamed(
      '/preview',
      arguments: <String, String>{
        'content': content,
        'name': name,
      },
    );
  }
}
