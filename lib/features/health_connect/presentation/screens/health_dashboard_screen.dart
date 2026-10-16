import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/health_controller.dart';
import '../widgets/health_status_card.dart';
import '../widgets/heart_rate_card.dart';
import '../widgets/sleep_card.dart';
import '../widgets/steps_card.dart';

class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);

    // Tampilkan snackbar jika ada error message
    ref.listen(healthControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Suhat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Fase 1: Health Connect',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Validasi Pembacaan Data Kesehatan Nyata',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: () => controller.fetchHealthData(),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            HealthStatusCard(
              state: healthState,
              onRequestPermissions: () => controller.requestPermissions(),
              onInstallHealthConnect: () =>
                  controller.openStoreForHealthConnect(),
              onRefresh: () => controller.fetchHealthData(),
            ),
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
            _buildBluetoothStatusFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothStatusFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 20,
            color: AppTheme.textMuted,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koneksi Bluetooth Langsung: Belum Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sesuai rencana implementasi Fase 1, aplikasi Suhat tidak mengklaim koneksi langsung melalui Bluetooth sebelum modul BLE diimplementasikan dan diverifikasi pada fase berikutnya. Seluruh metrik di atas bersumber dari Google Health Connect.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
