import 'package:flutter/material.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/widgets/recent_file_card.dart';

/// A screen showing all recent files (up to 50), with options to open or
/// remove individual entries, or clear the entire list.
class FullRecentListScreen extends StatelessWidget {
  final RecentFilesRepository recents;
  final ValueChanged<RecentFile>? onOpenFile;

  const FullRecentListScreen({
    super.key,
    required this.recents,
    this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近文件'),
        actions: [
          IconButton(
            tooltip: '清空',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<RecentFile>>(
        stream: recents.changes,
        initialData: recents.recent(limit: 50),
        builder: (context, snapshot) {
          final files = snapshot.data ?? [];
          if (files.isEmpty) {
            return const _EmptyState();
          }
          return ListView(
            children: files.map((file) => _buildCard(context, file)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, RecentFile file) {
    return RecentFileCard(
      file: file,
      onTap: onOpenFile != null
          ? () {
              onOpenFile!(file);
              Navigator.pop(context);
            }
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
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空最近文件?'),
        content: const Text(
          '将移除所有最近打开的文件,此操作不可撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              recents.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有最近文件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '打开的 Markdown 文件会',
            style: TextStyle(color: Colors.grey),
          ),
          const Text(
            '在这里显示',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
