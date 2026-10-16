/// Tipe tahapan tidur
enum SleepStage {
  asleep,
  deep,
  light,
  rem,
  awake,
  unknown;

  String get displayName {
    switch (this) {
      case SleepStage.asleep:
        return 'Tidur';
      case SleepStage.deep:
        return 'Tidur Nyenyak (Deep)';
      case SleepStage.light:
        return 'Tidur Ringan (Light)';
      case SleepStage.rem:
        return 'REM';
      case SleepStage.awake:
        return 'Terbangun';
      case SleepStage.unknown:
        return 'Lainnya';
    }
  }
}

/// Item segmen fase tidur
class SleepStageItem {
  final SleepStage stage;
  final DateTime startTime;
  final DateTime endTime;

  const SleepStageItem({
    required this.stage,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}

/// Model sesi tidur
class SleepSession {
  final DateTime startTime;
  final DateTime endTime;
  final List<SleepStageItem> stages;
  final String source;
  final String? deviceId;

  const SleepSession({
    required this.startTime,
    required this.endTime,
    required this.source,
    this.stages = const [],
    this.deviceId,
  });

  /// Total durasi di tempat tidur / sesi tidur (dari waktu mulai hingga selesai)
  Duration get totalSessionDuration => endTime.difference(startTime);

  /// Durasi tidur efektif (mengecualikan fase terjaga/awake jika dicatat)
  Duration get effectiveSleepDuration {
    if (stages.isEmpty) return totalSessionDuration;

    var awakeMinutes = 0;
    for (final st in stages) {
      if (st.stage == SleepStage.awake) {
        awakeMinutes += st.duration.inMinutes;
      }
    }
    final effectiveMin = totalSessionDuration.inMinutes - awakeMinutes;
    return Duration(minutes: effectiveMin > 0 ? effectiveMin : 0);
  }

  @override
  String toString() =>
      'SleepSession(from: $startTime, to: $endTime, total: $totalSessionDuration, source: $source)';
}
