import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/editorial_ui.dart';
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
    final c = context.suhatColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Integrasi Health Connect',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.inkPrimary,
                      ),
                    ),
                    Text(
                      'Validasi akses dan sinkronisasi data',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang data Health Connect',
                onPressed: state.isLoading ? null : onRefresh,
                icon: state.isLoading
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
            ],
          ),
          const SizedBox(height: 14),
          _buildStatusRows(c),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: c.hairline),
          const SizedBox(height: 12),
          _buildHonestProvenanceNotice(c),
          const SizedBox(height: 14),
          _buildActionButtons(c),
        ],
      ),
    );
  }

  Widget _buildStatusRows(SuhatColors c) {
    String availText;
    Color availColor;
    IconData availIcon;

    switch (state.availability) {
      case HealthConnectAvailability.available:
        availText = 'Health Connect Terpasang';
        availColor = c.accentPine;
        availIcon = Icons.check_circle_outline;
        break;
      case HealthConnectAvailability.updateRequired:
        availText = 'Perlu Update Health Connect';
        availColor = c.statusCaution;
        availIcon = Icons.warning_amber_rounded;
        break;
      case HealthConnectAvailability.notInstalled:
        availText = 'Health Connect Belum Terpasang';
        availColor = c.statusAlert;
        availIcon = Icons.error_outline;
        break;
      case HealthConnectAvailability.unsupportedPlatform:
        availText = 'Platform Tidak Didukung (Bukan Android)';
        availColor = c.inkSecondary;
        availIcon = Icons.device_unknown;
        break;
      case HealthConnectAvailability.checking:
        availText = 'Memeriksa Ketersediaan...';
        availColor = c.inkSecondary;
        availIcon = Icons.hourglass_top;
        break;
    }

    String permText;
    Color permColor;
    IconData permIcon;

    switch (state.permissions) {
      case HealthPermissionStatus.granted:
        permText = 'Izin Membaca: Aktif';
        permColor = c.accentPine;
        permIcon = Icons.verified_user_outlined;
        break;
      case HealthPermissionStatus.denied:
        permText = 'Izin Membaca: Ditolak / Belum Diberikan';
        permColor = c.statusAlert;
        permIcon = Icons.gpp_bad_outlined;
        break;
      case HealthPermissionStatus.partiallyGranted:
        permText = 'Izin Membaca: Sebagian';
        permColor = c.statusCaution;
        permIcon = Icons.gpp_maybe_outlined;
        break;
      case HealthPermissionStatus.unknown:
        permText = 'Izin Membaca: Belum Dikonfirmasi';
        permColor = c.inkSecondary;
        permIcon = Icons.help_outline;
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        EditorialStatusTag(label: availText, color: availColor, icon: availIcon),
        EditorialStatusTag(label: permText, color: permColor, icon: permIcon),
      ],
    );
  }

  Widget _buildHonestProvenanceNotice(SuhatColors c) {
    final hasSynced =
        state.summary.lastFetched != DateTime.fromMillisecondsSinceEpoch(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sumber Data Riil',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.inkPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Data diambil dari Google Health Connect API berdasarkan sinkronisasi perangkat wearable Anda. Setiap rekaman mencantumkan waktu pengukuran asli.',
          style: TextStyle(
            fontSize: 11.5,
            color: c.inkSecondary,
            height: 1.4,
          ),
        ),
        if (hasSynced) ...[
          const SizedBox(height: 6),
          Text(
            'Terakhir disinkronkan: ${DateFormatter.formatDateTime(state.summary.lastFetched)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.accentPine,
              fontFeatures: AppTheme.tabularNumbers,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(SuhatColors c) {
    if (state.availability == HealthConnectAvailability.notInstalled ||
        state.availability == HealthConnectAvailability.updateRequired) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onInstallHealthConnect,
          icon: const Icon(Icons.download, size: 18),
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
          onPressed: state.isRequestingPermission ? null : onRequestPermissions,
          icon: state.isRequestingPermission
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.onAccentPine,
                  ),
                )
              : const Icon(Icons.security, size: 18),
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
