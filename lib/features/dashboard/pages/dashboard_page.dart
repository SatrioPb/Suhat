import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../analytics/presentation/controllers/analytics_controller.dart';
import '../../health_connect/domain/models/health_models.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/state/health_state.dart';
import '../widgets/compact_recovery_banner.dart';
import '../widgets/metric_dual_grid.dart';
import '../widgets/minimal_step_card.dart';

class DashboardPage extends ConsumerWidget {
  final Function(int tabIndex) onNavigateTab;

  const DashboardPage({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthControllerProvider);
    final healthInsight = ref.watch(healthInsightProvider);
    final controller = ref.read(healthControllerProvider.notifier);

    final now = DateTime.now();
    final dateFormatted = DateFormatter.formatFullDate(now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatted,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
            const Text(
              'Supercalla Health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan data',
            onPressed: healthState.isLoading ? null : () => controller.fetchHealthData(),
            icon: healthState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () => controller.fetchHealthData(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            // Banner Izin jika belum aktif
            if (healthState.permissions != HealthPermissionStatus.granted)
              _buildPermissionReminder(context, healthState, controller),

            // 1. Ringkasan Kesiapan & Pemulihan (Kompak) -> Tab 1 (Analisis)
            CompactRecoveryBanner(
              insight: healthInsight,
              onTapViewAnalysis: () => onNavigateTab(1),
            ),

            // 2. Kartu Langkah Minimalis -> Tab 2 (Riwayat)
            MinimalStepCard(
              totalSteps: healthState.summary.totalStepsToday,
              stepGoal: 10000,
              realDistanceMeters: healthState.summary.totalDistanceToday,
              realActiveCaloriesKcal: healthState.summary.totalActiveCaloriesToday,
              onTap: () => onNavigateTab(2),
            ),

            // 3. Grid Dual Detak Jantung & Tidur
            MetricDualGrid(
              latestHeartRate: healthState.summary.latestHeartRate,
              latestSleep: healthState.summary.latestSleep,
              onTapHeartRate: () => onNavigateTab(1),
              onTapSleep: () => onNavigateTab(1),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Data disinkronkan dari Google Health Connect',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionReminder(
    BuildContext context,
    HealthState state,
    HealthController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.accentAmber,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Izin Health Connect belum aktif. Aktifkan izin untuk membaca data nyata.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => controller.requestPermissions(),
            child: const Text(
              'Aktifkan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
