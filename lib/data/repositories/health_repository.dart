import 'package:health/health.dart';

import '../../core/constants/app_constants.dart';
import '../../features/health_connect/domain/models/health_models.dart';
import '../local/preferences_service.dart';
import '../models/health_summary.dart';
import '../models/heart_rate_sample.dart';
import '../models/sleep_session.dart';
import '../models/step_data.dart';
import '../services/health_connect_service.dart';

abstract class HealthRepository {
  /// Memeriksa ketersediaan Google Health Connect SDK di perangkat
  Future<HealthConnectAvailability> checkAvailability();

  /// Memeriksa status izin baca
  Future<HealthPermissionStatus> checkPermissions();

  /// Meminta izin baca ke pengguna
  Future<bool> requestPermissions();

  /// Membuka Play Store untuk mengunduh/memperbarui Health Connect
  Future<void> openHealthConnectStore();

  /// Mengambil data langkah untuk satu tanggal kalender lokal tertentu
  Future<DailyStepData> fetchDailySteps(DateTime date, {int? customGoal});

  /// Mengambil riwayat langkah 7 hari terakhir (mingguan)
  Future<List<DailyStepData>> fetchWeeklySteps({
    DateTime? referenceDate,
    int? customGoal,
  });

  /// Mengambil data sampel dan ringkasan detak jantung
  Future<HeartRateSummary> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Mengambil data sesi dan tahapan tidur
  Future<List<SleepSession>> fetchSleepSessions({
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Mengambil ringkasan lengkap untuk Dashboard (Langkah, Detak Jantung, Tidur, Riwayat Mingguan)
  Future<HealthSummary> fetchHealthSummary({int? stepGoal});
}

class HealthRepositoryImpl implements HealthRepository {
  final HealthConnectService _service;
  final PreferencesService? _prefs;

  HealthRepositoryImpl({
    HealthConnectService? service,
    PreferencesService? preferencesService,
  })  : _service = service ?? HealthConnectService(),
        _prefs = preferencesService;

  @override
  Future<HealthConnectAvailability> checkAvailability() async {
    return await _service.checkAvailability();
  }

  @override
  Future<HealthPermissionStatus> checkPermissions() async {
    final hasPerms = await _service.hasPermissions();
    return hasPerms ? HealthPermissionStatus.granted : HealthPermissionStatus.denied;
  }

  @override
  Future<bool> requestPermissions() async {
    return await _service.requestPermissions();
  }

  @override
  Future<void> openHealthConnectStore() async {
    await _service.openStore();
  }

  @override
  Future<DailyStepData> fetchDailySteps(DateTime date, {int? customGoal}) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final goal = customGoal ?? _prefs?.getDailyStepGoal() ?? AppConstants.defaultDailyStepGoal;
    final total = await _service.getTotalSteps(startOfDay, endOfDay);

    // Ambil sampel interval langkah jika tersedia
    final samples = <StepSample>[];
    try {
      final points = await _service.getRawDataPoints(
        dataTypes: [HealthDataType.STEPS],
        start: startOfDay,
        end: endOfDay,
      );

      for (final p in points) {
        if (p.value is NumericHealthValue) {
          final count = (p.value as NumericHealthValue).numericValue.round();
          samples.add(StepSample(
            count: count,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty ? p.sourceName : AppConstants.healthConnectSourceName,
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      samples.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (_) {
      // Abaikan jika granular interval gagal dibaca, tetap kembalikan total agregasi
    }

    return DailyStepData(
      date: startOfDay,
      totalSteps: total,
      goalSteps: goal,
      samples: samples,
    );
  }

  @override
  Future<List<DailyStepData>> fetchWeeklySteps({
    DateTime? referenceDate,
    int? customGoal,
  }) async {
    final ref = referenceDate ?? DateTime.now();
    final weekly = <DailyStepData>[];

    // Iterasi 7 hari ke belakang (dari 6 hari lalu sampai hari ini)
    for (int i = 6; i >= 0; i--) {
      final targetDate = ref.subtract(Duration(days: i));
      final dailyData = await fetchDailySteps(targetDate, customGoal: customGoal);
      weekly.add(dailyData);
    }

    return weekly;
  }

  @override
  Future<HeartRateSummary> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(hours: 24));
    final end = endTime ?? now;

    try {
      final points = await _service.getRawDataPoints(
        dataTypes: [HealthDataType.HEART_RATE],
        start: start,
        end: end,
      );

      final samples = <HeartRateSample>[];
      for (final p in points) {
        if (p.value is NumericHealthValue) {
          final bpm = (p.value as NumericHealthValue).numericValue.round();
          samples.add(HeartRateSample(
            bpm: bpm,
            timestamp: p.dateTo,
            source: p.sourceName.isNotEmpty ? p.sourceName : AppConstants.healthConnectSourceName,
            deviceId: p.sourceDeviceId,
          ));
        }
      }

      return HeartRateSummary.fromSamples(samples);
    } catch (_) {
      return const HeartRateSummary();
    }
  }

  @override
  Future<List<SleepSession>> fetchSleepSessions({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(days: 3));
    final end = endTime ?? now;

    const sleepTypes = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
    ];

    try {
      final points = await _service.getRawDataPoints(
        dataTypes: sleepTypes,
        start: start,
        end: end,
      );

      final sessions = points.where((p) => p.type == HealthDataType.SLEEP_SESSION).toList();
      final stages = points.where((p) => p.type != HealthDataType.SLEEP_SESSION).toList();

      final result = <SleepSession>[];

      if (sessions.isNotEmpty) {
        for (final s in sessions) {
          final sessionStages = stages
              .where((st) => !st.dateFrom.isBefore(s.dateFrom) && !st.dateTo.isAfter(s.dateTo))
              .map((st) => SleepStageItem(
                    stage: _mapSleepStage(st.type),
                    startTime: st.dateFrom,
                    endTime: st.dateTo,
                  ))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          result.add(SleepSession(
            startTime: s.dateFrom,
            endTime: s.dateTo,
            source: s.sourceName.isNotEmpty ? s.sourceName : AppConstants.healthConnectSourceName,
            stages: sessionStages,
            deviceId: s.sourceDeviceId,
          ));
        }
      } else if (stages.isNotEmpty) {
        stages.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        DateTime? currentStart;
        DateTime? currentEnd;
        String source = AppConstants.healthConnectSourceName;
        String? deviceId;
        final currentStages = <SleepStageItem>[];

        for (final st in stages) {
          source = st.sourceName.isNotEmpty ? st.sourceName : source;
          deviceId = st.sourceDeviceId;

          if (currentEnd == null || st.dateFrom.difference(currentEnd).inHours > 2) {
            if (currentStart != null && currentEnd != null) {
              result.add(SleepSession(
                startTime: currentStart,
                endTime: currentEnd,
                source: source,
                stages: List.from(currentStages),
                deviceId: deviceId,
              ));
              currentStages.clear();
            }
            currentStart = st.dateFrom;
          }
          currentEnd = st.dateTo;
          currentStages.add(SleepStageItem(
            stage: _mapSleepStage(st.type),
            startTime: st.dateFrom,
            endTime: st.dateTo,
          ));
        }

        if (currentStart != null && currentEnd != null) {
          result.add(SleepSession(
            startTime: currentStart,
            endTime: currentEnd,
            source: source,
            stages: List.from(currentStages),
            deviceId: deviceId,
          ));
        }
      }

      result.sort((a, b) => b.startTime.compareTo(a.startTime));
      return result;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<HealthSummary> fetchHealthSummary({int? stepGoal}) async {
    final now = DateTime.now();
    final goal = stepGoal ?? _prefs?.getDailyStepGoal() ?? AppConstants.defaultDailyStepGoal;

    final todaySteps = await fetchDailySteps(now, customGoal: goal);
    final weeklySteps = await fetchWeeklySteps(referenceDate: now, customGoal: goal);
    final heartRate = await fetchHeartRate();
    final sleepSessions = await fetchSleepSessions();

    final summary = HealthSummary(
      todaySteps: todaySteps,
      weeklySteps: weeklySteps,
      heartRate: heartRate,
      latestSleep: sleepSessions.isNotEmpty ? sleepSessions.first : null,
      sleepHistory: sleepSessions,
      lastSyncTime: now,
    );

    await _prefs?.setLastSyncTime(now);
    return summary;
  }

  SleepStage _mapSleepStage(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_DEEP:
        return SleepStage.deep;
      case HealthDataType.SLEEP_LIGHT:
        return SleepStage.light;
      case HealthDataType.SLEEP_REM:
        return SleepStage.rem;
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_AWAKE_IN_BED:
      case HealthDataType.SLEEP_OUT_OF_BED:
        return SleepStage.awake;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_SESSION:
      case HealthDataType.SLEEP_IN_BED:
        return SleepStage.asleep;
      default:
        return SleepStage.unknown;
    }
  }
}
