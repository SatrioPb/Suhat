import '../../domain/models/health_models.dart';

class HealthState {
  final HealthConnectAvailability availability;
  final HealthPermissionStatus permissions;
  final HealthDataSummary summary;
  final bool isLoading;
  final bool isRequestingPermission;
  final String? errorMessage;

  /// Keterangan eksplisit mengenai sumber data
  /// Selama Fase 1, data hanya bersumber dari Google Health Connect
  final bool isDirectBluetoothConnected;

  const HealthState({
    required this.availability,
    required this.permissions,
    required this.summary,
    this.isLoading = false,
    this.isRequestingPermission = false,
    this.errorMessage,
    this.isDirectBluetoothConnected = false,
  });

  factory HealthState.initial() => HealthState(
        availability: HealthConnectAvailability.checking,
        permissions: HealthPermissionStatus.unknown,
        summary: HealthDataSummary.empty(),
        isLoading: false,
        isRequestingPermission: false,
        errorMessage: null,
        isDirectBluetoothConnected: false,
      );

  HealthState copyWith({
    HealthConnectAvailability? availability,
    HealthPermissionStatus? permissions,
    HealthDataSummary? summary,
    bool? isLoading,
    bool? isRequestingPermission,
    String? errorMessage,
    bool clearError = false,
    bool? isDirectBluetoothConnected,
  }) {
    return HealthState(
      availability: availability ?? this.availability,
      permissions: permissions ?? this.permissions,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isRequestingPermission:
          isRequestingPermission ?? this.isRequestingPermission,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isDirectBluetoothConnected:
          isDirectBluetoothConnected ?? this.isDirectBluetoothConnected,
    );
  }
}
