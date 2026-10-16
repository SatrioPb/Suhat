import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _fallbackDateTime =
      DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  /// Format tanggal & jam: contoh "16 Okt 2026, 11:30"
  static String formatDateTime(DateTime dateTime) {
    try {
      return _dateTimeFormat.format(dateTime);
    } catch (_) {
      return _fallbackDateTime.format(dateTime);
    }
  }

  /// Format jam saja: contoh "11:30"
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Format tanggal saja: contoh "16 Okt 2026"
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Format rentang waktu: contoh "23:00 - 06:30"
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Format durasi: contoh "7j 45m" atau "45m"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '${hours}j ${minutes}m';
    } else if (hours > 0) {
      return '${hours}j';
    } else {
      return '${minutes}m';
    }
  }
}
