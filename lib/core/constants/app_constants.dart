class AppConstants {
  static const String appName = 'Supercalla Health';
  static const String appVersion = '1.0.0';
  
  // Default values
  static const int defaultDailyStepGoal = 10000;
  static const String defaultDistanceUnit = 'kilometer'; // 'kilometer' atau 'mil'
  
  // Data Attribution
  static const String healthConnectSourceName = 'Google Health Connect';
  static const String bluetoothNotConnectedNotice =
      'Koneksi langsung Bluetooth (BLE) belum diaktifkan. Data bersumber dari Google Health Connect.';

  // SharedPreferences Keys
  static const String prefDailyStepGoal = 'daily_step_goal';
  static const String prefDistanceUnit = 'distance_unit';
  static const String prefLastSyncTime = 'last_sync_timestamp';
}
