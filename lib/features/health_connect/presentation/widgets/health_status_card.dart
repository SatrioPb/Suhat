import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/health_models.dart';
import '../state/health_state.dart';

class HealthStatusCard extends StatelessWidget {
  final HealthState state;
  final VoidCallback onRequestPermissions;
  final VoidCallback onInstallHealthConnect;
  final VoidCallback onRefresh;

  const HealthStatusCard({
    super.key,
    required this.state,
    required this.onRequestPermissions,
    required this.onInstallHealthConnect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Integrasi Health Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Validasi Akses & Sumber Data',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Muat ulang data',
                  onPressed: state.isLoading ? null : onRefresh,
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, color: AppTheme.primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildStatusBadges(),
            const SizedBox(height: 14),
            _buildHonestProvenanceNotice(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadges() {
    String availText;
    Color availColor;
    IconData availIcon;

    switch (state.availability) {
      case HealthConnectAvailability.available:
        availText = 'Health Connect Terpasang';
        availColor = AppTheme.accentGreen;
        availIcon = Icons.check_circle_outline;
        break;
      case HealthConnectAvailability.updateRequired:
        availText = 'Perlu Update Health Connect';
        availColor = AppTheme.accentAmber;
        availIcon = Icons.warning_amber_rounded;
        break;
      case HealthConnectAvailability.notInstalled:
        availText = 'Health Connect Belum Terpasang';
        availColor = AppTheme.accentRed;
        availIcon = Icons.error_outline;
        break;
      case HealthConnectAvailability.unsupportedPlatform:
        availText = 'Platform Tidak Didukung (Bukan Android)';
        availColor = AppTheme.textMuted;
        availIcon = Icons.device_unknown;
        break;
      case HealthConnectAvailability.checking:
        availText = 'Memeriksa Ketersediaan...';
        availColor = AppTheme.textMuted;
        availIcon = Icons.hourglass_top;
        break;
    }

    String permText;
    Color permColor;
    IconData permIcon;

    switch (state.permissions) {
      case HealthPermissionStatus.granted:
        permText = 'Izin Membaca: Aktif';
        permColor = AppTheme.accentGreen;
        permIcon = Icons.verified_user;
        break;
      case HealthPermissionStatus.denied:
        permText = 'Izin Membaca: Ditolak / Belum Diberikan';
        permColor = AppTheme.accentRed;
        permIcon = Icons.gpp_bad;
        break;
      case HealthPermissionStatus.partiallyGranted:
        permText = 'Izin Membaca: Sebagian';
        permColor = AppTheme.accentAmber;
        permIcon = Icons.gpp_maybe;
        break;
      case HealthPermissionStatus.unknown:
        permText = 'Izin Membaca: Belum Dikonfirmasi';
        permColor = AppTheme.textMuted;
        permIcon = Icons.help_outline;
        break;
    }

    return Column(
      children: [
        _buildPill(
          icon: availIcon,
          label: availText,
          color: availColor,
        ),
        const SizedBox(height: 8),
        _buildPill(
          icon: permIcon,
          label: permText,
          color: permColor,
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHonestProvenanceNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.textMuted,
              ),
              SizedBox(width: 6),
              Text(
                'Catatan Sumber Data (Fase 1)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '• Data diambil secara nyata melalui Google Health Connect API.\n'
            '• Suhat TIDAK terhubung langsung melalui Bluetooth. Data berasal dari sensor perangkat atau wearable yang sudah disinkronkan oleh pengguna ke Health Connect.\n'
            '• Setiap rekaman mencantumkan stempel waktu (timestamp) pengukuran aktual.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          if (state.summary.lastFetched != DateTime.fromMillisecondsSinceEpoch(0))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Terakhir disinkronkan: ${DateFormatter.formatDateTime(state.summary.lastFetched)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (state.availability == HealthConnectAvailability.notInstalled ||
        state.availability == HealthConnectAvailability.updateRequired) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onInstallHealthConnect,
          icon: const Icon(Icons.download),
          label: Text(
            state.availability == HealthConnectAvailability.updateRequired
                ? 'Perbarui Health Connect di Play Store'
                : 'Pasang Health Connect dari Play Store',
          ),
        ),
      );
    }

    if (state.permissions != HealthPermissionStatus.granted) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: state.isRequestingPermission ? null : onRequestPermissions,
          icon: state.isRequestingPermission
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.security),
          label: Text(
            state.isRequestingPermission
                ? 'Menunggu Konfirmasi Izin...'
                : 'Minta Izin Health Connect',
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
