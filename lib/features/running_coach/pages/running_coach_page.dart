import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/running_coach/presentation/controllers/running_coach_controller.dart';
import 'package:suhat/features/running_coach/presentation/widgets/overtraining_safety_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/running_zones_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/today_workout_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/weekly_running_progress_card.dart';

class RunningCoachPage extends ConsumerWidget {
  const RunningCoachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(runningCoachStateProvider);
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelatih Lari Cerdas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Rekomendasi Latihan Berdasarkan Data Kesehatan',
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
            // 1. Rekomendasi Latihan Lari Hari Ini
            TodayWorkoutCard(recommendation: coachState.recommendation),

            // 2. Pelacak Target Lari Mingguan (3-4x seminggu)
            WeeklyRunningProgressCard(summary: coachState.weeklySummary),

            // 3. Panduan 5 Zona Detak Jantung Lari Pribadi
            RunningZonesCard(zones: coachState.zones),

            // 4. Panduan Keselamatan & Pencegahan Cedera
            const OvertrainingSafetyCard(),
          ],
        ),
      ),
    );
  }
}
