import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/utils/relative_time.dart';

void main() {
  group('formatRelativeTime (zh)', () {
    test('刚刚 for less than 1 minute', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '刚刚');
    });

    test('刚刚 for 30 seconds ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 59, 30);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '刚刚');
    });

    test('X 分钟前 for less than 1 hour', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 55, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '5 分钟前');
    });

    test('X 分钟前 for 59 minutes ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 1, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '59 分钟前');
    });

    test('X 小时前 for less than 24 hours', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 8, 30, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '3 小时前');
    });

    test('X 小时前 for 23 hours ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 13, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '23 小时前');
    });

    test('昨天 for exactly 1 day ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '昨天');
    });

    test('X 天前 for 2-6 days ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 29, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '4 天前');
    });

    test('X 天前 for 6 days ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 27, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '6 天前');
    });

    test('X 周前 for 1 week ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 26, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '1 周前');
    });

    test('X 周前 for 13-14 days ago rounds to 2 weeks', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      // 13 days ago — should round to 2 weeks, not floor to 1
      final thirteenDaysAgo = DateTime.utc(2026, 6, 20, 12, 0, 0);
      expect(formatRelativeTime(thirteenDaysAgo, now: now, languageCode: 'zh'), '2 周前');
      // 14 days ago — exactly 2 weeks
      final fourteenDaysAgo = DateTime.utc(2026, 6, 19, 12, 0, 0);
      expect(formatRelativeTime(fourteenDaysAgo, now: now, languageCode: 'zh'), '2 周前');
    });

    test('X 周前 for 3 weeks ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 12, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '3 周前');
    });

    test('X 周前 for less than 30 days', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 10, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '3 周前');
    });

    test('YYYY-MM-DD for older than 30 days', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 1, 1, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'zh'), '2026-01-01');
    });
  });

  group('formatRelativeTime (en)', () {
    test('just now for less than 1 minute', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), 'just now');
    });

    test('X min ago for 30 seconds ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 59, 30);
      // 30 seconds is < 1 minute → 'just now' is correct.
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), 'just now');
    });

    test('X min ago for less than 1 hour', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 55, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '5 min ago');
    });

    test('X min ago for 59 minutes ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 1, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '59 min ago');
    });

    test('X h ago for less than 24 hours', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 8, 30, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '3 h ago');
    });

    test('X h ago for 23 hours ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 13, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '23 h ago');
    });

    test('yesterday for exactly 1 day ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), 'yesterday');
    });

    test('X d ago for 2-6 days ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 29, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '4 d ago');
    });

    test('X w ago for 1 week ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 26, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '1 w ago');
    });

    test('X w ago for 13-14 days ago rounds to 2 weeks', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final thirteenDaysAgo = DateTime.utc(2026, 6, 20, 12, 0, 0);
      expect(formatRelativeTime(thirteenDaysAgo, now: now, languageCode: 'en'), '2 w ago');
      final fourteenDaysAgo = DateTime.utc(2026, 6, 19, 12, 0, 0);
      expect(formatRelativeTime(fourteenDaysAgo, now: now, languageCode: 'en'), '2 w ago');
    });

    test('YYYY-MM-DD for older than 30 days', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 1, 1, 12, 0, 0);
      expect(formatRelativeTime(then, now: now, languageCode: 'en'), '2026-01-01');
    });
  });
}
