import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/widgets/heart_rate_card.dart';
import '../../health_connect/presentation/widgets/sleep_card.dart';
import '../../health_connect/presentation/widgets/steps_card.dart';

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
              'Riwayat Aktivitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Catatan Sampel & Log Pengukuran',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.normal,
              ),
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
            StepsCard(
              totalSteps: healthState.summary.totalStepsToday,
              stepRecords: healthState.summary.stepRecords,
              lastFetched: healthState.summary.lastFetched,
            ),
            HeartRateCard(
              latestRecord: healthState.summary.latestHeartRate,
              history: healthState.summary.heartRateHistory,
            ),
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
