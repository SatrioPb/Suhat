import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../presentation/controllers/analytics_controller.dart';
import '../presentation/widgets/heart_rate_analysis_card.dart';
import '../presentation/widgets/recovery_score_card.dart';
import '../presentation/widgets/sleep_analysis_card.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthInsight = ref.watch(healthInsightProvider);
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analisis Kesehatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Evaluasi Kesiapan Fisik & Rekomendasi',
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
            tooltip: 'Perbarui analisis',
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
            // 1. Skor Pemulihan Tubuh & Rekomendasi Lengkap
            RecoveryScoreCard(insight: healthInsight),

            // 2. Analisis Detak Jantung Mendalam
            HeartRateAnalysisCard(analysis: healthInsight.heartRateAnalysis),

            // 3. Analisis Kualitas & Tahapan Tidur
            SleepAnalysisCard(analysis: healthInsight.sleepAnalysis),
          ],
        ),
      ),
    );
  }
}
