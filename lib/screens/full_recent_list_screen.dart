import 'package:flutter/material.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/utils/app_localizations.dart';
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recentsAppbarTitle),
        actions: [
          IconButton(
            tooltip: l.recentsClearTooltip,
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
    final l = AppLocalizations.of(context);
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
    );
  }

  void _showClearDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.recentsClearDialogTitle),
        content: Text(l.recentsClearDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.recentsClearDialogCancel),
          ),
          TextButton(
            onPressed: () {
              recents.clear();
              Navigator.pop(dialogContext);
            },
            child: Text(l.recentsClearDialogConfirm),
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
    final l = AppLocalizations.of(context);
    // Split the subtitle across two Text widgets to preserve visual layout.
    final parts = l.recentsEmptySubtitle.split('会');
    final part1 = parts.isNotEmpty ? '${parts[0]}会' : l.recentsEmptySubtitle;
    final part2 = parts.length > 1 ? parts[1] : '';

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
          Text(
            l.recentsEmptyTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            part1,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            part2,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
