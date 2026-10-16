/// Representasi sampel interval langkah
class StepSample {
  final int count;
  final DateTime startTime;
  final DateTime endTime;
  final String source;
  final String? deviceId;

  const StepSample({
    required this.count,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.deviceId,
  });

  Duration get duration => endTime.difference(startTime);

  @override
  String toString() =>
      'StepSample(count: $count, from: $startTime, to: $endTime, source: $source)';
}

/// Representasi agregat data langkah untuk satu hari kalender
class DailyStepData {
  final DateTime date;
  final int totalSteps;
  final int goalSteps;
  final List<StepSample> samples;

  const DailyStepData({
    required this.date,
    required this.totalSteps,
    required this.goalSteps,
    this.samples = const [],
  });

  /// Persentase pencapaian target harian (0.0 - 1.0+)
  double get progress => goalSteps > 0 ? (totalSteps / goalSteps) : 0.0;

  /// Apakah target langkah harian telah tercapai
  bool get isGoalReached => totalSteps >= goalSteps;

  DailyStepData copyWith({
    DateTime? date,
    int? totalSteps,
    int? goalSteps,
    List<StepSample>? samples,
  }) {
    return DailyStepData(
      date: date ?? this.date,
      totalSteps: totalSteps ?? this.totalSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      samples: samples ?? this.samples,
    );
  }
}
