import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/health_repository_impl.dart';
import '../../domain/models/health_models.dart';
import '../../domain/repositories/health_repository.dart';
import '../state/health_state.dart';

/// Provider untuk dependency injection HealthRepository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl();
});

/// StateNotifierProvider untuk mengelola status Health Connect & data metrik
final healthControllerProvider =
    StateNotifierProvider<HealthController, HealthState>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return HealthController(repository);
});

class HealthController extends StateNotifier<HealthState> {
  final HealthRepository _repository;

  HealthController(this._repository) : super(HealthState.initial()) {
    initialize();
  }

  /// Inisialisasi awal: cek ketersediaan SDK dan izin akses
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final availability = await _repository.checkAvailability();
      final permissions = await _repository.checkPermissions();

      state = state.copyWith(
        availability: availability,
        permissions: permissions,
        isLoading: false,
      );

      // Jika izin telah diberikan sebelumnya, langsung sinkronkan data
      if (permissions == HealthPermissionStatus.granted) {
        await fetchHealthData();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menginisialisasi Health Connect: $e',
      );
    }
  }

  /// Meminta izin akses data ke pengguna
  Future<void> requestPermissions() async {
    state = state.copyWith(isRequestingPermission: true, clearError: true);
    try {
      final granted = await _repository.requestPermissions();
      final permStatus = granted
          ? HealthPermissionStatus.granted
          : HealthPermissionStatus.denied;

      state = state.copyWith(
        permissions: permStatus,
        isRequestingPermission: false,
      );

      if (granted) {
        await fetchHealthData();
      } else {
        state = state.copyWith(
          errorMessage:
              'Izin Health Connect belum diberikan oleh pengguna. Pastikan izin membaca Langkah, Detak Jantung, dan Tidur dicentang.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRequestingPermission: false,
        errorMessage: 'Terjadi kesalahan saat meminta izin: $e',
      );
    }
  }

  /// Mengambil data kesehatan terkini (Langkah, Detak Jantung, Tidur)
  Future<void> fetchHealthData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary = await _repository.fetchHealthData();
      state = state.copyWith(
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membaca data kesehatan: $e',
      );
    }
  }

  /// Membuka tautan unduhan Health Connect di Play Store
  Future<void> openStoreForHealthConnect() async {
    await _repository.openHealthConnectInStore();
  }
}
