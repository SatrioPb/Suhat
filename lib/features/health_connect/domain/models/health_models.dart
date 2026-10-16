/// Status ketersediaan Health Connect SDK pada perangkat Android
enum HealthConnectAvailability {
  checking,
  available,
  updateRequired,
  notInstalled,
  unsupportedPlatform,
}

/// Status izin akses pembacaan data kesehatan
enum HealthPermissionStatus {
  unknown,
  granted,
  denied,
  partiallyGranted,
}

/// Model data langkah (Steps)
class StepRecord {
  final int count;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const StepRecord({
    required this.count,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });

  Duration get duration => endTime.difference(startTime);

  @override
  String toString() =>
      'StepRecord(count: $count, from: $startTime, to: $endTime, source: $source)';
}

/// Model data detak jantung (Heart Rate)
class HeartRateRecord {
  final int bpm;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const HeartRateRecord({
    required this.bpm,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });

  @override
  String toString() =>
      'HeartRateRecord(bpm: $bpm, timestamp: $timestamp, source: $source)';
}

/// Tahapan tidur (Sleep Stage)
enum SleepStageType {
  asleep,
  deep,
  light,
  rem,
  awake,
  unknown;

  String get label {
    switch (this) {
      case SleepStageType.asleep:
        return 'Tidur';
      case SleepStageType.deep:
        return 'Tidur Nyenyak (Deep)';
      case SleepStageType.light:
        return 'Tidur Ringan (Light)';
      case SleepStageType.rem:
        return 'REM';
      case SleepStageType.awake:
        return 'Terbangun';
      case SleepStageType.unknown:
        return 'Tidak Diketahui';
    }
  }
}

/// Item tahapan tidur spesifik
class SleepStageRecord {
  final SleepStageType stage;
  final DateTime startTime;
  final DateTime endTime;

  const SleepStageRecord({
    required this.stage,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}

/// Model rekaman tidur (Sleep Session)
class SleepRecord {
  final DateTime startTime;
  final DateTime endTime;
  final List<SleepStageRecord> stages;
  final String source;
  final String? deviceId;

  const SleepRecord({
    required this.startTime,
    required this.endTime,
    required this.source,
    this.stages = const [],
    this.deviceId,
  });

  Duration get totalDuration => endTime.difference(startTime);

  @override
  String toString() =>
      'SleepRecord(start: $startTime, end: $endTime, stages: ${stages.length}, source: $source)';
}

/// Ringkasan keseluruhan data kesehatan yang divalidasi dari Health Connect
class HealthDataSummary {
  final int totalStepsToday;
  final List<StepRecord> stepRecords;
  final HeartRateRecord? latestHeartRate;
  final List<HeartRateRecord> heartRateHistory;
  final SleepRecord? latestSleep;
  final List<SleepRecord> sleepHistory;
  final DateTime lastFetched;

  const HealthDataSummary({
    required this.totalStepsToday,
    required this.stepRecords,
    this.latestHeartRate,
    this.heartRateHistory = const [],
    this.latestSleep,
    this.sleepHistory = const [],
    required this.lastFetched,
  });

  factory HealthDataSummary.empty() => HealthDataSummary(
        totalStepsToday: 0,
        stepRecords: const [],
        heartRateHistory: const [],
        sleepHistory: const [],
        lastFetched: DateTime.now(),
      );

  HealthDataSummary copyWith({
    int? totalStepsToday,
    List<StepRecord>? stepRecords,
    HeartRateRecord? latestHeartRate,
    List<HeartRateRecord>? heartRateHistory,
    SleepRecord? latestSleep,
    List<SleepRecord>? sleepHistory,
    DateTime? lastFetched,
  }) {
    return HealthDataSummary(
      totalStepsToday: totalStepsToday ?? this.totalStepsToday,
      stepRecords: stepRecords ?? this.stepRecords,
      latestHeartRate: latestHeartRate ?? this.latestHeartRate,
      heartRateHistory: heartRateHistory ?? this.heartRateHistory,
      latestSleep: latestSleep ?? this.latestSleep,
      sleepHistory: sleepHistory ?? this.sleepHistory,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}
