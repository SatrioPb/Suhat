import 'heart_rate_sample.dart';
import 'sleep_session.dart';
import 'step_data.dart';

/// Ringkasan keseluruhan data kesehatan yang disajikan untuk dashboard dan modul riwayat
class HealthSummary {
  final DailyStepData todaySteps;
  final HeartRateSummary heartRate;
  final SleepSession? latestSleep;
  final List<SleepSession> sleepHistory;
  final List<DailyStepData> weeklySteps;
  final DateTime lastSyncTime;

  const HealthSummary({
    required this.todaySteps,
    required this.heartRate,
    this.latestSleep,
    this.sleepHistory = const [],
    this.weeklySteps = const [],
    required this.lastSyncTime,
  });

  factory HealthSummary.initial({int stepGoal = 10000}) {
    final now = DateTime.now();
    return HealthSummary(
      todaySteps: DailyStepData(
        date: DateTime(now.year, now.month, now.day),
        totalSteps: 0,
        goalSteps: stepGoal,
      ),
      heartRate: const HeartRateSummary(),
      latestSleep: null,
      sleepHistory: const [],
      weeklySteps: const [],
      lastSyncTime: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  HealthSummary copyWith({
    DailyStepData? todaySteps,
    HeartRateSummary? heartRate,
    SleepSession? latestSleep,
    List<SleepSession>? sleepHistory,
    List<DailyStepData>? weeklySteps,
    DateTime? lastSyncTime,
  }) {
    return HealthSummary(
      todaySteps: todaySteps ?? this.todaySteps,
      heartRate: heartRate ?? this.heartRate,
      latestSleep: latestSleep ?? this.latestSleep,
      sleepHistory: sleepHistory ?? this.sleepHistory,
      weeklySteps: weeklySteps ?? this.weeklySteps,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
