/// Kategori evaluasi durasi tidur
enum SleepDurationCategory {
  optimal, // 7 - 9 jam
  fair,    // 6 - 7 jam
  short,   // < 6 jam
  long,    // > 9 jam
  noData;

  String get label {
    switch (this) {
      case SleepDurationCategory.optimal:
        return 'Durasi Optimal (7-9 jam)';
      case SleepDurationCategory.fair:
        return 'Cukup (6-7 jam)';
      case SleepDurationCategory.short:
        return 'Kurang Tidur (<6 jam)';
      case SleepDurationCategory.long:
        return 'Durasi Panjang (>9 jam)';
      case SleepDurationCategory.noData:
        return 'Belum Ada Data';
    }
  }

  String get shortLabel {
    switch (this) {
      case SleepDurationCategory.optimal:
        return 'Optimal';
      case SleepDurationCategory.fair:
        return 'Cukup';
      case SleepDurationCategory.short:
        return 'Kurang';
      case SleepDurationCategory.long:
        return 'Panjang';
      case SleepDurationCategory.noData:
        return 'Tanpa Data';
    }
  }
}

/// Kategori evaluasi efisiensi tidur
enum SleepEfficiencyCategory {
  good, // >= 85%
  fair, // 75% - 84%
  poor, // < 75%
  noData;

  String get label {
    switch (this) {
      case SleepEfficiencyCategory.good:
        return 'Efisiensi Baik (≥85%)';
      case SleepEfficiencyCategory.fair:
        return 'Efisiensi Sedang (75-84%)';
      case SleepEfficiencyCategory.poor:
        return 'Banyak Terbangun (<75%)';
      case SleepEfficiencyCategory.noData:
        return 'Belum Ada Data';
    }
  }
}

/// Hasil analisis sesi tidur
class SleepAnalysis {
  final Duration totalDuration;
  final Duration effectiveDuration;
  final double efficiencyPercentage;
  final SleepDurationCategory durationCategory;
  final SleepEfficiencyCategory efficiencyCategory;
  final double deepSleepPercent;
  final double remSleepPercent;
  final double lightSleepPercent;
  final double awakePercent;
  final String summaryDescription;
  final DateTime? sessionStart;
  final DateTime? sessionEnd;
  final bool hasStages;
  final bool hasData;

  const SleepAnalysis({
    this.totalDuration = Duration.zero,
    this.effectiveDuration = Duration.zero,
    this.efficiencyPercentage = 0.0,
    required this.durationCategory,
    required this.efficiencyCategory,
    this.deepSleepPercent = 0.0,
    this.remSleepPercent = 0.0,
    this.lightSleepPercent = 0.0,
    this.awakePercent = 0.0,
    required this.summaryDescription,
    this.sessionStart,
    this.sessionEnd,
    this.hasStages = false,
    this.hasData = false,
  });

  factory SleepAnalysis.empty() => const SleepAnalysis(
        durationCategory: SleepDurationCategory.noData,
        efficiencyCategory: SleepEfficiencyCategory.noData,
        summaryDescription:
            'Belum ada rekaman sesi tidur yang dicatat di Health Connect.',
        hasData: false,
      );
}
