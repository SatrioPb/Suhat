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

/// Model rekaman kalori aktif terbakar (Active Energy Burned)
class ActiveCaloriesRecord {
  final double kcal;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const ActiveCaloriesRecord({
    required this.kcal,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman total kalori terbakar (Total Calories Burned)
class TotalCaloriesRecord {
  final double kcal;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const TotalCaloriesRecord({
    required this.kcal,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman jarak tempuh (Distance)
class DistanceRecord {
  final double distanceMeters;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const DistanceRecord({
    required this.distanceMeters,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });

  double get distanceKm => distanceMeters / 1000.0;
}

/// Model rekaman elevasi / lantai dinaiki (Elevation / Floors Climbed)
class ElevationRecord {
  final double floorsClimbed;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const ElevationRecord({
    required this.floorsClimbed,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman sesi olahraga / latihan (Exercise Session / Workout)
class ExerciseRecord {
  final String activityName;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final double? caloriesBurned;
  final double? distanceMeters;
  final String source;
  final String? deviceId;

  const ExerciseRecord({
    required this.activityName,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.caloriesBurned,
    this.distanceMeters,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman Variabilitas Detak Jantung (Heart Rate Variability - RMSSD)
class HrvRecord {
  final double rmssdMillis;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const HrvRecord({
    required this.rmssdMillis,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman tinggi badan (Height)
class HeightRecord {
  final double heightMeters;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const HeightRecord({
    required this.heightMeters,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });

  double get heightCentimeters => heightMeters * 100.0;
}

/// Model rekaman saturasi oksigen darah (Oxygen Saturation / SpO2)
class OxygenSaturationRecord {
  final double percentage;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const OxygenSaturationRecord({
    required this.percentage,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman detak jantung saat istirahat (Resting Heart Rate - RHR)
class RestingHeartRateRecord {
  final int bpm;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const RestingHeartRateRecord({
    required this.bpm,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });
}

/// Model rekaman berat badan (Weight)
class WeightRecord {
  final double weightKg;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const WeightRecord({
    required this.weightKg,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });
}

/// Ringkasan keseluruhan data kesehatan yang divalidasi dari Health Connect
class HealthDataSummary {
  final int totalStepsToday;
  final List<StepRecord> stepRecords;
  final HeartRateRecord? latestHeartRate;
  final List<HeartRateRecord> heartRateHistory;
  final SleepRecord? latestSleep;
  final List<SleepRecord> sleepHistory;

  // New Metrics
  final double totalActiveCaloriesToday;
  final List<ActiveCaloriesRecord> activeCaloriesRecords;
  final double totalCaloriesBurnedToday;
  final List<TotalCaloriesRecord> totalCaloriesRecords;
  final double totalDistanceToday; // in meters
  final List<DistanceRecord> distanceRecords;
  final double totalFloorsClimbedToday;
  final List<ElevationRecord> elevationRecords;
  final List<ExerciseRecord> exerciseRecords;
  final HrvRecord? latestHrv;
  final List<HrvRecord> hrvHistory;
  final HeightRecord? latestHeight;
  final OxygenSaturationRecord? latestOxygenSaturation;
  final List<OxygenSaturationRecord> oxygenSaturationHistory;
  final RestingHeartRateRecord? latestRestingHeartRate;
  final List<RestingHeartRateRecord> restingHeartRateHistory;
  final WeightRecord? latestWeight;
  final List<WeightRecord> weightHistory;

  final DateTime lastFetched;

  const HealthDataSummary({
    required this.totalStepsToday,
    required this.stepRecords,
    this.latestHeartRate,
    this.heartRateHistory = const [],
    this.latestSleep,
    this.sleepHistory = const [],
    this.totalActiveCaloriesToday = 0.0,
    this.activeCaloriesRecords = const [],
    this.totalCaloriesBurnedToday = 0.0,
    this.totalCaloriesRecords = const [],
    this.totalDistanceToday = 0.0,
    this.distanceRecords = const [],
    this.totalFloorsClimbedToday = 0.0,
    this.elevationRecords = const [],
    this.exerciseRecords = const [],
    this.latestHrv,
    this.hrvHistory = const [],
    this.latestHeight,
    this.latestOxygenSaturation,
    this.oxygenSaturationHistory = const [],
    this.latestRestingHeartRate,
    this.restingHeartRateHistory = const [],
    this.latestWeight,
    this.weightHistory = const [],
    required this.lastFetched,
  });

  double get distanceKmToday => totalDistanceToday / 1000.0;

  double? get bmi {
    if (latestWeight != null && latestHeight != null && latestHeight!.heightMeters > 0) {
      return latestWeight!.weightKg / (latestHeight!.heightMeters * latestHeight!.heightMeters);
    }
    return null;
  }

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
    double? totalActiveCaloriesToday,
    List<ActiveCaloriesRecord>? activeCaloriesRecords,
    double? totalCaloriesBurnedToday,
    List<TotalCaloriesRecord>? totalCaloriesRecords,
    double? totalDistanceToday,
    List<DistanceRecord>? distanceRecords,
    double? totalFloorsClimbedToday,
    List<ElevationRecord>? elevationRecords,
    List<ExerciseRecord>? exerciseRecords,
    HrvRecord? latestHrv,
    List<HrvRecord>? hrvHistory,
    HeightRecord? latestHeight,
    OxygenSaturationRecord? latestOxygenSaturation,
    List<OxygenSaturationRecord>? oxygenSaturationHistory,
    RestingHeartRateRecord? latestRestingHeartRate,
    List<RestingHeartRateRecord>? restingHeartRateHistory,
    WeightRecord? latestWeight,
    List<WeightRecord>? weightHistory,
    DateTime? lastFetched,
  }) {
    return HealthDataSummary(
      totalStepsToday: totalStepsToday ?? this.totalStepsToday,
      stepRecords: stepRecords ?? this.stepRecords,
      latestHeartRate: latestHeartRate ?? this.latestHeartRate,
      heartRateHistory: heartRateHistory ?? this.heartRateHistory,
      latestSleep: latestSleep ?? this.latestSleep,
      sleepHistory: sleepHistory ?? this.sleepHistory,
      totalActiveCaloriesToday:
          totalActiveCaloriesToday ?? this.totalActiveCaloriesToday,
      activeCaloriesRecords:
          activeCaloriesRecords ?? this.activeCaloriesRecords,
      totalCaloriesBurnedToday:
          totalCaloriesBurnedToday ?? this.totalCaloriesBurnedToday,
      totalCaloriesRecords:
          totalCaloriesRecords ?? this.totalCaloriesRecords,
      totalDistanceToday: totalDistanceToday ?? this.totalDistanceToday,
      distanceRecords: distanceRecords ?? this.distanceRecords,
      totalFloorsClimbedToday:
          totalFloorsClimbedToday ?? this.totalFloorsClimbedToday,
      elevationRecords: elevationRecords ?? this.elevationRecords,
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
      latestHrv: latestHrv ?? this.latestHrv,
      hrvHistory: hrvHistory ?? this.hrvHistory,
      latestHeight: latestHeight ?? this.latestHeight,
      latestOxygenSaturation:
          latestOxygenSaturation ?? this.latestOxygenSaturation,
      oxygenSaturationHistory:
          oxygenSaturationHistory ?? this.oxygenSaturationHistory,
      latestRestingHeartRate:
          latestRestingHeartRate ?? this.latestRestingHeartRate,
      restingHeartRateHistory:
          restingHeartRateHistory ?? this.restingHeartRateHistory,
      latestWeight: latestWeight ?? this.latestWeight,
      weightHistory: weightHistory ?? this.weightHistory,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}
