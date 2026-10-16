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

  int get totalSamples =>
      restingCount + fatBurnCount + cardioCount + peakCount;
}

/// Hasil analisis komprehensif data detak jantung
class HeartRateAnalysis {
  final int? latestBpm;
  final int minBpm;
  final int maxBpm;
  final int avgBpm;
  final HeartRateStatus status;
  final String statusDescription;
  final HeartRateZones zones;
  final DateTime? latestMeasurementTime;
  final int sampleCount;

  const HeartRateAnalysis({
    this.latestBpm,
    this.minBpm = 0,
    this.maxBpm = 0,
    this.avgBpm = 0,
    required this.status,
    required this.statusDescription,
    this.zones = const HeartRateZones(),
    this.latestMeasurementTime,
    this.sampleCount = 0,
  });

  bool get hasData => latestBpm != null && sampleCount > 0;

  factory HeartRateAnalysis.empty() => const HeartRateAnalysis(
        status: HeartRateStatus.insufficientData,
        statusDescription:
            'Belum ada sampel detak jantung yang dicatat di Health Connect.',
      );
}
