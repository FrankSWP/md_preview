import 'package:flutter/material.dart';
import 'package:md_preview/services/recent_files_repository.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown 预览'),
        actions: [
          IconButton(
            tooltip: '设置',
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
                        'Markdown 预览',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '从文件管理器打开 .md 文件,或点击下方按钮',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: onOpenFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('打开 Markdown 文件'),
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
            const Text(
              '最近文件',
              style: TextStyle(
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
                          content: const Text('已从最近文件中移除'),
                          action: SnackBarAction(
                            label: '撤销',
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
                  child: const Text('查看全部 →'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

