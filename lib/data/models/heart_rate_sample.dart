/// Model sampel data detak jantung (denyut nadi)
class HeartRateSample {
  final int bpm;
  final DateTime timestamp;
  final String source;
  final String? deviceId;

  const HeartRateSample({
    required this.bpm,
    required this.timestamp,
    required this.source,
    this.deviceId,
  });

  @override
  String toString() =>
      'HeartRateSample(bpm: $bpm, timestamp: $timestamp, source: $source)';
}

/// Ringkasan statistik detak jantung dalam periode tertentu
class HeartRateSummary {
  final HeartRateSample? latest;
  final int minBpm;
  final int maxBpm;
  final int avgBpm;
  final List<HeartRateSample> history;

  const HeartRateSummary({
    this.latest,
    this.minBpm = 0,
    this.maxBpm = 0,
    this.avgBpm = 0,
    this.history = const [],
  });

  factory HeartRateSummary.fromSamples(List<HeartRateSample> samples) {
    if (samples.isEmpty) {
      return const HeartRateSummary();
    }

    final sorted = List<HeartRateSample>.from(samples)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final bpms = sorted.map((e) => e.bpm).toList();
    final min = bpms.reduce((curr, next) => curr < next ? curr : next);
    final max = bpms.reduce((curr, next) => curr > next ? curr : next);
    final avg = (bpms.reduce((a, b) => a + b) / bpms.length).round();

    return HeartRateSummary(
      latest: sorted.first,
      minBpm: min,
      maxBpm: max,
      avgBpm: avg,
      history: sorted,
    );
  }
}
