/// Formats a UTC timestamp as a relative time string.
///
/// [now] is parameterised for testing; defaults to DateTime.now().toUtc().
/// [languageCode] defaults to 'zh' (Chinese buckets); pass 'en' for English buckets.
String formatRelativeTime(
  DateTime utc, {
  DateTime? now,
  String languageCode = 'zh',
}) {
  final current = now ?? DateTime.now().toUtc();
  final diff = current.difference(utc);

  if (diff.inMinutes < 1) {
    return languageCode == 'zh' ? '刚刚' : 'just now';
  }
  if (diff.inHours < 1) {
    final min = diff.inMinutes;
    return languageCode == 'zh' ? '$min 分钟前' : '$min min ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return languageCode == 'zh' ? '$h 小时前' : '$h h ago';
  }
  if (diff.inDays == 1) {
    return languageCode == 'zh' ? '昨天' : 'yesterday';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return languageCode == 'zh' ? '$d 天前' : '$d d ago';
  }
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).round();
    return languageCode == 'zh' ? '$weeks 周前' : '$weeks w ago';
  }

  return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
}
