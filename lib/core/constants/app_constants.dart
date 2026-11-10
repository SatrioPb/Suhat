class AppConstants {
  static const String appName = 'Supercalla Health';
  static const String appVersion = '1.0.0';
  
  // Default values
  static const int defaultDailyStepGoal = 10000;
  static const int defaultRunnerAge = 30;
  static const int defaultWeeklyRunTarget = 4;
  static const String defaultDistanceUnit = 'kilometer'; // 'kilometer' atau 'mil'
  
  // Data Attribution
  static const String healthConnectSourceName = 'Google Health Connect';
  static const String bluetoothNotConnectedNotice =
      'Koneksi langsung Bluetooth (BLE) belum diaktifkan. Data bersumber dari Google Health Connect.';

  // SharedPreferences Keys
  static const String prefDailyStepGoal = 'daily_step_goal';
  static const String prefDistanceUnit = 'distance_unit';
  static const String prefLastSyncTime = 'last_sync_timestamp';
  static const String prefThemeMode = 'app_theme_mode';
  static const String prefRunnerAge = 'runner_age';
  static const String prefWeeklyRunTarget = 'weekly_run_target';
}
