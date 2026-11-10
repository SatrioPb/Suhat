import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../presentation/controllers/analytics_controller.dart';
import '../presentation/widgets/heart_rate_analysis_card.dart';
import '../presentation/widgets/recovery_score_card.dart';
import '../presentation/widgets/sleep_analysis_card.dart';
import '../presentation/widgets/vitals_biometrics_card.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthInsight = ref.watch(healthInsightProvider);
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
              'Analisis Kesehatan',
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
              'Kesiapan fisik, denyut jantung, dan tidur',
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
            tooltip: 'Perbarui analisis',
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
                  title: 'Menganalisis data...',
                  message:
                      'Memproses rekaman detak jantung dan tahapan tidur dari Health Connect.',
                  showProgress: true,
                ),

              if (healthState.errorMessage != null)
                EditorialStateNotice(
                  icon: Icons.error_outline,
                  color: c.statusAlert,
                  title: 'Analisis tidak dapat diperbarui',
                  message: healthState.errorMessage!,
                  actionLabel: 'Coba Lagi',
                  onAction: () => controller.fetchHealthData(),
                ),

              // 1. Focal Sheet: Kesiapan & Pemulihan Fisik
              RecoveryScoreCard(insight: healthInsight),

              const SizedBox(height: 16),

              // 2. Open Canvas: Analisis Detak Jantung
              HeartRateAnalysisCard(analysis: healthInsight.heartRateAnalysis),

              const SizedBox(height: 16),

              // 3. Recessed Strip: Analisis Kualitas Tidur
              SleepAnalysisCard(analysis: healthInsight.sleepAnalysis),

              const SizedBox(height: 16),

              // 4. Flat Editorial Ledger: Tanda Vital & Biometrik
              VitalsBiometricsCard(summary: healthState.summary),
            ],
          ),
        ),
      ),
    );
  }
}
