import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatTime should format HH:mm correctly', () {
      final dt = DateTime(2026, 10, 16, 14, 35);
      expect(DateFormatter.formatTime(dt), '14:35');
    });

    test('formatTimeRange should format start and end cleanly', () {
      final start = DateTime(2026, 10, 16, 23, 0);
      final end = DateTime(2026, 10, 17, 6, 30);
      expect(DateFormatter.formatTimeRange(start, end), '23:00 - 06:30');
    });

    test('formatDuration should format hours and minutes', () {
      const d1 = Duration(hours: 7, minutes: 25);
      expect(DateFormatter.formatDuration(d1), '7j 25m');

      const d2 = Duration(hours: 3);
      expect(DateFormatter.formatDuration(d2), '3j');

      const d3 = Duration(minutes: 42);
      expect(DateFormatter.formatDuration(d3), '42m');
    });

    test('formatDate should format dd MMM yyyy', () {
      final dt = DateTime(2026, 10, 16);
      expect(DateFormatter.formatDate(dt), contains('2026'));
      expect(DateFormatter.formatDate(dt), contains('16'));
    });
  });
}
