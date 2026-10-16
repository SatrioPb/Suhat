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
