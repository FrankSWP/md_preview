import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:md_preview/screens/home_screen.dart';
import 'package:md_preview/screens/preview_screen.dart';
import 'package:md_preview/screens/settings_screen.dart';
import 'package:md_preview/services/file_service.dart';
import 'package:md_preview/services/router.dart';
import 'package:md_preview/services/settings_service.dart';
import 'package:md_preview/theme/app_theme.dart';

class MdPreviewApp extends StatelessWidget {
  final SettingsService settings;
  final FileService fileService;
  const MdPreviewApp({
    super.key,
    required this.settings,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeModeListenable,
      builder: (_, mode, __) => MaterialApp(
        title: 'MD Preview',
        navigatorKey: rootNavigatorKey,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: mode,
        initialRoute: '/',
        routes: {
          '/settings': (_) => SettingsScreen(settings: settings),
        },
        onGenerateRoute: (s) {
          if (s.name == '/preview') {
            final args =
                (s.arguments as Map<String, String>? ?? <String, String>{});
            return MaterialPageRoute(
              builder: (_) => PreviewScreen(
                content: args['content'] ?? '',
                name: args['name'] ?? '',
                fontSize: settings.fontSizeListenable.value,
              ),
            );
          }
          return null;
        },
        home: HomeScreen(onOpenFile: _pickAndPreview),
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
    final loaded = await fileService.loadFromUri(path);
    await _pushLoaded(loaded);
  }

  /// Pushes the preview screen for any [FileLoadResult]. Public so
  /// `main.dart`'s intent listener can reuse it.
  Future<void> pushLoaded(FileLoadResult loaded) => _pushLoaded(loaded);

  Future<void> _pushLoaded(FileLoadResult loaded) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    if (loaded is Ok) {
      await nav.pushNamed(
        '/preview',
        arguments: <String, String>{
          'content': loaded.content,
          'name': loaded.name,
        },
      );
    } else if (loaded is Error) {
      await nav.pushNamed(
        '/preview',
        arguments: <String, String>{
          'content': '_Failed to open file._\n\n${loaded.reason}',
          'name': 'Error',
        },
      );
    }
  }
}
