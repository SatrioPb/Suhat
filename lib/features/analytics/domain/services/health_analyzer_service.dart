import '../../../../data/models/heart_rate_sample.dart';
import '../../../../data/models/sleep_session.dart';
import '../models/heart_rate_analysis.dart';
import '../models/health_insight.dart';
import '../models/sleep_analysis.dart';

class HealthAnalyzerService {
  /// Menganalisis ringkasan detak jantung dan membagi zona denyut
  HeartRateAnalysis analyzeHeartRate(
    HeartRateSummary summary, {
    int userAge = 30,
  }) {
    if (summary.history.isEmpty || summary.latest == null) {
      return HeartRateAnalysis.empty();
    }

    final maxHr = 220 - userAge;
    final restingThreshold = (maxHr * 0.50).round();
    final fatBurnThreshold = (maxHr * 0.70).round();
    final cardioThreshold = (maxHr * 0.85).round();

    int restingCount = 0;
    int fatBurnCount = 0;
    int cardioCount = 0;
    int peakCount = 0;

    for (final s in summary.history) {
      if (s.bpm < restingThreshold) {
        restingCount++;
      } else if (s.bpm < fatBurnThreshold) {
        fatBurnCount++;
      } else if (s.bpm < cardioThreshold) {
        cardioCount++;
      } else {
        peakCount++;
      }
    }

    final zones = HeartRateZones(
      restingCount: restingCount,
      fatBurnCount: fatBurnCount,
      cardioCount: cardioCount,
      peakCount: peakCount,
    );

    // Evaluasi status klinis umum berdasarkan denyut rata-rata
    HeartRateStatus status;
    String statusDesc;

    final avg = summary.avgBpm;
    if (avg < 55) {
      status = HeartRateStatus.bradycardia;
      statusDesc =
          'Rata-rata detak jantung ($avg BPM) tergolong rendah. Normal bagi atlet atau saat istirahat malam hari yang sangat dalam.';
    } else if (avg <= 85) {
      status = HeartRateStatus.normal;
      statusDesc =
          'Detak jantung rata-rata ($avg BPM) berada dalam rentang istirahat sehat dan optimal (60-85 BPM).';
    } else if (avg <= 100) {
      status = HeartRateStatus.elevated;
      statusDesc =
          'Detak jantung rata-rata ($avg BPM) cenderung tinggi. Bisa dipicu oleh stres, dehidrasi, kurang tidur, atau kafein.';
    } else {
      status = HeartRateStatus.tachycardia;
      statusDesc =
          'Detak jantung rata-rata ($avg BPM) tergolong tinggi (>100 BPM). Jika terjadi saat istirahat total, luangkan waktu untuk relaksasi dan hidrasi.';
    }

    return HeartRateAnalysis(
      latestBpm: summary.latest?.bpm,
      minBpm: summary.minBpm,
      maxBpm: summary.maxBpm,
      avgBpm: summary.avgBpm,
      status: status,
      statusDescription: statusDesc,
      zones: zones,
      latestMeasurementTime: summary.latest?.timestamp,
      latestSource: summary.latest?.source,
      recordCount: summary.history.length,
    );
  }

  /// Menganalisis sesi tidur, efisiensi, dan komposisi tahapan tidur
  SleepAnalysis analyzeSleep(SleepSession? session) {
    if (session == null || session.totalSessionDuration.inMinutes < 30) {
      return SleepAnalysis.empty();
    }

    final totalMin = session.totalSessionDuration.inMinutes;
    final effectiveMin = session.effectiveSleepDuration.inMinutes;

    final efficiency = totalMin > 0
        ? ((effectiveMin / totalMin) * 100).clamp(0.0, 100.0)
        : 0.0;

    // Evaluasi kategori durasi
    SleepDurationCategory durationCat;
    if (effectiveMin < 360) {
      durationCat = SleepDurationCategory.short;
    } else if (effectiveMin < 420) {
      durationCat = SleepDurationCategory.fair;
    } else if (effectiveMin <= 540) {
      durationCat = SleepDurationCategory.optimal;
    } else {
      durationCat = SleepDurationCategory.long;
    }

    // Evaluasi efisiensi
    SleepEfficiencyCategory efficiencyCat;
    if (efficiency >= 85) {
      efficiencyCat = SleepEfficiencyCategory.good;
    } else if (efficiency >= 75) {
      efficiencyCat = SleepEfficiencyCategory.fair;
    } else {
      efficiencyCat = SleepEfficiencyCategory.poor;
    }

    // Persentase tahapan tidur jika ada
    double deepPct = 0;
    double remPct = 0;
    double lightPct = 0;
    double awakePct = 0;
    final hasStages = session.stages.isNotEmpty;

    if (hasStages && totalMin > 0) {
      int deepMin = 0;
      int remMin = 0;
      int lightMin = 0;
      int awakeMin = 0;

      for (final st in session.stages) {
        final d = st.duration.inMinutes;
        switch (st.stage) {
          case SleepStage.deep:
            deepMin += d;
            break;
          case SleepStage.rem:
            remMin += d;
            break;
          case SleepStage.light:
          case SleepStage.asleep:
            lightMin += d;
            break;
          case SleepStage.awake:
            awakeMin += d;
            break;
          case SleepStage.unknown:
            break;
        }
      }

      deepPct = (deepMin / totalMin) * 100;
      remPct = (remMin / totalMin) * 100;
      lightPct = (lightMin / totalMin) * 100;
      awakePct = (awakeMin / totalMin) * 100;
    }

    final hours = effectiveMin ~/ 60;
    final mins = effectiveMin % 60;
    final summaryDesc =
        'Tidur efektif selama ${hours}j ${mins}m dengan efisiensi ${efficiency.toStringAsFixed(1)}%. '
        '${durationCat == SleepDurationCategory.optimal ? "Memenuhi target pemulihan tubuh 7-9 jam." : "Durasi berada di luar rentang optimal 7-9 jam."}';

    return SleepAnalysis(
      totalDuration: session.totalSessionDuration,
      effectiveDuration: session.effectiveSleepDuration,
      efficiencyPercentage: efficiency,
      durationCategory: durationCat,
      efficiencyCategory: efficiencyCat,
      deepSleepPercent: deepPct,
      remSleepPercent: remPct,
      lightSleepPercent: lightPct,
      awakePercent: awakePct,
      summaryDescription: summaryDesc,
      sessionStart: session.startTime,
      sessionEnd: session.endTime,
      hasStages: hasStages,
      hasData: true,
    );
  }

  /// Menghitung skor pemulihan tubuh (0-100) dan rekomendasi actionable
  HealthInsight generateInsight({
    required HeartRateAnalysis hrAnalysis,
    required SleepAnalysis sleepAnalysis,
    int todaySteps = 0,
    int stepGoal = 10000,
    double? hrvRmssd,
    int? restingBpm,
    double? spO2Percentage,
  }) {
    if (!hrAnalysis.hasData && !sleepAnalysis.hasData) {
      return HealthInsight.empty();
    }

    int score = 0;

    // 1. Poin Durasi Tidur (Maks 40 poin)
    if (sleepAnalysis.hasData) {
      switch (sleepAnalysis.durationCategory) {
        case SleepDurationCategory.optimal:
          score += 40;
          break;
        case SleepDurationCategory.fair:
          score += 30;
          break;
        case SleepDurationCategory.long:
          score += 25;
          break;
        case SleepDurationCategory.short:
          score += 15;
          break;
        case SleepDurationCategory.noData:
          score += 20;
          break;
      }
    } else {
      score += 20; // Default separuh jika data belum ada
    }

    // 2. Poin Efisiensi Tidur (Maks 25 poin)
    if (sleepAnalysis.hasData) {
      switch (sleepAnalysis.efficiencyCategory) {
        case SleepEfficiencyCategory.good:
          score += 25;
          break;
        case SleepEfficiencyCategory.fair:
          score += 15;
          break;
        case SleepEfficiencyCategory.poor:
          score += 5;
          break;
        case SleepEfficiencyCategory.noData:
          score += 12;
          break;
      }
    } else {
      score += 12;
    }

    // 3. Poin Detak Jantung Istirahat (Maks 25 poin)
    if (hrAnalysis.hasData) {
      switch (hrAnalysis.status) {
        case HeartRateStatus.normal:
          score += 25;
          break;
        case HeartRateStatus.bradycardia:
          score += 20;
          break;
        case HeartRateStatus.elevated:
          score += 10;
          break;
        case HeartRateStatus.tachycardia:
          score += 5;
          break;
        case HeartRateStatus.insufficientData:
          score += 15;
          break;
      }
    } else {
      score += 15;
    }

    // 4. Poin Komposisi Deep Sleep & REM (Maks 10 poin)
    if (sleepAnalysis.hasStages) {
      if (sleepAnalysis.deepSleepPercent >= 15 && sleepAnalysis.remSleepPercent >= 15) {
        score += 10;
      } else if (sleepAnalysis.deepSleepPercent >= 10 || sleepAnalysis.remSleepPercent >= 10) {
        score += 6;
      } else {
        score += 3;
      }
    } else {
      score += 5;
    }

    score = score.clamp(0, 100);

    // Tentukan Level Pemulihan
    RecoveryLevel level;
    String headline;
    String summary;
    final advice = <String>[];

    if (score >= 80) {
      level = RecoveryLevel.optimal;
      headline = 'Pemulihan Tubuh Prima (Siap Beraktivitas)';
      summary = hrAnalysis.hasData
          ? 'Kombinasi kualitas tidur yang prima dan denyut jantung rata-rata (${hrAnalysis.avgBpm} BPM) yang stabil menunjukkan pemulihan kardiovaskular dan otot telah optimal.'
          : 'Kualitas dan efisiensi tidur sangat baik, mendukung regenerasi energi fisik optimal. (Menunggu rekaman denyut jantung riil dari Health Connect).';
      advice.add('Kondisi fisik prima untuk melakukan latihan olahraga intensitas sedang hingga tinggi.');
      advice.add('Pertahankan jadwal tidur yang konsisten untuk menjaga ritme sirkadian.');
      advice.add('Pastikan asupan nutrisi seimbang untuk mendukung aktivitas harian.');
    } else if (score >= 65) {
      level = RecoveryLevel.good;
      headline = 'Kondisi Tubuh Baik';
      summary = hrAnalysis.hasData
          ? 'Pemulihan fisik berjalan baik dengan denyut nadi rata-rata ${hrAnalysis.avgBpm} BPM. Energi tubuh cukup untuk menjalani rutinitas harian secara produktif.'
          : 'Pemulihan fisik berjalan baik berdasarkan durasi dan efisiensi tidur yang memadai.';
      advice.add('Aman untuk berolahraga rutin dengan pemanasan yang cukup.');
      advice.add('Perhatikan hidrasi tubuh secara berkala sepanjang hari.');
      if (sleepAnalysis.durationCategory == SleepDurationCategory.short) {
        advice.add('Targetkan tidur 30-45 menit lebih awal malam ini untuk melengkapi waktu istirahat.');
      }
    } else if (score >= 45) {
      level = RecoveryLevel.attentionNeeded;
      headline = 'Pemulihan Perlu Perhatian';
      summary = hrAnalysis.hasData
          ? 'Data menunjukkan pemulihan belum tuntas (denyut rata-rata: ${hrAnalysis.avgBpm} BPM). Perhatikan waktu istirahat dan kurangi beban berlebih.'
          : 'Indikasi pemulihan belum tuntas, kemungkinan akibat tidur kurang dari 6 jam atau kualitas istirahat yang belum optimal.';
      advice.add('Prioritaskan istirahat aktif (active recovery) seperti jalan santai atau peregangan ringan.');
      advice.add('Hindari kafein berlebih di sore hari agar tidak mengganggu tidur malam berikutnya.');
      advice.add('Luangkan waktu power nap 15-20 menit jika merasakan kantuk di siang hari.');
    } else {
      level = RecoveryLevel.restRequired;
      headline = 'Tubuh Membutuhkan Istirahat Ekstra';
      summary = hrAnalysis.hasData
          ? 'Beban kardiovaskular terindikasi tinggi (denyut rata-rata: ${hrAnalysis.avgBpm} BPM). Sangat dianjurkan memberi waktu jeda bagi tubuh untuk regenerasi.'
          : 'Skor pemulihan rendah menandakan kebutuhan istirahat fisik. Sangat dianjurkan memberi waktu jeda bagi tubuh untuk regenerasi.';
      advice.add('Tunda sesi latihan fisik berat hari ini, fokus pada pemulihan tubuh.');
      advice.add('Tingkatkan konsumsi air putih dan konsumsi makanan kaya mikronutrien.');
      advice.add('Lakukan teknik pernapasan relaksasi (deep breathing) untuk menurunkan detak jantung istirahat.');
    }

    // Tambahan insight langkah jika ada
    if (todaySteps >= stepGoal) {
      advice.add('Target $stepGoal langkah tercapai! Pastikan melakukan pendinginan.');
    }

    // Tambahan evaluasi biomarker HRV jika tersedia
    if (hrvRmssd != null) {
      if (hrvRmssd >= 50) {
        advice.add('Variabilitas detak jantung (HRV: ${hrvRmssd.round()} ms) prima, sistem syaraf otonom siap untuk aktivitas optimal.');
      } else if (hrvRmssd < 25) {
        advice.add('HRV tergolong rendah (${hrvRmssd.round()} ms). Waspadai keletihan sistem syaraf, perbanyak jeda istirahat.');
      }
    }

    // Tambahan evaluasi SpO2 jika tersedia
    if (spO2Percentage != null && spO2Percentage < 95) {
      advice.add('Saturasi oksigen darah (${spO2Percentage.toStringAsFixed(1)}%) di bawah standar 95%. Periksa posisi strap jam.');
    }

    // Tambahan evaluasi Resting Heart Rate jika tersedia
    if (restingBpm != null && restingBpm <= 65) {
      advice.add('Detak jantung istirahat ($restingBpm BPM) efisien, mencerminkan kebugaran kardiovaskular yang terjaga.');
    }

    return HealthInsight(
      recoveryScore: score,
      level: level,
      headline: headline,
      summary: summary,
      actionableAdvice: advice,
      heartRateAnalysis: hrAnalysis,
      sleepAnalysis: sleepAnalysis,
      generatedAt: DateTime.now(),
    );
  }
}
