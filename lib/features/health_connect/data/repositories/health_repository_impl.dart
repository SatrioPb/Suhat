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

  /// Daftar tipe data yang didukung oleh Suhat
  static const List<HealthDataType> requiredTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.WEIGHT,
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
    HealthDataAccess.READ,
    HealthDataAccess.READ,
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
      final start = startTime ?? now.subtract(const Duration(hours: 48));
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
    final defaultStart = startTime ?? now.subtract(const Duration(hours: 48));
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

    // Ambil detak jantung (rentang 48 jam ke belakang agar mencakup sinkronisasi smartwatch berkala)
    final hrRecords = await fetchHeartRate(
      startTime: defaultStart,
      endTime: end,
    );
    final latestHr = hrRecords.isNotEmpty ? hrRecords.first : null;

    // Ambil tidur (rentang 48 jam ke belakang untuk mencakup tidur semalam)
    final sleepRecords = await fetchSleep(
      startTime: now.subtract(const Duration(days: 2)),
      endTime: now,
    );
    final latestSleep = sleepRecords.isNotEmpty ? sleepRecords.first : null;

    // 4. Ambil Kalori Aktif (Active Calories Burned)
    final activeCalRecords = <ActiveCaloriesRecord>[];
    double totalActiveCal = 0.0;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          final cal = (p.value as NumericHealthValue).numericValue.toDouble();
          totalActiveCal += cal;
          activeCalRecords.add(ActiveCaloriesRecord(
            kcal: cal,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      activeCalRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching active calories: $e');
    }

    // 5. Ambil Total Kalori Terbakar (Total Calories Burned)
    final totalCalRecords = <TotalCaloriesRecord>[];
    double totalCal = 0.0;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.TOTAL_CALORIES_BURNED],
        startTime: midnight,
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          final cal = (p.value as NumericHealthValue).numericValue.toDouble();
          totalCal += cal;
          totalCalRecords.add(TotalCaloriesRecord(
            kcal: cal,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      totalCalRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching total calories: $e');
    }

    // 6. Ambil Jarak Tempuh (Distance)
    final distRecords = <DistanceRecord>[];
    double totalDist = 0.0;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: midnight,
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          final dist = (p.value as NumericHealthValue).numericValue.toDouble();
          totalDist += dist;
          distRecords.add(DistanceRecord(
            distanceMeters: dist,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      distRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching distance: $e');
    }

    // 7. Ambil Elevasi / Lantai Dinaiki (Floors Climbed)
    final elevRecords = <ElevationRecord>[];
    double totalFloors = 0.0;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.FLIGHTS_CLIMBED],
        startTime: midnight,
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          final floors =
              (p.value as NumericHealthValue).numericValue.toDouble();
          totalFloors += floors;
          elevRecords.add(ElevationRecord(
            floorsClimbed: floors,
            startTime: p.dateFrom,
            endTime: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      elevRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching elevation/floors: $e');
    }

    // 8. Ambil Sesi Olahraga (Workouts / Exercise)
    final exerciseRecords = <ExerciseRecord>[];
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: now.subtract(const Duration(days: 7)),
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        String activityName = 'Olahraga';
        double? cal;
        double? dist;
        if (p.value is WorkoutHealthValue) {
          final wv = p.value as WorkoutHealthValue;
          activityName = wv.workoutActivityType.name.replaceAll('_', ' ');
          cal = wv.totalEnergyBurned?.toDouble();
          dist = wv.totalDistance?.toDouble();
        }
        exerciseRecords.add(ExerciseRecord(
          activityName: activityName,
          duration: p.dateTo.difference(p.dateFrom),
          startTime: p.dateFrom,
          endTime: p.dateTo,
          caloriesBurned: cal,
          distanceMeters: dist,
          source: p.sourceName.isNotEmpty
              ? p.sourceName
              : 'Google Health Connect',
          deviceId: p.sourceDeviceId,
        ));
      }
      exerciseRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
    }

    // 9. Ambil Variabilitas Detak Jantung (HRV - RMSSD)
    final hrvRecords = <HrvRecord>[];
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
        startTime: now.subtract(const Duration(days: 7)),
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          hrvRecords.add(HrvRecord(
            rmssdMillis:
                (p.value as NumericHealthValue).numericValue.toDouble(),
            timestamp: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      hrvRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching HRV: $e');
    }
    final latestHrv = hrvRecords.isNotEmpty ? hrvRecords.first : null;

    // 10. Ambil Detak Jantung Istirahat (Resting Heart Rate)
    final restingHrRecords = <RestingHeartRateRecord>[];
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.RESTING_HEART_RATE],
        startTime: now.subtract(const Duration(days: 7)),
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          restingHrRecords.add(RestingHeartRateRecord(
            bpm: (p.value as NumericHealthValue).numericValue.round(),
            timestamp: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      restingHrRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching resting HR: $e');
    }
    final latestRestingHr =
        restingHrRecords.isNotEmpty ? restingHrRecords.first : null;

    // 11. Ambil Saturasi Oksigen Darah (SpO2)
    final spo2Records = <OxygenSaturationRecord>[];
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: now.subtract(const Duration(days: 7)),
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          var pct = (p.value as NumericHealthValue).numericValue.toDouble();
          if (pct <= 1.0 && pct > 0) {
            pct = pct * 100.0;
          }
          spo2Records.add(OxygenSaturationRecord(
            percentage: pct,
            timestamp: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      spo2Records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching SpO2: $e');
    }
    final latestSpo2 = spo2Records.isNotEmpty ? spo2Records.first : null;

    // 12. Ambil Tinggi Badan (Height)
    HeightRecord? latestHeight;
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEIGHT],
        startTime: now.subtract(const Duration(days: 90)),
        endTime: now,
      );
      final sorted = _health.removeDuplicates(points);
      sorted.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      if (sorted.isNotEmpty && sorted.first.value is NumericHealthValue) {
        latestHeight = HeightRecord(
          heightMeters:
              (sorted.first.value as NumericHealthValue).numericValue.toDouble(),
          timestamp: sorted.first.dateTo,
          source: sorted.first.sourceName.isNotEmpty
              ? sorted.first.sourceName
              : 'Google Health Connect',
          deviceId: sorted.first.sourceDeviceId,
        );
      }
    } catch (e) {
      debugPrint('Error fetching height: $e');
    }

    // 13. Ambil Berat Badan (Weight)
    final weightRecords = <WeightRecord>[];
    try {
      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: now.subtract(const Duration(days: 90)),
        endTime: now,
      );
      for (final p in _health.removeDuplicates(points)) {
        if (p.value is NumericHealthValue) {
          weightRecords.add(WeightRecord(
            weightKg:
                (p.value as NumericHealthValue).numericValue.toDouble(),
            timestamp: p.dateTo,
            source: p.sourceName.isNotEmpty
                ? p.sourceName
                : 'Google Health Connect',
            deviceId: p.sourceDeviceId,
          ));
        }
      }
      weightRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching weight: $e');
    }
    final latestWeight =
        weightRecords.isNotEmpty ? weightRecords.first : null;

    return HealthDataSummary(
      totalStepsToday: totalSteps,
      stepRecords: stepRecords,
      latestHeartRate: latestHr,
      heartRateHistory: hrRecords,
      latestSleep: latestSleep,
      sleepHistory: sleepRecords,
      totalActiveCaloriesToday: totalActiveCal,
      activeCaloriesRecords: activeCalRecords,
      totalCaloriesBurnedToday: totalCal,
      totalCaloriesRecords: totalCalRecords,
      totalDistanceToday: totalDist,
      distanceRecords: distRecords,
      totalFloorsClimbedToday: totalFloors,
      elevationRecords: elevRecords,
      exerciseRecords: exerciseRecords,
      latestHrv: latestHrv,
      hrvHistory: hrvRecords,
      latestHeight: latestHeight,
      latestOxygenSaturation: latestSpo2,
      oxygenSaturationHistory: spo2Records,
      latestRestingHeartRate: latestRestingHr,
      restingHeartRateHistory: restingHrRecords,
      latestWeight: latestWeight,
      weightHistory: weightRecords,
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
