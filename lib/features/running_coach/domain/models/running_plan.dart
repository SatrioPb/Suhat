import 'package:flutter/material.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/features/health_connect/domain/models/health_models.dart';

/// Jenis latihan lari terstruktur
enum RunningWorkoutType {
  restDay,
  recoveryRun,
  easyRun,
  tempoRun,
  intervalRun,
  longRun;

  String get label {
    switch (this) {
      case RunningWorkoutType.restDay:
        return 'Hari Istirahat (Rest Day)';
      case RunningWorkoutType.recoveryRun:
        return 'Recovery Jog (Zona 1)';
      case RunningWorkoutType.easyRun:
        return 'Easy Base Run (Zona 2)';
      case RunningWorkoutType.tempoRun:
        return 'Tempo / Threshold Run (Zona 3-4)';
      case RunningWorkoutType.intervalRun:
        return 'Interval / Speed Run (Zona 4-5)';
      case RunningWorkoutType.longRun:
        return 'Long Run (Zona 2 Endurance)';
    }
  }

  String get shortLabel {
    switch (this) {
      case RunningWorkoutType.restDay:
        return 'Rest Day';
      case RunningWorkoutType.recoveryRun:
        return 'Recovery';
      case RunningWorkoutType.easyRun:
        return 'Easy Run';
      case RunningWorkoutType.tempoRun:
        return 'Tempo Run';
      case RunningWorkoutType.intervalRun:
        return 'Interval Run';
      case RunningWorkoutType.longRun:
        return 'Long Run';
    }
  }

  Color get color {
    switch (this) {
      case RunningWorkoutType.restDay:
        return AppTheme.accentIndigo;
      case RunningWorkoutType.recoveryRun:
        return AppTheme.primaryTeal;
      case RunningWorkoutType.easyRun:
        return AppTheme.accentGreen;
      case RunningWorkoutType.tempoRun:
        return AppTheme.accentAmber;
      case RunningWorkoutType.intervalRun:
        return AppTheme.accentRed;
      case RunningWorkoutType.longRun:
        return Colors.deepOrange;
    }
  }

  IconData get icon {
    switch (this) {
      case RunningWorkoutType.restDay:
        return Icons.hotel;
      case RunningWorkoutType.recoveryRun:
        return Icons.directions_walk;
      case RunningWorkoutType.easyRun:
        return Icons.directions_run;
      case RunningWorkoutType.tempoRun:
        return Icons.speed;
      case RunningWorkoutType.intervalRun:
        return Icons.bolt;
      case RunningWorkoutType.longRun:
        return Icons.map;
    }
  }
}

/// Rentang zona detak jantung khusus lari
class HeartRateZoneRange {
  final int zoneNumber;
  final String name;
  final int minBpm;
  final int maxBpm;
  final String description;
  final Color color;

  const HeartRateZoneRange({
    required this.zoneNumber,
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    required this.description,
    required this.color,
  });
}

/// 5 Zona denyut jantung lari pribadi berdasarkan metode Karvonen (Heart Rate Reserve - HRR)
/// Formula: Target HR = (MHR - RHR) * %HRR + RHR
class PersonalRunningZones {
  final int maxHeartRate;
  final int restingHeartRate;
  final int heartRateReserve;
  final HeartRateZoneRange zone1; // 50% - 60% HRR + RHR
  final HeartRateZoneRange zone2; // 60% - 70% HRR + RHR
  final HeartRateZoneRange zone3; // 70% - 80% HRR + RHR
  final HeartRateZoneRange zone4; // 80% - 90% HRR + RHR
  final HeartRateZoneRange zone5; // 90% - 100% HRR + RHR

  const PersonalRunningZones({
    required this.maxHeartRate,
    required this.restingHeartRate,
    required this.heartRateReserve,
    required this.zone1,
    required this.zone2,
    required this.zone3,
    required this.zone4,
    required this.zone5,
  });

  /// Menghitung zona lari menggunakan formula Karvonen (Heart Rate Reserve)
  /// Target HR = (MHR - RHR) * %HRR + RHR
  factory PersonalRunningZones.fromKarvonen({
    required int age,
    int? restingHeartRate,
    int? maxHeartRate,
  }) {
    final mhr = maxHeartRate ?? (220 - age);
    final rhr = (restingHeartRate != null && restingHeartRate > 35 && restingHeartRate < 120)
        ? restingHeartRate
        : 60;
    final hrr = (mhr - rhr).clamp(30, 180);

    // Hitung batas denyut nadi untuk masing-masing zona sesuai persentase HRR
    final z1Min = (hrr * 0.50).round() + rhr;
    final z1Max = (hrr * 0.60).round() + rhr - 1;

    final z2Min = (hrr * 0.60).round() + rhr;
    final z2Max = (hrr * 0.70).round() + rhr - 1;

    final z3Min = (hrr * 0.70).round() + rhr;
    final z3Max = (hrr * 0.80).round() + rhr - 1;

    final z4Min = (hrr * 0.80).round() + rhr;
    final z4Max = (hrr * 0.90).round() + rhr - 1;

    final z5Min = (hrr * 0.90).round() + rhr;
    final z5Max = mhr;

    return PersonalRunningZones(
      maxHeartRate: mhr,
      restingHeartRate: rhr,
      heartRateReserve: hrr,
      zone1: HeartRateZoneRange(
        zoneNumber: 1,
        name: 'Active Recovery',
        minBpm: z1Min,
        maxBpm: z1Max,
        description: '50-60% HRR: Pemulihan aktif, pemanasan, sangat santai.',
        color: AppTheme.primaryTeal,
      ),
      zone2: HeartRateZoneRange(
        zoneNumber: 2,
        name: 'Aerobic Base (Easy Run)',
        minBpm: z2Min,
        maxBpm: z2Max,
        description: '60-70% HRR: Membangun fondasi daya tahan & efisiensi mitokondria. Kunci 80% porsi lari.',
        color: AppTheme.accentGreen,
      ),
      zone3: HeartRateZoneRange(
        zoneNumber: 3,
        name: 'Aerobic Endurance (Tempo)',
        minBpm: z3Min,
        maxBpm: z3Max,
        description: '70-80% HRR: Meningkatkan ritme kardiovaskular dan stamina maraton.',
        color: AppTheme.accentAmber,
      ),
      zone4: HeartRateZoneRange(
        zoneNumber: 4,
        name: 'Threshold (Ambang Laktat)',
        minBpm: z4Min,
        maxBpm: z4Max,
        description: '80-90% HRR: Meningkatkan ambang toleransi asam laktat dan kecepatan.',
        color: Colors.deepOrange,
      ),
      zone5: HeartRateZoneRange(
        zoneNumber: 5,
        name: 'Max Effort (Sprint / Anaerobik)',
        minBpm: z5Min,
        maxBpm: z5Max,
        description: '90-100% HRR: Daya ledak & kapasitas VO2 max maksimal, repetisi singkat.',
        color: AppTheme.accentRed,
      ),
    );
  }

  factory PersonalRunningZones.fromAge(int age, {int? restingHeartRate}) {
    return PersonalRunningZones.fromKarvonen(
      age: age,
      restingHeartRate: restingHeartRate,
    );
  }

  List<HeartRateZoneRange> get allZones => [zone1, zone2, zone3, zone4, zone5];
}

/// Rekomendasi latihan lari harian yang dipersonalisasi
class RunningWorkoutRecommendation {
  final RunningWorkoutType workoutType;
  final String title;
  final int targetDurationMinutes;
  final double? targetDistanceKm;
  final String targetZoneLabel;
  final String rationale;
  final String pacingTips;
  final String warmupCooldown;
  final List<String> checklist;

  const RunningWorkoutRecommendation({
    required this.workoutType,
    required this.title,
    required this.targetDurationMinutes,
    this.targetDistanceKm,
    required this.targetZoneLabel,
    required this.rationale,
    required this.pacingTips,
    required this.warmupCooldown,
    this.checklist = const [],
  });
}

/// Ringkasan progres lari mingguan pengguna
class WeeklyRunningSummary {
  final int targetRunsPerWeek;
  final int completedRunsThisWeek;
  final double totalWeeklyDistanceKm;
  final Duration totalWeeklyDuration;
  final double totalCaloriesBurned;
  final List<ExerciseRecord> recentRuns;
  final String? overtrainingWarning;

  const WeeklyRunningSummary({
    this.targetRunsPerWeek = 4,
    this.completedRunsThisWeek = 0,
    this.totalWeeklyDistanceKm = 0.0,
    this.totalWeeklyDuration = Duration.zero,
    this.totalCaloriesBurned = 0.0,
    this.recentRuns = const [],
    this.overtrainingWarning,
  });

  double get weeklyProgressPercent =>
      targetRunsPerWeek > 0 ? (completedRunsThisWeek / targetRunsPerWeek).clamp(0.0, 1.0) : 0.0;
}

/// State lengkap untuk fitur Running Coach
class RunningCoachState {
  final RunningWorkoutRecommendation recommendation;
  final WeeklyRunningSummary weeklySummary;
  final PersonalRunningZones zones;
  final bool isLoading;

  const RunningCoachState({
    required this.recommendation,
    required this.weeklySummary,
    required this.zones,
    this.isLoading = false,
  });
}
