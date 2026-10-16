import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/data/models/heart_rate_sample.dart';
import 'package:suhat/data/models/sleep_session.dart';
import 'package:suhat/features/analytics/domain/models/heart_rate_analysis.dart';
import 'package:suhat/features/analytics/domain/models/health_insight.dart';
import 'package:suhat/features/analytics/domain/models/sleep_analysis.dart';
import 'package:suhat/features/analytics/domain/services/health_analyzer_service.dart';

void main() {
  group('HealthAnalyzerService Tests', () {
    late HealthAnalyzerService analyzer;

    setUp(() {
      analyzer = HealthAnalyzerService();
    });

    test('analyzeHeartRate handles empty data correctly', () {
      const emptySummary = HeartRateSummary();
      final result = analyzer.analyzeHeartRate(emptySummary);

      expect(result.status, HeartRateStatus.insufficientData);
      expect(result.hasData, isFalse);
    });

    test('analyzeHeartRate calculates normal resting heart rate and zones', () {
      final now = DateTime(2026, 10, 16, 10, 0);
      final summary = HeartRateSummary(
        latest: HeartRateSample(
          bpm: 72,
          timestamp: now,
          source: 'Google Health Connect',
        ),
        minBpm: 65,
        maxBpm: 120,
        avgBpm: 75,
        history: [
          HeartRateSample(bpm: 70, timestamp: now.subtract(const Duration(hours: 3)), source: 'Health Connect'),
          HeartRateSample(bpm: 80, timestamp: now.subtract(const Duration(hours: 2)), source: 'Health Connect'),
          HeartRateSample(bpm: 110, timestamp: now.subtract(const Duration(hours: 1)), source: 'Health Connect'),
          HeartRateSample(bpm: 72, timestamp: now, source: 'Health Connect'),
        ],
      );

      final analysis = analyzer.analyzeHeartRate(summary, userAge: 30);

      expect(analysis.hasData, isTrue);
      expect(analysis.status, HeartRateStatus.normal);
      expect(analysis.avgBpm, 75);
      expect(analysis.zones.totalSamples, 4);
      expect(analysis.zones.restingCount, greaterThan(0));
    });

    test('analyzeHeartRate detects elevated and tachycardia HR', () {
      final now = DateTime.now();
      final highSummary = HeartRateSummary(
        latest: HeartRateSample(bpm: 108, timestamp: now, source: 'Health Connect'),
        avgBpm: 105,
        minBpm: 102,
        maxBpm: 112,
        history: [
          HeartRateSample(bpm: 108, timestamp: now, source: 'Health Connect'),
        ],
      );

      final analysis = analyzer.analyzeHeartRate(highSummary);
      expect(analysis.status, HeartRateStatus.tachycardia);
    });

    test('analyzeSleep evaluates optimal duration and stage percentages', () {
      final start = DateTime(2026, 10, 15, 23, 0);
      final end = DateTime(2026, 10, 16, 7, 0); // 480 mins

      final session = SleepSession(
        startTime: start,
        endTime: end,
        source: 'Google Health Connect',
        stages: [
          SleepStageItem(
            stage: SleepStage.deep,
            startTime: start.add(const Duration(minutes: 30)),
            endTime: start.add(const Duration(minutes: 150)), // 120 mins (25%)
          ),
          SleepStageItem(
            stage: SleepStage.rem,
            startTime: start.add(const Duration(minutes: 150)),
            endTime: start.add(const Duration(minutes: 246)), // 96 mins (20%)
          ),
          SleepStageItem(
            stage: SleepStage.light,
            startTime: start.add(const Duration(minutes: 246)),
            endTime: end, // 234 mins
          ),
        ],
      );

      final analysis = analyzer.analyzeSleep(session);

      expect(analysis.hasData, isTrue);
      expect(analysis.durationCategory, SleepDurationCategory.optimal);
      expect(analysis.efficiencyCategory, SleepEfficiencyCategory.good);
      expect(analysis.deepSleepPercent, closeTo(25.0, 1.0));
      expect(analysis.remSleepPercent, closeTo(20.0, 1.0));
    });

    test('analyzeSleep detects short sleep under 6 hours', () {
      final start = DateTime(2026, 10, 16, 1, 0);
      final end = DateTime(2026, 10, 16, 5, 30); // 4.5 hours (270 mins)

      final session = SleepSession(
        startTime: start,
        endTime: end,
        source: 'Google Health Connect',
      );

      final analysis = analyzer.analyzeSleep(session);

      expect(analysis.durationCategory, SleepDurationCategory.short);
    });

    test('generateInsight combines metrics to yield optimal recovery score', () {
      const hrAnalysis = HeartRateAnalysis(
        latestBpm: 68,
        minBpm: 60,
        maxBpm: 90,
        avgBpm: 70,
        status: HeartRateStatus.normal,
        statusDescription: 'Normal',
        sampleCount: 10,
      );

      const sleepAnalysis = SleepAnalysis(
        totalDuration: Duration(hours: 8),
        effectiveDuration: Duration(hours: 7, minutes: 40),
        efficiencyPercentage: 95.0,
        durationCategory: SleepDurationCategory.optimal,
        efficiencyCategory: SleepEfficiencyCategory.good,
        deepSleepPercent: 20.0,
        remSleepPercent: 22.0,
        summaryDescription: 'Sleep well',
        hasStages: true,
        hasData: true,
      );

      final insight = analyzer.generateInsight(
        hrAnalysis: hrAnalysis,
        sleepAnalysis: sleepAnalysis,
      );

      expect(insight.recoveryScore, greaterThanOrEqualTo(80));
      expect(insight.level, RecoveryLevel.optimal);
      expect(insight.actionableAdvice.isNotEmpty, isTrue);
      expect(insight.medicalDisclaimer, contains('bukan merupakan diagnosis medis'));
    });

    test('generateInsight handles poor sleep and elevated HR safely', () {
      const hrAnalysis = HeartRateAnalysis(
        latestBpm: 102,
        minBpm: 95,
        maxBpm: 110,
        avgBpm: 98,
        status: HeartRateStatus.elevated,
        statusDescription: 'Elevated HR',
        sampleCount: 5,
      );

      const sleepAnalysis = SleepAnalysis(
        totalDuration: Duration(hours: 5),
        effectiveDuration: Duration(hours: 4),
        efficiencyPercentage: 80.0,
        durationCategory: SleepDurationCategory.short,
        efficiencyCategory: SleepEfficiencyCategory.fair,
        summaryDescription: 'Short sleep',
        hasData: true,
      );

      final insight = analyzer.generateInsight(
        hrAnalysis: hrAnalysis,
        sleepAnalysis: sleepAnalysis,
      );

      expect(insight.recoveryScore, lessThan(65));
      expect(insight.level, isNot(RecoveryLevel.optimal));
      expect(insight.actionableAdvice.any((a) => a.contains('istirahat') || a.contains('tidur')), isTrue);
    });
  });
}
