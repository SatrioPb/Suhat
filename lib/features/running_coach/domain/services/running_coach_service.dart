import 'package:suhat/features/analytics/domain/models/health_insight.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';

/// Service pemberi rekomendasi latihan lari cerdas berbasis prinsip kedokteran olahraga & data riil
class RunningCoachService {
  /// Menghitung 5 zona detak jantung lari berdasarkan usia
  PersonalRunningZones calculateRunningZones(int userAge) {
    return PersonalRunningZones.fromAge(userAge);
  }

  /// Menghitung akumulasi dan statistik lari dalam minggu kalender berjalan (Senin - Minggu)
  WeeklyRunningSummary calculateWeeklySummary(
    HealthDataSummary summary, {
    int targetRuns = 4,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    // Tentukan hari Senin awal minggu ini (00:00:00)
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    // Filter sesi olahraga yang termasuk kategori lari/jogging
    final runningRecords = summary.exerciseRecords.where((e) {
      final name = e.activityName.toLowerCase();
      final isRunning = name.contains('run') ||
          name.contains('lari') ||
          name.contains('jog') ||
          name.contains('treadmill');
      return isRunning;
    }).toList();

    // Sesi lari minggu ini
    final runsThisWeek = runningRecords
        .where((e) => !e.startTime.isBefore(monday) && !e.startTime.isAfter(now))
        .toList();

    double totalKm = 0.0;
    Duration totalDuration = Duration.zero;
    double totalCalories = 0.0;

    for (final r in runsThisWeek) {
      totalKm += (r.distanceMeters ?? 0.0) / 1000.0;
      totalDuration += r.duration;
      totalCalories += (r.caloriesBurned ?? 0.0);
    }

    // Deteksi potensi overtraining (misal lari 3 hari berturut-turut tanpa jeda)
    String? overtrainingWarning;
    if (runsThisWeek.length >= 3) {
      // Periksa apakah ada 3 hari berurutan
      final days = runsThisWeek
          .map((r) => DateTime(r.startTime.year, r.startTime.month, r.startTime.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (days.length >= 3) {
        final diff1 = days[0].difference(days[1]).inDays;
        final diff2 = days[1].difference(days[2]).inDays;
        if (diff1 == 1 && diff2 == 1) {
          overtrainingWarning =
              'Anda telah berlari 3 hari berturut-turut tanpa hari istirahat. Disarankan mengambil Rest Day untuk memberi waktu regenerasi serat otot & persendian kaki.';
        }
      }
    }

    return WeeklyRunningSummary(
      targetRunsPerWeek: targetRuns,
      completedRunsThisWeek: runsThisWeek.length,
      totalWeeklyDistanceKm: totalKm,
      totalWeeklyDuration: totalDuration,
      totalCaloriesBurned: totalCalories,
      recentRuns: runningRecords,
      overtrainingWarning: overtrainingWarning,
    );
  }

  /// Menghasilkan rekomendasi latihan lari harian berdasarkan data riil
  RunningWorkoutRecommendation recommendTodayWorkout({
    required HealthInsight insight,
    required HealthDataSummary summary,
    int userAge = 30,
    int targetRuns = 4,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final zones = calculateRunningZones(userAge);
    final weekly = calculateWeeklySummary(
      summary,
      targetRuns: targetRuns,
      referenceDate: currentTime,
    );

    // Cek apakah sudah ada sesi lari yang tercatat hari ini
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final ranToday = weekly.recentRuns.any((r) {
      final runDay = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      return runDay.isAtSameMomentAs(today);
    });

    if (ranToday) {
      return RunningWorkoutRecommendation(
        workoutType: RunningWorkoutType.restDay,
        title: 'Pemulihan Pasca Lari Hari Ini',
        targetDurationMinutes: 0,
        targetZoneLabel: 'Zona Istirahat (< ${zones.zone1.minBpm} BPM)',
        rationale:
            'Anda sudah menyelesaikan sesi lari hari ini. Tubuh membutuhkan waktu 24-48 jam untuk sintesis protein otot dan pemulihan simpanan glikogen.',
        pacingTips:
            'Fokus pada peregangan statis (hamstring, quadriceps, calf), mandi air hangat, dan konsumsi protein berkualitas.',
        warmupCooldown: 'Peregangan statis 10-15 menit dan hidrasi elektrolit.',
        checklist: const [
          'Minum 500 ml air putih / elektrolit untuk rehidrasi.',
          'Lakukan foam rolling atau peregangan otot betis dan paha.',
          'Cukupi asupan protein (20-25 gram) dalam 2 jam pasca lari.',
        ],
      );
    }

    // Evaluasi Skor Pemulihan Tubuh (Recovery Score)
    final score = insight.recoveryScore;
    final hrv = summary.latestHrv?.rmssdMillis;
    final rhr = summary.latestRestingHeartRate?.bpm;
    final sleepDurationMin = insight.sleepAnalysis.effectiveDuration.inMinutes;

    // Kondisi 1: Tubuh sangat lelah / Skor < 45 / Tidur < 5 jam
    if (score < 45 || (sleepDurationMin > 0 && sleepDurationMin < 300)) {
      return RunningWorkoutRecommendation(
        workoutType: RunningWorkoutType.restDay,
        title: 'Hari Istirahat Penuh (Rest Day)',
        targetDurationMinutes: 0,
        targetZoneLabel: 'Zona Istirahat Total',
        rationale:
            'Skor pemulihan rendah ($score/100)${sleepDurationMin > 0 ? " dan tidur efektif hanya ${(sleepDurationMin / 60).toStringAsFixed(1)} jam" : ""}. '
            'Berlari saat tubuh lelah meningkatkan risiko cedera lutut (runner\'s knee) dan overtraining.',
        pacingTips: 'Beri jeda bagi sistem kardiovaskular dan sendi kaki untuk beregenerasi.',
        warmupCooldown: 'Latihan mobilitas ringan atau jalan santai 10 menit jika ingin bergerak.',
        checklist: const [
          'Prioritaskan tidur lebih awal malam ini (+45 menit).',
          'Hindari kafein berlebih di sore hari.',
          'Lakukan peregangan ringan jika otot terasa kaku.',
        ],
      );
    }

    // Kondisi 2: Peringatan Overtraining (Lari beruntun)
    if (weekly.overtrainingWarning != null && score < 75) {
      return RunningWorkoutRecommendation(
        workoutType: RunningWorkoutType.recoveryRun,
        title: 'Recovery Jog Santai / Jalan Aktif',
        targetDurationMinutes: 20,
        targetDistanceKm: 2.5,
        targetZoneLabel: 'Zona 1 (${zones.zone1.name}) (${zones.zone1.minBpm}-${zones.zone1.maxBpm} BPM)',
        rationale:
            'Tubuh telah menjalani beberapa sesi lari berturut-turut. Lari pemulihan sangat ringan bertujuan melancarkan aliran darah dan membuang sisa asam laktat tanpa menambah beban otot.',
        pacingTips:
            'Kecepatan sangat santai (conversational pace). Anda harus bisa bernyanyi atau bercakap-cakap dengan mudah.',
        warmupCooldown: 'Pemanasan jalan santai 5 menit, pendinginan peregangan betis & paha.',
        checklist: [
          'Jaga denyut jantung tetap di bawah ${zones.zone1.maxBpm} BPM.',
          'Gunakan sepatu lari dengan bantalan empuk (cushioning).',
          'Segera berhenti jika timbul rasa nyeri pada sendi atau tulang kering.',
        ],
      );
    }

    // Kondisi 3: Skor Prima (>= 80) & HRV Bagus -> Kesempatan Latihan Berkualitas
    if (score >= 80 && (hrv == null || hrv >= 40)) {
      // Jika baru lari 1-2x minggu ini, cocok untuk sesi kualitas (Tempo Run)
      if (weekly.completedRunsThisWeek >= 1 && weekly.completedRunsThisWeek < targetRuns) {
        return RunningWorkoutRecommendation(
          workoutType: RunningWorkoutType.tempoRun,
          title: 'Tempo / Threshold Run (Zona 3-4)',
          targetDurationMinutes: 40,
          targetDistanceKm: 5.5,
          targetZoneLabel: 'Zona 3 (${zones.zone3.name}) (${zones.zone3.minBpm}-${zones.zone3.maxBpm} BPM)',
          rationale:
              'Kondisi kardiovaskular dan pemulihan prima (Skor: $score/100, denyut rata-rata stabil). '
              'Hari ini momen ideal untuk meningkatkan ambang laktat dan kecepatan lari Anda.',
          pacingTips:
              'Pola latihan: 10 menit Easy Run (Zona 2), 20 menit Tempo Terkendali (Zona 3-4, ritme mantap terkontrol), 10 menit Cooldown (Zona 1-2).',
          warmupCooldown: 'Pemanasan dinamis 5 menit + 10 menit Cooldown jalan santai.',
          checklist: const [
            'Lakukan pemanasan dinamis (leg swings, high knees, ankle circles).',
            'Pertahankan ritme stabil selama fase tempo 20 menit.',
            'Jaga postur tegak, pandangan ke depan, dan bahu rileks.',
          ],
        );
      }
    }

    // Kondisi 4: Long Run di Akhir Pekan (Sabtu / Minggu) jika frekuensi sudah 2-3x
    final isWeekend = currentTime.weekday == DateTime.saturday || currentTime.weekday == DateTime.sunday;
    if (isWeekend && score >= 70 && weekly.completedRunsThisWeek >= 2) {
      return RunningWorkoutRecommendation(
        workoutType: RunningWorkoutType.longRun,
        title: 'Weekend Long Run (Zona 2 Endurance)',
        targetDurationMinutes: 55,
        targetDistanceKm: 7.5,
        targetZoneLabel: 'Zona 2 (${zones.zone2.name}) (${zones.zone2.minBpm}-${zones.zone2.maxBpm} BPM)',
        rationale:
            'Kesiapan fisik baik ($score/100). Akhir pekan cocok untuk lari berdurasi panjang dengan ritme santai Zona 2 guna membangun kapasitas aerobik jangka panjang.',
        pacingTips:
            'Jaga intensitas santai (bisa mengobrol nyaman). Hindari memulai terlalu cepat di kilometer awal.',
        warmupCooldown: 'Pemanasan dinamis 5 menit, pendinginan & rehidrasi lengkap 10 menit.',
        checklist: const [
          'Bawa botol air minum jika rute lari lebih dari 45 menit.',
          'Pilih rute yang datar dan permukaan yang ramah lutut.',
          'Konsumsi karbohidrat ringan (pisang / kurma) 30 menit sebelum mulai.',
        ],
      );
    }

    // Default: Easy Base Run (Zona 2) - Fondasi Utama Pelari 3-4x Seminggu
    return RunningWorkoutRecommendation(
      workoutType: RunningWorkoutType.easyRun,
      title: 'Easy Base Run (Zona 2 Aerobik)',
      targetDurationMinutes: 35,
      targetDistanceKm: 4.5,
      targetZoneLabel: 'Zona 2 (${zones.zone2.name}) (${zones.zone2.minBpm}-${zones.zone2.maxBpm} BPM)',
      rationale:
          'Kondisi tubuh stabil (Skor: $score/100${rhr != null ? ", RHR: $rhr BPM" : ""}). '
          'Lari santai Zona 2 adalah kunci utama (80% porsi latihan) untuk memperkuat dinding kapiler jantung dan efisiensi paru-paru.',
      pacingTips:
          'Lari dengan ritme santai di mana Anda masih bisa bernapas melalui hidung atau berbicara satu kalimat penuh tanpa terengah-engah.',
      warmupCooldown: 'Pemanasan 5 menit (jalan cepat & ankle rolls), pendinginan jalan 5 menit.',
      checklist: [
        'Pertahankan denyut nadi di kisaran ${zones.zone2.minBpm}-${zones.zone2.maxBpm} BPM.',
        'Jaga irama langkah (cadence) stabil di sekitar 165-175 langkah per menit.',
        'Minum air putih secukupnya sebelum dan sesudah lari.',
      ],
    );
  }
}
