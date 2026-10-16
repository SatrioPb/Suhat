import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../domain/models/health_models.dart';
import '../../domain/repositories/health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  final Health _health;
  bool _isConfigured = false;

  HealthRepositoryImpl({Health? healthClient})
      : _health = healthClient ?? Health();

  /// Daftar tipe data yang divalidasi pada Fase 1
  static const List<HealthDataType> requiredTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  /// Izin akses pembacaan yang sesuai
  static const List<HealthDataAccess> requiredPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      try {
        await _health.configure();
        _isConfigured = true;
      } catch (e) {
        debugPrint('Health configuration warning: $e');
      }
    }
  }

  @override
  Future<HealthConnectAvailability> checkAvailability() async {
    if (!kIsWeb && !Platform.isAndroid) {
      return HealthConnectAvailability.unsupportedPlatform;
    }

    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      switch (status) {
        case HealthConnectSdkStatus.sdkAvailable:
          return HealthConnectAvailability.available;
        case HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
          return HealthConnectAvailability.updateRequired;
        case HealthConnectSdkStatus.sdkUnavailable:
        default:
          return HealthConnectAvailability.notInstalled;
      }
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return HealthConnectAvailability.notInstalled;
    }
  }

  @override
  Future<HealthPermissionStatus> checkPermissions() async {
    try {
      await _ensureConfigured();
      final hasPerms = await _health.hasPermissions(
        requiredTypes,
        permissions: requiredPermissions,
      );

      if (hasPerms == true) {
        return HealthPermissionStatus.granted;
      } else if (hasPerms == false) {
        return HealthPermissionStatus.denied;
      } else {
        return HealthPermissionStatus.unknown;
      }
    } catch (e) {
      debugPrint('Error checking Health Connect permissions: $e');
      return HealthPermissionStatus.unknown;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(
        requiredTypes,
        permissions: requiredPermissions,
      );
      return granted;
    } catch (e) {
      debugPrint('Error requesting Health Connect authorization: $e');
      return false;
    }
  }

  @override
  Future<void> openHealthConnectInStore() async {
    try {
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint('Error opening Health Connect in Play Store: $e');
    }
  }

  @override
  Future<int> fetchTodaySteps() async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final total = await _health.getTotalStepsInInterval(midnight, now);
      return total ?? 0;
    } catch (e) {
      debugPrint('Error fetching steps interval: $e');
      return 0;
    }
  }

  @override
  Future<List<HeartRateRecord>> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final start = startTime ?? now.subtract(const Duration(hours: 24));
      final end = endTime ?? now;

      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      // Bersihkan duplikat jika ada
      final uniquePoints = _health.removeDuplicates(dataPoints);

      final records = <HeartRateRecord>[];
      for (final point in uniquePoints) {
        if (point.value is NumericHealthValue) {
          final numeric = (point.value as NumericHealthValue).numericValue;
          records.add(HeartRateRecord(
            bpm: numeric.round(),
            timestamp: point.dateTo,
            source: point.sourceName.isNotEmpty
                ? point.sourceName
                : 'Google Health Connect',
            deviceId: point.sourceDeviceId,
          ));
        }
      }

      // Urutkan dari yang terbaru ke terlama
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    } catch (e) {
      debugPrint('Error fetching heart rate data: $e');
      return [];
    }
  }

  @override
  Future<List<SleepRecord>> fetchSleep({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final start = startTime ?? now.subtract(const Duration(days: 2));
      final end = endTime ?? now;

      const sleepTypes = [
        HealthDataType.SLEEP_SESSION,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
      ];

      final rawDataPoints = await _health.getHealthDataFromTypes(
        types: sleepTypes,
        startTime: start,
        endTime: end,
      );

      final dataPoints = _health.removeDuplicates(rawDataPoints);

      final sessionPoints = dataPoints
          .where((p) => p.type == HealthDataType.SLEEP_SESSION)
          .toList();

      final stagePoints = dataPoints
          .where((p) => p.type != HealthDataType.SLEEP_SESSION)
          .toList();

      final sleepRecords = <SleepRecord>[];

      if (sessionPoints.isNotEmpty) {
        for (final session in sessionPoints) {
          // Cari stage yang masuk dalam rentang waktu sesi ini
          final sessionStages = stagePoints
              .where((st) =>
                  !st.dateFrom.isBefore(session.dateFrom) &&
                  !st.dateTo.isAfter(session.dateTo))
              .map((st) => SleepStageRecord(
                    stage: _mapSleepStageType(st.type),
                    startTime: st.dateFrom,
                    endTime: st.dateTo,
                  ))
              .toList();

          sessionStages.sort((a, b) => a.startTime.compareTo(b.startTime));

          sleepRecords.add(SleepRecord(
            startTime: session.dateFrom,
            endTime: session.dateTo,
            source: session.sourceName.isNotEmpty
                ? session.sourceName
                : 'Google Health Connect',
            stages: sessionStages,
            deviceId: session.sourceDeviceId,
          ));
        }
      } else if (stagePoints.isNotEmpty) {
        // Jika provider mencatat stage tanpa enclosing SLEEP_SESSION
        stagePoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        // Kelompokkan stages yang berdekatan (kurang dari 2 jam selang)
        DateTime? currentStart;
        DateTime? currentEnd;
        String source = 'Google Health Connect';
        String? deviceId;
        final currentStages = <SleepStageRecord>[];

        for (final st in stagePoints) {
          source = st.sourceName.isNotEmpty ? st.sourceName : source;
          deviceId = st.sourceDeviceId;

          if (currentEnd == null ||
              st.dateFrom.difference(currentEnd).inHours > 2) {
            if (currentStart != null && currentEnd != null) {
              sleepRecords.add(SleepRecord(
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
          currentStages.add(SleepStageRecord(
            stage: _mapSleepStageType(st.type),
            startTime: st.dateFrom,
            endTime: st.dateTo,
          ));
        }

        if (currentStart != null && currentEnd != null) {
          sleepRecords.add(SleepRecord(
            startTime: currentStart,
            endTime: currentEnd,
            source: source,
            stages: List.from(currentStages),
            deviceId: deviceId,
          ));
        }
      }

      // Urutkan rekaman tidur dari yang paling baru
      sleepRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
      return sleepRecords;
    } catch (e) {
      debugPrint('Error fetching sleep data: $e');
      return [];
    }
  }

  @override
  Future<HealthDataSummary> fetchHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(hours: 24));
    final end = endTime ?? now;
    final midnight = DateTime(now.year, now.month, now.day);

    // Ambil total langkah
    final totalSteps = await fetchTodaySteps();

    // Ambil rincian segmen langkah
    List<StepRecord> stepRecords = [];
    try {
      final stepPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );
      final uniqueSteps = _health.removeDuplicates(stepPoints);
      for (final p in uniqueSteps) {
        if (p.value is NumericHealthValue) {
          final count = (p.value as NumericHealthValue).numericValue.round();
          stepRecords.add(StepRecord(
            count: count,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      stepRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching step detail points: $e');
    }

    // Ambil detak jantung
    final hrRecords = await fetchHeartRate(startTime: start, endTime: end);
    final latestHr = hrRecords.isNotEmpty ? hrRecords.first : null;

    // Ambil tidur (rentang 48 jam ke belakang untuk mencakup tidur semalam)
    final sleepRecords = await fetchSleep(
      startTime: now.subtract(const Duration(days: 2)),
      endTime: now,
    );
    final latestSleep = sleepRecords.isNotEmpty ? sleepRecords.first : null;

    return HealthDataSummary(
      totalStepsToday: totalSteps,
      stepRecords: stepRecords,
      latestHeartRate: latestHr,
      heartRateHistory: hrRecords,
      latestSleep: latestSleep,
      sleepHistory: sleepRecords,
      lastFetched: now,
    );
  }

  SleepStageType _mapSleepStageType(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_DEEP:
        return SleepStageType.deep;
      case HealthDataType.SLEEP_LIGHT:
        return SleepStageType.light;
      case HealthDataType.SLEEP_REM:
        return SleepStageType.rem;
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_AWAKE_IN_BED:
      case HealthDataType.SLEEP_OUT_OF_BED:
        return SleepStageType.awake;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_SESSION:
      case HealthDataType.SLEEP_IN_BED:
        return SleepStageType.asleep;
      default:
        return SleepStageType.unknown;
    }
  }
}
