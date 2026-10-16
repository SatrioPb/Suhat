abstract class Failure {
  final String message;
  final dynamic cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Kegagalan ketika Health Connect belum terpasang di perangkat
class HealthConnectNotInstalledFailure extends Failure {
  const HealthConnectNotInstalledFailure([
    super.message = 'Google Health Connect belum terpasang pada perangkat Android ini.',
    super.cause,
  ]);
}

/// Kegagalan ketika Health Connect membutuhkan pembaruan versi
class HealthConnectUpdateRequiredFailure extends Failure {
  const HealthConnectUpdateRequiredFailure([
    super.message = 'Aplikasi Google Health Connect perlu diperbarui dari Google Play Store.',
    super.cause,
  ]);
}

/// Kegagalan ketika platform bukan Android
class UnsupportedPlatformFailure extends Failure {
  const UnsupportedPlatformFailure([
    super.message = 'Health Connect hanya didukung pada sistem operasi Android.',
    super.cause,
  ]);
}

/// Kegagalan ketika izin Health Connect ditolak pengguna
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([
    super.message = 'Izin akses membaca data kesehatan belum diberikan oleh pengguna.',
    super.cause,
  ]);
}

/// Kegagalan saat sinkronisasi atau pembacaan data kesehatan
class DataSyncFailure extends Failure {
  const DataSyncFailure([
    super.message = 'Terjadi kesalahan saat membaca data dari Health Connect.',
    super.cause,
  ]);
}

/// Kegagalan umum lokal preferences
class LocalStorageFailure extends Failure {
  const LocalStorageFailure([
    super.message = 'Gagal membaca atau menyimpan data ke penyimpanan lokal.',
    super.cause,
  ]);
}
