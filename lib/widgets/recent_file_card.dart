import 'package:flutter/material.dart';
import 'package:md_preview/services/recent_files_repository.dart';
import 'package:md_preview/utils/app_localizations.dart';
import 'package:md_preview/utils/relative_time.dart';

/// A card widget displaying a single recent file entry.
///
/// Used by both [HomeScreen] (showing up to 3) and [FullRecentListScreen]
/// (showing all up to 50).
class RecentFileCard extends StatelessWidget {
  final RecentFile file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RecentFileCard({
    super.key,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final placeholder = l.recentCardSharePlaceholder;
    final subtitle =
        '${file.parentDir ?? placeholder} · ${formatRelativeTime(file.lastOpenedAt, languageCode: l.locale.languageCode)}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.description_outlined),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
