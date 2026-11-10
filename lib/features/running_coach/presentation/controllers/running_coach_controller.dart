import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/app/providers.dart';
import 'package:suhat/core/constants/app_constants.dart';
import 'package:suhat/data/local/preferences_service.dart';
import 'package:suhat/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/running_coach/domain/models/running_plan.dart';
import 'package:suhat/features/running_coach/domain/services/running_coach_service.dart';

final runningCoachServiceProvider = Provider<RunningCoachService>((ref) {
  return RunningCoachService();
});

class WeeklyTargetRunsNotifier extends StateNotifier<int> {
  final PreferencesService _prefs;
  WeeklyTargetRunsNotifier(this._prefs)
      : super(_prefs.getWeeklyRunTarget());

  Future<void> setTarget(int runs) async {
    final clamped = runs.clamp(1, 7);
    state = clamped;
    await _prefs.setWeeklyRunTarget(clamped);
  }
}

final runningWeeklyTargetRunsProvider =
    StateNotifierProvider<WeeklyTargetRunsNotifier, int>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return WeeklyTargetRunsNotifier(prefs);
});

class RunnerAgeNotifier extends StateNotifier<int> {
  final PreferencesService _prefs;
  RunnerAgeNotifier(this._prefs) : super(_prefs.getRunnerAge());

  Future<void> setAge(int age) async {
    final clamped = age.clamp(14, 90);
    state = clamped;
    await _prefs.setRunnerAge(clamped);
  }
}

final runnerAgeProvider = StateNotifierProvider<RunnerAgeNotifier, int>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return RunnerAgeNotifier(prefs);
});

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
    runnerAge > 0 ? runnerAge : AppConstants.defaultRunnerAge,
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
