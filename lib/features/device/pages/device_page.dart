import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/widgets/health_status_card.dart';

class DevicePage extends ConsumerWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);
    final prefsService = ref.watch(preferencesServiceProvider);

    final currentGoal = prefsService.getDailyStepGoal();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perangkat & Pengaturan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Integrasi Sumber Data & Preferensi',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          // 1. Status Health Connect & Izin
          HealthStatusCard(
            state: healthState,
            onRequestPermissions: () => controller.requestPermissions(),
            onInstallHealthConnect: () =>
                controller.openStoreForHealthConnect(),
            onRefresh: () => controller.fetchHealthData(),
          ),

          // 2. Petunjuk Sinkronisasi Smartwatch Supercalla MG5 via Fitbeing
          _buildFitbeingGuideCard(),

          // 3. Pengaturan Target Langkah Harian
          _buildStepGoalCard(context, ref, currentGoal),

          // 4. Informasi Sumber Data Health Connect
          _buildHealthConnectNoticeCard(),

          // 5. Tentang Aplikasi & Privasi
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildFitbeingGuideCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.watch,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Panduan Smartwatch Supercalla',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Untuk menampilkan data kesehatan jam Supercalla di aplikasi ini:',
            style: TextStyle(fontSize: 12, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          _buildStepItem('1', 'Buka aplikasi Fitbeing pada ponsel Anda.'),
          _buildStepItem('2', 'Pastikan smartwatch Supercalla terhubung via Bluetooth di Fitbeing.'),
          _buildStepItem('3', 'Masuk ke Pengaturan Fitbeing > Aktifkan integrasi Google Health Connect.'),
          _buildStepItem('4', 'Kembali ke aplikasi Supercalla Health dan tekan tombol sinkronisasi.'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGoalCard(BuildContext context, WidgetRef ref, int currentGoal) {
    final goals = [6000, 8000, 10000, 12000, 15000];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Langkah Harian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target saat ini: $currentGoal langkah per hari',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: goals.map((g) {
              final isSelected = g == currentGoal;
              return ChoiceChip(
                label: Text('$g'),
                selected: isSelected,
                selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryTeal : AppTheme.textDark,
                ),
                onSelected: (selected) async {
                  if (selected) {
                    final prefs = ref.read(preferencesServiceProvider);
                    await prefs.setDailyStepGoal(g);
                    // Refresh data
                    ref.read(healthControllerProvider.notifier).fetchHealthData();
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildHealthConnectNoticeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 20,
            color: AppTheme.primaryTeal,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sumber Data: Google Health Connect',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aplikasi Suhat menggunakan Google Health Connect sebagai pusat pertukaran data kesehatan terpadu. '
                  'Semua metrik dari smartwatch (Supercalla MG5 melalui aplikasi Fitbeing) disinkronkan secara aman dan otomatis melalui Health Connect.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Supercalla Health (Suhat)\nVersi 1.0.0 (MVP Health Connect)\n'
            'Privasi Anda terjamin. Semua data kesehatan disimpan secara lokal dan diproses pada perangkat Anda.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
