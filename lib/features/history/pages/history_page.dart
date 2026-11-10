import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
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
              'Riwayat Aktivitas & Vitalitas',
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
              'Rekaman langkah, kalori, denyut jantung, dan tidur riil',
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
            tooltip: 'Sinkronkan riwayat',
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
                  title: 'Memuat riwayat...',
                  message:
                      'Mengambil log pengukuran terbaru dari Google Health Connect.',
                  showProgress: true,
                ),

              if (healthState.errorMessage != null)
                EditorialStateNotice(
                  icon: Icons.error_outline,
                  color: c.statusAlert,
                  title: 'Gagal memuat riwayat',
                  message: healthState.errorMessage!,
                  actionLabel: 'Coba Lagi',
                  onAction: () => controller.fetchHealthData(),
                ),

              // 1. Focal Sheet: Kalori, Jarak & Olahraga
              ActivityMetricsCard(summary: healthState.summary),

              const SizedBox(height: 18),

              // 2. Open Ledger: Log Langkah
              StepsCard(
                totalSteps: healthState.summary.totalStepsToday,
                stepRecords: healthState.summary.stepRecords,
                lastFetched: healthState.summary.lastFetched,
              ),

              const SizedBox(height: 18),

              // 3. Recessed Band: Tanda Vital & Komposisi Tubuh
              BiometricsHistoryCard(summary: healthState.summary),

              const SizedBox(height: 18),

              // 4. Open Ledger: Log Detak Jantung Riil
              HeartRateCard(
                latestRecord: healthState.summary.latestHeartRate,
                history: healthState.summary.heartRateHistory,
              ),

              const SizedBox(height: 18),

              // 5. Recessed Band: Log Sesi Tidur & Tahapan
              SleepCard(
                latestSleep: healthState.summary.latestSleep,
                sleepHistory: healthState.summary.sleepHistory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
