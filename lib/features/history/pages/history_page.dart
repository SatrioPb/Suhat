import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/widgets/heart_rate_card.dart';
import '../../health_connect/presentation/widgets/sleep_card.dart';
import '../../health_connect/presentation/widgets/steps_card.dart';
import '../presentation/widgets/activity_metrics_card.dart';
import '../presentation/widgets/biometrics_history_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Aktivitas & Vitalitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Log Pengukuran & Rekaman Riil Lengkap',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan data',
            onPressed: healthState.isLoading ? null : () => controller.fetchHealthData(),
            icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () => controller.fetchHealthData(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            // 1. Log Langkah & Segmen
            StepsCard(
              totalSteps: healthState.summary.totalStepsToday,
              stepRecords: healthState.summary.stepRecords,
              lastFetched: healthState.summary.lastFetched,
            ),

            // 2. Kalori Aktif, Total Kalori, Jarak, Elevasi & Sesi Olahraga
            ActivityMetricsCard(
              summary: healthState.summary,
            ),

            // 3. Log Detak Jantung Riil
            HeartRateCard(
              latestRecord: healthState.summary.latestHeartRate,
              history: healthState.summary.heartRateHistory,
            ),

            // 4. Log Tanda Vital (RHR, HRV, SpO2) & Biometrik (Berat, Tinggi, BMI)
            BiometricsHistoryCard(
              summary: healthState.summary,
            ),

            // 5. Log Sesi Tidur & Tahapan
            SleepCard(
              latestSleep: healthState.summary.latestSleep,
              sleepHistory: healthState.summary.sleepHistory,
            ),
          ],
        ),
      ),
    );
  }
}
