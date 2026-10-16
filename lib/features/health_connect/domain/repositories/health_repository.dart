import '../models/health_models.dart';

abstract class HealthRepository {
  /// Memeriksa ketersediaan Google Health Connect SDK di perangkat
  Future<HealthConnectAvailability> checkAvailability();

  /// Memeriksa status izin akses data kesehatan (Steps, Heart Rate, Sleep)
  Future<HealthPermissionStatus> checkPermissions();

  /// Meminta izin akses data kesehatan ke pengguna melalui Health Connect dialog
  Future<bool> requestPermissions();

  /// Membuka Play Store untuk menginstal atau memperbarui Health Connect
  Future<void> openHealthConnectInStore();

  /// Mengambil ringkasan data langkah, detak jantung, dan tidur
  Future<HealthDataSummary> fetchHealthData({
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Mengambil total langkah hari ini
  Future<int> fetchTodaySteps();

  /// Mengambil catatan detak jantung pada rentang waktu tertentu
  Future<List<HeartRateRecord>> fetchHeartRate({
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Mengambil catatan sesi dan tahapan tidur pada rentang waktu tertentu
  Future<List<SleepRecord>> fetchSleep({
    DateTime? startTime,
    DateTime? endTime,
  });
}
