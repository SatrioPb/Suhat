/// Kategori status detak jantung berdasarkan pedoman klinis umum
enum HeartRateStatus {
  normal,
  elevated,
  bradycardia,
  tachycardia,
  insufficientData;

  String get label {
    switch (this) {
      case HeartRateStatus.normal:
        return 'Normal & Stabil';
      case HeartRateStatus.elevated:
        return 'Cenderung Meningkat';
      case HeartRateStatus.bradycardia:
        return 'Rendah (Bradikardia)';
      case HeartRateStatus.tachycardia:
        return 'Tinggi (Takikardia)';
      case HeartRateStatus.insufficientData:
        return 'Data Tidak Cukup';
    }
  }

  String get shortLabel {
    switch (this) {
      case HeartRateStatus.normal:
        return 'Normal';
      case HeartRateStatus.elevated:
        return 'Meningkat';
      case HeartRateStatus.bradycardia:
        return 'Bradikardia';
      case HeartRateStatus.tachycardia:
        return 'Takikardia';
      case HeartRateStatus.insufficientData:
        return 'Kurang Data';
    }
  }
}

/// Distribusi estimasi zona denyut jantung
class HeartRateZones {
  final int restingCount;
  final int fatBurnCount;
  final int cardioCount;
  final int peakCount;

  const HeartRateZones({
    this.restingCount = 0,
    this.fatBurnCount = 0,
    this.cardioCount = 0,
    this.peakCount = 0,
  });

  int get totalRecords =>
      restingCount + fatBurnCount + cardioCount + peakCount;

  /// Alias kompatibilitas
  int get totalSamples => totalRecords;
}

/// Hasil analisis komprehensif data detak jantung riil
class HeartRateAnalysis {
  final int? latestBpm;
  final int minBpm;
  final int maxBpm;
  final int avgBpm;
  final HeartRateStatus status;
  final String statusDescription;
  final HeartRateZones zones;
  final DateTime? latestMeasurementTime;
  final String? latestSource;
  final int recordCount;

  const HeartRateAnalysis({
    this.latestBpm,
    this.minBpm = 0,
    this.maxBpm = 0,
    this.avgBpm = 0,
    required this.status,
    required this.statusDescription,
    this.zones = const HeartRateZones(),
    this.latestMeasurementTime,
    this.latestSource,
    int recordCount = 0,
    int? sampleCount,
  }) : recordCount = sampleCount ?? recordCount;

  /// Alias kompatibilitas dengan pengujian lama
  int get sampleCount => recordCount;

  bool get hasData => latestBpm != null && recordCount > 0;

  factory HeartRateAnalysis.empty() => const HeartRateAnalysis(
        status: HeartRateStatus.insufficientData,
        statusDescription:
            'Belum ada rekaman detak jantung nyata yang dicatat di Google Health Connect.',
      );
}
