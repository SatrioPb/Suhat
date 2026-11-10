import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
import '../../analytics/presentation/controllers/analytics_controller.dart';
import '../../health_connect/domain/models/health_models.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/state/health_state.dart';
import '../../running_coach/presentation/controllers/running_coach_controller.dart';
import '../widgets/compact_recovery_banner.dart';
import '../widgets/compact_running_banner.dart';
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
    final coachState = ref.watch(runningCoachStateProvider);
    final stepGoal = ref.watch(dailyStepGoalProvider);
    final controller = ref.read(healthControllerProvider.notifier);
    final c = context.suhatColors;

    final now = DateTime.now();
    final dateFormatted = DateFormatter.formatFullDate(now);
    final hasNeverFetched = healthState.summary.lastFetched ==
        DateTime.fromMillisecondsSinceEpoch(0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatted,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.inkSecondary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Supercalla Health',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.inkPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeToggleIconButton(),
          IconButton(
            tooltip: 'Sinkronkan data Health Connect',
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
                : Icon(Icons.sync, color: c.accentPine),
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
            padding: const EdgeInsets.only(top: 6, bottom: 32),
            children: [
              // Loading state saat pengambilan pertama (R-27)
              if (healthState.isLoading && hasNeverFetched)
                EditorialStateNotice(
                  icon: Icons.sync,
                  color: c.accentPine,
                  title: 'Memuat data kesehatan...',
                  message:
                      'Mengambil rekaman langkah, detak jantung, dan tidur terbaru dari Google Health Connect.',
                  showProgress: true,
                ),

              // Error state (R-27)
              if (healthState.errorMessage != null)
                EditorialStateNotice(
                  icon: Icons.error_outline,
                  color: c.statusAlert,
                  title: 'Sinkronisasi terkendala',
                  message: healthState.errorMessage!,
                  actionLabel: 'Coba Lagi',
                  onAction: () => controller.fetchHealthData(),
                ),

              // Permission state (R-27)
              if (healthState.permissions != HealthPermissionStatus.granted)
                _buildPermissionReminder(context, healthState, controller, c),

              // 1. Focal Point: Langkah Hari Ini (Elevated Crisp Sheet)
              MinimalStepCard(
                totalSteps: healthState.summary.totalStepsToday,
                stepGoal: stepGoal,
                realDistanceMeters: healthState.summary.totalDistanceToday,
                realActiveCaloriesKcal:
                    healthState.summary.totalActiveCaloriesToday,
                onTap: () => onNavigateTab(3),
              ),

              const SizedBox(height: 12),

              // 2. Editorial Hairline Row: Kesiapan Fisik -> Tab 1 (Analisis)
              CompactRecoveryBanner(
                insight: healthInsight,
                onTapViewAnalysis: () => onNavigateTab(1),
              ),

              const SizedBox(height: 12),

              // 3. Recessed Strip: Pelatih Lari Hari Ini -> Tab 2 (Pelatih Lari)
              CompactRunningBanner(
                recommendation: coachState.recommendation,
                onTapViewCoach: () => onNavigateTab(2),
              ),

              const SizedBox(height: 16),

              // 4. Flat Hairline Split Ledger: Detak Jantung & Tidur -> Tab 1
              MetricDualGrid(
                latestHeartRate: healthState.summary.latestHeartRate,
                latestSleep: healthState.summary.latestSleep,
                onTapHeartRate: () => onNavigateTab(1),
                onTapSleep: () => onNavigateTab(1),
              ),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sumber data riil: Google Health Connect (Supercalla MG5 via FitBeing)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionReminder(
    BuildContext context,
    HealthState state,
    HealthController controller,
    SuhatColors c,
  ) {
    final isDenied = state.permissions == HealthPermissionStatus.denied;
    return EditorialStateNotice(
      icon: isDenied ? Icons.lock_outline : Icons.health_and_safety_outlined,
      color: c.statusCaution,
      title: isDenied
          ? 'Izin Health Connect belum diberikan'
          : 'Hubungkan izin Google Health Connect',
      message:
          'Aktifkan izin membaca Langkah, Detak Jantung, Tidur, dan Olahraga agar metrik riil tampil di sini.',
      actionLabel: state.isRequestingPermission ? 'Meminta Izin...' : 'Aktifkan Izin',
      onAction: state.isRequestingPermission
          ? null
          : () => controller.requestPermissions(),
      showProgress: state.isRequestingPermission,
    );
  }
}
