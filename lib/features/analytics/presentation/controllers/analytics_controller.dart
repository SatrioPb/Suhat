import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/heart_rate_sample.dart';
import '../../../../data/models/sleep_session.dart';
import '../../../health_connect/presentation/controllers/health_controller.dart';
import '../../domain/models/health_insight.dart';
import '../../domain/services/health_analyzer_service.dart';

/// Provider singleton HealthAnalyzerService
final healthAnalyzerServiceProvider = Provider<HealthAnalyzerService>((ref) {
  return HealthAnalyzerService();
});

/// Provider yang otomatis menghitung analisis & rekomendasi kesehatan berdasarkan data sinkronisasi terkini
final healthInsightProvider = Provider<HealthInsight>((ref) {
  final healthState = ref.watch(healthControllerProvider);
  final analyzer = ref.watch(healthAnalyzerServiceProvider);

  final summary = healthState.summary;

  // Ubah ke model HeartRateSummary menggunakan data riil
  final hrList = summary.heartRateHistory
      .map((e) => HeartRateSample(
            bpm: e.bpm,
            timestamp: e.timestamp,
            source: e.source,
            deviceId: e.deviceId,
          ))
      .toList();

  // Jika history kosong tapi latestHeartRate ada, sertakan titik data tersebut
  if (hrList.isEmpty && summary.latestHeartRate != null) {
    hrList.add(HeartRateSample(
      bpm: summary.latestHeartRate!.bpm,
      timestamp: summary.latestHeartRate!.timestamp,
      source: summary.latestHeartRate!.source,
      deviceId: summary.latestHeartRate!.deviceId,
    ));
  }

  // fromSamples otomatis menghitung latest, minBpm, maxBpm, dan avgBpm secara akurat dari data riil
  final hrSummary = HeartRateSummary.fromSamples(hrList);

  // Ubah ke model SleepSession
  SleepSession? sleepSession;
  if (summary.latestSleep != null) {
    final ls = summary.latestSleep!;
    sleepSession = SleepSession(
      startTime: ls.startTime,
      endTime: ls.endTime,
      source: ls.source,
      deviceId: ls.deviceId,
      stages: ls.stages
          .map((st) => SleepStageItem(
                stage: _mapStage(st.stage.name),
                startTime: st.startTime,
                endTime: st.endTime,
              ))
          .toList(),
    );
  }

  final hrAnalysis = analyzer.analyzeHeartRate(hrSummary);
  final sleepAnalysis = analyzer.analyzeSleep(sleepSession);

  return analyzer.generateInsight(
    hrAnalysis: hrAnalysis,
    sleepAnalysis: sleepAnalysis,
    todaySteps: summary.totalStepsToday,
    hrvRmssd: summary.latestHrv?.rmssdMillis,
    restingBpm: summary.latestRestingHeartRate?.bpm,
    spO2Percentage: summary.latestOxygenSaturation?.percentage,
  );
});

SleepStage _mapStage(String name) {
  switch (name.toLowerCase()) {
    case 'deep':
      return SleepStage.deep;
    case 'light':
      return SleepStage.light;
    case 'rem':
      return SleepStage.rem;
    case 'awake':
      return SleepStage.awake;
    case 'asleep':
    default:
      return SleepStage.asleep;
  }
}
