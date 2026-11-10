import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhat/core/theme/app_theme.dart';
import 'package:suhat/core/widgets/editorial_ui.dart';
import 'package:suhat/features/health_connect/presentation/controllers/health_controller.dart';
import 'package:suhat/features/running_coach/presentation/controllers/running_coach_controller.dart';
import 'package:suhat/features/running_coach/presentation/widgets/overtraining_safety_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/running_zones_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/today_workout_card.dart';
import 'package:suhat/features/running_coach/presentation/widgets/weekly_running_progress_card.dart';
import 'package:suhat/features/weather_aqi/presentation/widgets/outdoor_weather_aqi_card.dart';

class RunningCoachPage extends ConsumerWidget {
  const RunningCoachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(runningCoachStateProvider);
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);
    final c = context.suhatColors;
    final hasNeverFetched = healthState.summary.lastFetched ==
        DateTime.fromMillisecondsSinceEpoch(0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelatih Lari',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: c.inkPrimary,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Rekomendasi latihan berbasis data fisik & zona Karvonen',
              style: TextStyle(
                fontSize: 11,
                color: c.inkSecondary,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan data latihan',
            onPressed:
                healthState.isLoading ? null : () => controller.fetchHealthData(),
            icon: healthState.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.accentPine,
                    ),
                  )
                : Icon(Icons.refresh, color: c.accentPine),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: c.accentPine,
          onRefresh: () => controller.fetchHealthData(),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 36),
            children: [
              if (healthState.isLoading && hasNeverFetched)
                EditorialStateNotice(
                  icon: Icons.sync,
                  color: c.accentPine,
                  title: 'Menyiapkan rencana lari...',
                  message:
                      'Membaca histori lari dan kesiapan fisik dari Health Connect.',
                  showProgress: true,
                ),

              if (healthState.errorMessage != null)
                EditorialStateNotice(
                  icon: Icons.error_outline,
                  color: c.statusAlert,
                  title: 'Data latihan tidak dapat diperbarui',
                  message: healthState.errorMessage!,
                  actionLabel: 'Coba Lagi',
                  onAction: () => controller.fetchHealthData(),
                ),

              // 1. Focal Sheet: Rekomendasi Latihan Lari Hari Ini
              TodayWorkoutCard(recommendation: coachState.recommendation),

              const SizedBox(height: 14),

              // 2. Recessed Strip: Kondisi Cuaca & Kualitas Udara (AQI)
              const OutdoorWeatherAqiCard(),

              const SizedBox(height: 20),

              // 3. Open Canvas Tracker: Target Lari Mingguan
              WeeklyRunningProgressCard(summary: coachState.weeklySummary),

              const SizedBox(height: 20),

              // 4. Ledger Table: 5 Zona Detak Jantung Lari (Karvonen HRR)
              RunningZonesCard(zones: coachState.zones),

              const SizedBox(height: 20),

              // 5. Editorial Notes: Pencegahan Cedera & Overtraining
              const OvertrainingSafetyCard(),
            ],
          ),
        ),
      ),
    );
  }
}
