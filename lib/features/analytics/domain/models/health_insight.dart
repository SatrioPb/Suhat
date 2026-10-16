import 'heart_rate_analysis.dart';
import 'sleep_analysis.dart';

/// Level skor pemulihan dan kesiapan fisik harian
enum RecoveryLevel {
  optimal,        // 80 - 100
  good,           // 65 - 79
  attentionNeeded,// 45 - 64
  restRequired,   // < 45
  insufficientData;

  String get label {
    switch (this) {
      case RecoveryLevel.optimal:
        return 'Pemulihan Prima';
      case RecoveryLevel.good:
        return 'Kondisi Baik';
      case RecoveryLevel.attentionNeeded:
        return 'Perlu Perhatian';
      case RecoveryLevel.restRequired:
        return 'Butuh Istirahat';
      case RecoveryLevel.insufficientData:
        return 'Menunggu Data';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecoveryLevel.optimal:
        return 'Prima';
      case RecoveryLevel.good:
        return 'Baik';
      case RecoveryLevel.attentionNeeded:
        return 'Perhatian';
      case RecoveryLevel.restRequired:
        return 'Istirahat';
      case RecoveryLevel.insufficientData:
        return 'Menunggu';
    }
  }
}

/// Rekomendasi terpadu dan skor pemulihan kesehatan
class HealthInsight {
  final int recoveryScore; // 0 - 100
  final RecoveryLevel level;
  final String headline;
  final String summary;
  final List<String> actionableAdvice;
  final HeartRateAnalysis heartRateAnalysis;
  final SleepAnalysis sleepAnalysis;
  final DateTime generatedAt;
  final String medicalDisclaimer;

  const HealthInsight({
    required this.recoveryScore,
    required this.level,
    required this.headline,
    required this.summary,
    required this.actionableAdvice,
    required this.heartRateAnalysis,
    required this.sleepAnalysis,
    required this.generatedAt,
    this.medicalDisclaimer =
        'Analisis dan rekomendasi ini bersifat panduan kebugaran umum (wellness guidance) '
        'berdasarkan data Health Connect, dan bukan merupakan diagnosis medis pengganti konsultasi dokter.',
  });

  factory HealthInsight.empty() => HealthInsight(
        recoveryScore: 0,
        level: RecoveryLevel.insufficientData,
        headline: 'Menunggu Sinkronisasi Data',
        summary:
            'Sinkronkan data langkah, detak jantung, dan tidur dari smartwatch atau aplikasi ke Health Connect untuk menghasilkan analisis pemulihan tubuh Anda.',
        actionableAdvice: const [
          'Pastikan izin akses membaca Health Connect telah diberikan.',
          'Buka aplikasi smartwatch Anda (seperti Fitbeing) untuk memicu sinkronisasi data ke Health Connect.',
        ],
        heartRateAnalysis: HeartRateAnalysis.empty(),
        sleepAnalysis: SleepAnalysis.empty(),
        generatedAt: DateTime.now(),
      );
}
