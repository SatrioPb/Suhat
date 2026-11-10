import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  /// Mengambil target langkah harian pengguna
  int getDailyStepGoal() {
    return _prefs.getInt(AppConstants.prefDailyStepGoal) ??
        AppConstants.defaultDailyStepGoal;
  }

  /// Menyimpan target langkah harian baru
  Future<bool> setDailyStepGoal(int goal) async {
    return await _prefs.setInt(AppConstants.prefDailyStepGoal, goal);
  }

  /// Mengambil mode tampilan (terang, gelap, atau sistem)
  ThemeMode getThemeMode() {
    final raw = _prefs.getString(AppConstants.prefThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Menyimpan mode tampilan
  Future<bool> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return await _prefs.setString(AppConstants.prefThemeMode, value);
  }

  /// Mengambil usia pelari untuk kalkulasi Karvonen HRR
  int getRunnerAge() {
    return _prefs.getInt(AppConstants.prefRunnerAge) ??
        AppConstants.defaultRunnerAge;
  }

  /// Menyimpan usia pelari
  Future<bool> setRunnerAge(int age) async {
    return await _prefs.setInt(AppConstants.prefRunnerAge, age.clamp(14, 90));
  }

  /// Mengambil target frekuensi lari mingguan
  int getWeeklyRunTarget() {
    return _prefs.getInt(AppConstants.prefWeeklyRunTarget) ??
        AppConstants.defaultWeeklyRunTarget;
  }

  /// Menyimpan target frekuensi lari mingguan
  Future<bool> setWeeklyRunTarget(int target) async {
    return await _prefs.setInt(
        AppConstants.prefWeeklyRunTarget, target.clamp(1, 7));
  }

  /// Mengambil satuan jarak (misal 'kilometer')
  String getDistanceUnit() {
    return _prefs.getString(AppConstants.prefDistanceUnit) ??
        AppConstants.defaultDistanceUnit;
  }

  /// Menyimpan satuan jarak
  Future<bool> setDistanceUnit(String unit) async {
    return await _prefs.setString(AppConstants.prefDistanceUnit, unit);
  }

  /// Mengambil waktu sinkronisasi terakhir
  DateTime? getLastSyncTime() {
    final millis = _prefs.getInt(AppConstants.prefLastSyncTime);
    if (millis == null || millis == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Menyimpan waktu sinkronisasi terakhir
  Future<bool> setLastSyncTime(DateTime time) async {
    return await _prefs.setInt(
        AppConstants.prefLastSyncTime, time.millisecondsSinceEpoch);
  }
}
