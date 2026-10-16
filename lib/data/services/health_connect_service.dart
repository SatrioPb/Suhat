import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/errors/failures.dart';
import '../../features/health_connect/domain/models/health_models.dart';

/// Service yang bertanggung jawab langsung berkomunikasi dengan package `health` / Health Connect SDK
class HealthConnectService {
  final Health _health;
  bool _isConfigured = false;

  HealthConnectService({Health? healthClient})
      : _health = healthClient ?? Health();

  static const List<HealthDataType> types = [
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

  static const List<HealthDataAccess> permissions = [
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

  Future<void> ensureConfigured() async {
    if (!_isConfigured) {
      try {
        await _health.configure();
        _isConfigured = true;
      } catch (e) {
        debugPrint('Health configuration notice: $e');
      }
    }
  }

  /// Memeriksa ketersediaan Health Connect SDK
  Future<HealthConnectAvailability> checkAvailability() async {
    if (!kIsWeb && !Platform.isAndroid) {
      return HealthConnectAvailability.unsupportedPlatform;
    }

    try {
      await ensureConfigured();
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
      debugPrint('Error checkAvailability: $e');
      return HealthConnectAvailability.notInstalled;
    }
  }

  /// Memeriksa apakah izin membaca sudah diberikan
  Future<bool> hasPermissions() async {
    try {
      await ensureConfigured();
      final granted = await _health.hasPermissions(types, permissions: permissions);
      return granted == true;
    } catch (e) {
      debugPrint('Error hasPermissions: $e');
      return false;
    }
  }

  /// Meminta izin membaca data ke dialog Health Connect
  Future<bool> requestPermissions() async {
    try {
      await ensureConfigured();
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      return granted;
    } catch (e) {
      throw DataSyncFailure('Gagal memunculkan dialog izin Health Connect', e);
    }
  }

  /// Membuka Play Store untuk memasang atau memperbarui Health Connect
  Future<void> openStore() async {
    try {
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint('Error openStore: $e');
    }
  }

  /// Membaca total langkah dalam rentang waktu menggunakan agregasi Health Connect
  Future<int> getTotalSteps(DateTime start, DateTime end) async {
    try {
      await ensureConfigured();
      final total = await _health.getTotalStepsInInterval(start, end);
      return total ?? 0;
    } catch (e) {
      debugPrint('Error getTotalSteps: $e');
      return 0;
    }
  }

  /// Mengambil data point mentah dari jenis data tertentu
  Future<List<HealthDataPoint>> getRawDataPoints({
    required List<HealthDataType> dataTypes,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await ensureConfigured();
      final points = await _health.getHealthDataFromTypes(
        types: dataTypes,
        startTime: start,
        endTime: end,
      );
      return _health.removeDuplicates(points);
    } catch (e) {
      debugPrint('Error getRawDataPoints: $e');
      throw DataSyncFailure('Gagal membaca data point dari Health Connect', e);
    }
  }
}
