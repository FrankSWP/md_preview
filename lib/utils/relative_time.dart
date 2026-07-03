/// Formats a UTC timestamp as a relative time string in Chinese.
///
/// [now] is parameterised for testing; defaults to DateTime.now().toUtc().
String formatRelativeTime(DateTime utc, {DateTime? now}) {
  final current = now ?? DateTime.now().toUtc();
  final diff = current.difference(utc);

  if (diff.inMinutes < 1) {
    return '刚刚';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes} 分钟前';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} 小时前';
  }
  if (diff.inDays == 1) {
    return '昨天';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} 天前';
  }
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).round();
    return '$weeks 周前';
  }

  return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
}
