import 'package:flutter/material.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/utils/app_localizations.dart';
import 'package:md_preview/widgets/recent_file_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenFile;
  final VoidCallback? onViewAllRecents;
  final RecentFilesRepository? recents;
  final ValueChanged<RecentFile>? onOpenRecent;

  const HomeScreen({
    super.key,
    required this.onOpenFile,
    this.onViewAllRecents,
    this.recents,
    this.onOpenRecent,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeAppbarTitle),
        actions: [
          IconButton(
            tooltip: l.homeSettingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 96,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.homeTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.homeSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: onOpenFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(l.homeOpenButton),
                      ),
                      if (recents != null) ...[
                        const SizedBox(height: 32),
                        _RecentFilesSection(
                          recents: recents!,
                          onOpenFile: onOpenFile,
                          onViewAll: onViewAllRecents,
                          onOpenRecent: onOpenRecent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecentFilesSection extends StatelessWidget {
  final RecentFilesRepository recents;
  final VoidCallback onOpenFile;
  final VoidCallback? onViewAll;
  final ValueChanged<RecentFile>? onOpenRecent;

  const _RecentFilesSection({
    required this.recents,
    required this.onOpenFile,
    this.onViewAll,
    this.onOpenRecent,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StreamBuilder<List<RecentFile>>(
      stream: recents.changes,
      initialData: recents.recent(),
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];
        if (files.isEmpty) return const SizedBox.shrink();

        final displayFiles = files.take(3).toList();
        final hasMore = files.length > 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l.homeRecentSectionHeader,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...displayFiles.map((file) => RecentFileCard(
                  file: file,
                  onTap: onOpenRecent != null
                      ? () => onOpenRecent!(file)
                      : null,
                  onLongPress: () async {
                    final name = file.name;
                    final path = file.path;
                    await recents.remove(path);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.recentRemovedSnackbar),
                          action: SnackBarAction(
                            label: l.recentUndoAction,
                            onPressed: () async {
                              await recents.add(path: path, name: name);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),),

            if (hasMore && onViewAll != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onViewAll,
                  child: Text(l.homeViewAllLink),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
