import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/preferences_service.dart';
import '../data/repositories/health_repository.dart';
import '../data/services/health_connect_service.dart';

/// Provider instance SharedPreferences yang di-override saat bootstrap aplikasi
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

/// Provider PreferencesService untuk membaca & menyimpan setelan lokal
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
});

/// Provider HealthConnectService (low-level Health Connect integration)
final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return HealthConnectService();
});

/// Provider HealthRepository (domain & business logic aggregator)
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final service = ref.watch(healthConnectServiceProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return HealthRepositoryImpl(
    service: service,
    preferencesService: prefs,
  );
});
