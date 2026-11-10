import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../health_connect/presentation/controllers/health_controller.dart';
import '../../health_connect/presentation/widgets/health_status_card.dart';

class DevicePage extends ConsumerWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.suhatColors;
    final healthState = ref.watch(healthControllerProvider);
    final controller = ref.read(healthControllerProvider.notifier);
    final currentGoal = ref.watch(dailyStepGoalProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perangkat & Pengaturan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: c.inkPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'Integrasi Health Connect, tampilan, dan target',
              style: TextStyle(
                fontSize: 11,
                color: c.inkSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 36),
          children: [
            // 1. Focal Sheet: Status Health Connect & Izin
            HealthStatusCard(
              state: healthState,
              onRequestPermissions: () => controller.requestPermissions(),
              onInstallHealthConnect: () =>
                  controller.openStoreForHealthConnect(),
              onRefresh: () => controller.fetchHealthData(),
            ),

            const SizedBox(height: 16),

            // 2. Recessed Block: Pengaturan Tampilan (Terang/Gelap) & Target Langkah
            _buildPreferencesBlock(context, ref, themeMode, currentGoal, c),

            const SizedBox(height: 20),

            // 3. Open Hairline List: Panduan Smartwatch Supercalla
            _buildFitbeingGuideSection(c),

            const SizedBox(height: 16),

            // 4. Open Footer: Sumber Data & Privasi
            _buildFooterNotice(c),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesBlock(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    int currentGoal,
    SuhatColors c,
  ) {
    final goals = [6000, 8000, 10000, 12000, 15000];
    final fmt = NumberFormat('#,###', 'id_ID');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode Tampilan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih tema yang nyaman untuk pagi hari atau luar ruangan',
            style: TextStyle(fontSize: 12, color: c.inkSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceButton(
                c: c,
                label: 'Terang',
                selected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
              _buildChoiceButton(
                c: c,
                label: 'Gelap',
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
              _buildChoiceButton(
                c: c,
                label: 'Sistem',
                selected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 14),

          Text(
            'Target Langkah Harian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target aktif: ${fmt.format(currentGoal)} langkah per hari',
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals.map((g) {
              return _buildChoiceButton(
                c: c,
                label: fmt.format(g),
                selected: g == currentGoal,
                onTap: () async {
                  await ref.read(dailyStepGoalProvider.notifier).setGoal(g);
                  ref.read(healthControllerProvider.notifier).fetchHealthData();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required SuhatColors c,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: c.accentPine,
      backgroundColor: c.surfaceElevated,
      side: BorderSide(
        color: selected ? c.accentPine : c.controlBorder,
        width: 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? c.onAccentPine : c.inkPrimary,
        fontFeatures: AppTheme.tabularNumbers,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: (isSel) {
        if (isSel || selected) onTap();
      },
    );
  }

  Widget _buildFitbeingGuideSection(SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
          Text(
            'Panduan Smartwatch Supercalla',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alur sinkronisasi jam Supercalla MG5 ke aplikasi Suhat:',
            style: TextStyle(fontSize: 12, color: c.inkSecondary),
          ),
          const SizedBox(height: 10),
          _buildGuideRow('01', 'Buka aplikasi FitBeing pada ponsel Anda.', c),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildGuideRow(
              '02', 'Pastikan smartwatch Supercalla MG5 terhubung di FitBeing.', c),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildGuideRow('03',
              'Buka Pengaturan FitBeing lalu aktifkan integrasi Google Health Connect.', c),
          Divider(height: 1, thickness: 1, color: c.hairline),
          _buildGuideRow(
              '04', 'Kembali ke Suhat dan tekan tombol sinkronisasi pada Dashboard.', c),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String numStr, String text, SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.accentPine,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: c.inkPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNotice(SuhatColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 16),
          Text(
            'Sumber Data: Google Health Connect',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suhat menggunakan Google Health Connect sebagai pusat pertukaran data terpadu untuk metrik dari Supercalla MG5 (melalui FitBeing). Seluruh data kesehatan diproses langsung di perangkat Anda.',
            style: TextStyle(
              fontSize: 12,
              color: c.inkSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Supercalla Health (Suhat) • Versi 1.0.0',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
