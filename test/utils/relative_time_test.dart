import 'package:flutter_test/flutter_test.dart';
import 'package:md_preview/utils/relative_time.dart';

void main() {
  group('formatRelativeTime', () {
    test('刚刚 for less than 1 minute', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '刚刚');
    });

    test('刚刚 for 30 seconds ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 59, 30);
      expect(formatRelativeTime(then, now: now), '刚刚');
    });

    test('X 分钟前 for less than 1 hour', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 55, 0);
      expect(formatRelativeTime(then, now: now), '5 分钟前');
    });

    test('X 分钟前 for 59 minutes ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 11, 1, 0);
      expect(formatRelativeTime(then, now: now), '59 分钟前');
    });

    test('X 小时前 for less than 24 hours', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 3, 8, 30, 0);
      expect(formatRelativeTime(then, now: now), '3 小时前');
    });

    test('X 小时前 for 23 hours ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 13, 0, 0);
      expect(formatRelativeTime(then, now: now), '23 小时前');
    });

    test('昨天 for exactly 1 day ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 7, 2, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '昨天');
    });

    test('X 天前 for 2-6 days ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 29, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '4 天前');
    });

    test('X 天前 for 6 days ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 27, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '6 天前');
    });

    test('X 周前 for 1 week ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 26, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '1 周前');
    });

    test('X 周前 for 3 weeks ago', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 12, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '3 周前');
    });

    test('X 周前 for less than 30 days', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 6, 10, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '3 周前');
    });

    test('YYYY-MM-DD for older than 30 days', () {
      final now = DateTime.utc(2026, 7, 3, 12, 0, 0);
      final then = DateTime.utc(2026, 1, 1, 12, 0, 0);
      expect(formatRelativeTime(then, now: now), '2026-01-01');
    });
  });
}
