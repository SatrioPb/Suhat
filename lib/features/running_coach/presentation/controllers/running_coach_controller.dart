import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/running_coach/domain/services/running_coach_service.dart';

/// Provider singleton untuk RunningCoachService
final runningCoachServiceProvider = Provider<RunningCoachService>((ref) {
  return RunningCoachService();
});

/// Target frekuensi lari per minggu (default: 4x seminggu, rentang ideal pelari 3-4x)
final runningWeeklyTargetRunsProvider = StateProvider<int>((ref) => 4);

/// Estimasi usia pelari untuk kalkulasi Max Heart Rate & zona denyut (default: 30 tahun)
final runnerAgeProvider = StateProvider<int>((ref) => 30);

/// Provider yang otomatis menghasilkan rekomendasi latihan lari dan analitika lari mingguan
final runningCoachStateProvider = Provider<RunningCoachState>((ref) {
  final coachService = ref.watch(runningCoachServiceProvider);
  final healthState = ref.watch(healthControllerProvider);
  final healthInsight = ref.watch(healthInsightProvider);
  final targetRuns = ref.watch(runningWeeklyTargetRunsProvider);
  final runnerAge = ref.watch(runnerAgeProvider);

  final rhr = healthState.summary.latestRestingHeartRate?.bpm ??
      (healthState.summary.heartRateHistory.isNotEmpty
          ? healthState.summary.heartRateHistory
              .map((e) => e.bpm)
              .reduce((a, b) => a < b ? a : b)
          : 60);

  final zones = coachService.calculateRunningZones(
    runnerAge,
    restingHeartRate: rhr,
  );
  final weeklySummary = coachService.calculateWeeklySummary(
    healthState.summary,
    targetRuns: targetRuns,
  );
  final recommendation = coachService.recommendTodayWorkout(
    insight: healthInsight,
    summary: healthState.summary,
    userAge: runnerAge,
    customRestingHeartRate: rhr,
    targetRuns: targetRuns,
  );

  return RunningCoachState(
    recommendation: recommendation,
    weeklySummary: weeklySummary,
    zones: zones,
    isLoading: healthState.isLoading,
  );
});
